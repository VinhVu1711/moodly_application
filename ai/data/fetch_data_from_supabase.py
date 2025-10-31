from supabase import create_client
from dotenv import load_dotenv
import pandas as pd
import os

dotenv_path = os.path.join(os.path.dirname(__file__), "../.env")
load_dotenv(dotenv_path=dotenv_path)
supabase = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

def fetch_all_logs():
    """
    Lấy toàn bộ dữ liệu bảng moods của tất cả người dùng.
    """
    print("📦 Fetching ALL logs from Supabase (all users)...")

    resp = (
        supabase.table("moods")
        .select("*")
        .order("day", desc=False)
        .execute()
    )

    df = pd.DataFrame(resp.data or [])
    out_path = "ai/data/logs_raw.csv"
    df.to_csv(out_path, index=False, encoding="utf-8-sig")

    print(f"✅ Exported {len(df)} rows → {out_path}")
    return df
