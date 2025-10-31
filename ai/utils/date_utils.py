import pandas as pd
from datetime import datetime, timedelta

def _normalize_date(date_str):
    try:
        return pd.to_datetime(date_str)
    except Exception:
        return pd.NaT

def filter_logs_for_user_mode(user_id: str, mode: str, month: int | None = None, year: int | None = None):
    """
    Đọc file logs_clean.csv, lọc theo user + mode (week/month/year).
    Trả về list chuỗi text để build prompt.
    """
    df = pd.read_csv("ai/data/logs_clean.csv")
    if df.empty:
        print("⚠️ logs_clean.csv rỗng.")
        return []

    df["day"] = pd.to_datetime(df["day"], errors="coerce")
    df = df[df["user_id"] == user_id]

    if df.empty:
        print(f"⚠️ Không tìm thấy log cho user={user_id}.")
        return []

    now = datetime.now()

    if mode == "week":
        start = now - timedelta(days=7)
        df = df[df["day"] >= start]

    elif mode == "month":
        if not month or not year:
            month, year = now.month, now.year
        start = datetime(year, month, 1)
        end = datetime(year + (month // 12), (month % 12) + 1, 1)
        df = df[(df["day"] >= start) & (df["day"] < end)]

    elif mode == "year":
        if not year:
            year = now.year
        start = datetime(year, 1, 1)
        end = datetime(year + 1, 1, 1)
        df = df[(df["day"] >= start) & (df["day"] < end)]

    else:
        print("⚠️ Mode không hợp lệ. Dùng week | month | year.")
        return []

    print(f"📊 Filtered {len(df)} logs for user={user_id}, mode={mode}")
    return df["formatted"].tolist()
