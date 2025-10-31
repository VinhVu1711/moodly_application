import sys
import os

sys.path.append(os.path.dirname(__file__))

from data.fetch_data_from_supabase import fetch_all_logs
from data.clean_data import clean_logs

if __name__ == "__main__":
    print("📦 Fetching all logs for all users...")
    df = fetch_all_logs()

    if df.empty:
        print("⚠️ Không có dữ liệu trong bảng moods.")
    else:
        print("🧹 Cleaning all logs ...")
        clean_logs()
        print("✅ Hoàn tất pipeline (fetch + clean).")
