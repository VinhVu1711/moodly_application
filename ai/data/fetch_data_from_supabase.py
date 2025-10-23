from supabase import create_client, Client
import pandas as pd

# --- Cấu hình Supabase ---
SUPABASE_URL = "a"
SUPABASE_KEY = "b"
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# --- Lấy dữ liệu từ bảng moods ---
response = supabase.table("moods").select(
    "user_id,emotion,another_emotions,people,note,day"
).execute()
data = response.data

# --- Ghi dữ liệu ra CSV ---
df = pd.DataFrame(data)
df.to_csv("ai/data/moodly_export.csv", index=False, encoding="utf-8")

print(f"✅ Đã tải {len(df)} dòng dữ liệu mới từ Supabase (có user_id).")
