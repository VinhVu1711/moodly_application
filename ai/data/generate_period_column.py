import pandas as pd

# --- Đọc dữ liệu gốc ---
df = pd.read_csv("ai/data/moodly_export.csv")

# --- Chuyển cột day sang datetime ---
df["day"] = pd.to_datetime(df["day"], errors="coerce")

# --- Tạo cột period ---
df["week_period"] = df["day"].dt.strftime("%Y-W%U")
df["month_period"] = df["day"].dt.strftime("%Y-%m")
df["year_period"] = df["day"].dt.strftime("%Y")

# --- Lưu file ---
df.to_csv("ai/data/moodly_with_period.csv", index=False, encoding="utf-8")
print(f"✅ Đã tạo moodly_with_period.csv ({len(df)} dòng).")
