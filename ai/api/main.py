from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
from ai.data.fetch_data_from_supabase import fetch_all_logs
from ai.data.clean_data import clean_logs
from ai.utils.date_utils import filter_logs_for_user_mode
from ai.model.prompt_template import build_prompt
from ai.model.generate_output import generate_output
import os
import time
import pandas as pd

app = FastAPI(title="Moodly AI API", version="1.2")

# -------- Schemas --------
class RefreshBody(BaseModel):
    """Body khi user lưu mood — trigger fetch + clean toàn bộ"""
    mode: str = Field("week", description="week | month | year")
    month: Optional[int] = None
    year: Optional[int] = None

class AdviceBody(BaseModel):
    """Body khi Flutter gọi để sinh lời khuyên"""
    user: str
    mode: str = Field("week", description="week | month | year")
    month: Optional[int] = None
    year: Optional[int] = None
    lan: str = Field("vn", description="vn | eng")

# -------- Helpers --------
def _validate_mode_payload(mode: str, month: Optional[int], year: Optional[int]):
    if mode == "month" and (not month or not year):
        raise HTTPException(status_code=400, detail="mode=month cần month và year")
    if mode == "year" and not year:
        raise HTTPException(status_code=400, detail="mode=year cần year")

# -------- Endpoints --------
@app.get("/")
def home():
    return {"message": "Moodly AI API is running"}

# ================================================================
# 🔹 Khi user lưu mood → 20s sau tự động fetch toàn bộ + clean lại
# ================================================================
@app.post("/refresh-data")
async def refresh_data(background_tasks: BackgroundTasks):
    """
    Khi người dùng lưu cảm xúc -> gọi endpoint này.
    Hệ thống sẽ đợi 20s rồi tự động fetch toàn bộ dữ liệu từ Supabase
    và clean lại logs_clean.csv cho tất cả user.
    """
    def delayed_clean():
        time.sleep(20)
        print("📦 Fetching ALL logs (all users)...")
        df = fetch_all_logs()
        if not df.empty:
            clean_logs()
            print(f"✅ Dữ liệu toàn hệ thống đã được làm sạch ({len(df)} rows)")
        else:
            print("⚠️ Không có dữ liệu nào trong Supabase.")

    background_tasks.add_task(delayed_clean)
    return {"message": "Đang chuẩn bị làm sạch toàn bộ dữ liệu..."}

# ================================================================
# 🔹 Khi user bấm Get Advice → lọc dữ liệu đã clean → gọi Gemini
# ================================================================
@app.post("/get-advice")
async def get_advice(body: AdviceBody):
    """
    Flutter POST JSON:
    {
      "user":"a",
      "mode":"week",
      "lan":"vn"
    }
    hoặc
    {
      "user":"a",
      "mode":"month",
      "month":10,
      "year":2025,
      "lan":"eng"
    }
    """
    _validate_mode_payload(body.mode, body.month, body.year)

    csv_path = "ai/data/logs_clean.csv"
    if not os.path.exists(csv_path):
        raise HTTPException(status_code=404, detail="Chưa có dữ liệu clean. Hãy lưu cảm xúc trước.")

    df = pd.read_csv(csv_path)
    if df.empty:
        raise HTTPException(status_code=404, detail="logs_clean.csv rỗng, chưa có dữ liệu để sinh lời khuyên.")

    # lọc theo user + mode
    filtered = filter_logs_for_user_mode(
        user_id=body.user,
        mode=body.mode,
        month=body.month,
        year=body.year
    )

    if not filtered:
        raise HTTPException(status_code=404, detail=f"Không có log phù hợp cho user {body.user} ({body.mode}).")

    logs_text = "\n".join(filtered)
    prompt = build_prompt(logs_text, body.lan, body.mode)
    print(prompt)
    print(f"🧠 Generating advice for user={body.user}, mode={body.mode} ...")

    output = generate_output(prompt)
    print("✅ Hoàn tất sinh lời khuyên.")

    return {
        "user": body.user,
        "mode": body.mode,
        "month": body.month,
        "year": body.year,
        "language": body.lan,
        "ai_output": output,
        "count": len(filtered),
    }
