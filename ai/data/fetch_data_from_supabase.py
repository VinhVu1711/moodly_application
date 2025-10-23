from supabase import create_client, Client
import pandas as pd

# --- Cấu hình Supabase ---
SUPABASE_URL = "https://dznyqpjisucohdvcjxid.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6bnlxcGppc3Vjb2hkdmNqeGlkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzU2MDA5MiwiZXhwIjoyMDczMTM2MDkyfQ.ejIncZDJYN1O1xhp0hwYDAk0IbeDLw8ujKP3uBOA_bo"
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
