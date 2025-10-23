import pandas as pd
from datetime import datetime

# --- Đọc dữ liệu ---
df = pd.read_csv("ai/data/moodly_with_period.csv")
df["day"] = pd.to_datetime(df["day"], errors="coerce")

# Mặc định tuần cần ≥5/7 ngày có dữ liệu, tháng ≥22/30, năm ≥274/365.
def aggregate_and_save(df, period_field, min_ratio=0.75):
    """Tạo dataset theo period, kiểm tra coverage >= 75% cho tất cả các mốc thời gian"""
    results = []
    grouped = df.groupby(["user_id", period_field])

    for (user, period), group in grouped:
        # --- Xác định tổng số ngày trong period ---
        if period_field == "week_period":
            # Tách năm và số tuần
            year_str, week_str = str(period).split("-W")
            year, week = int(year_str), int(week_str)
            # Lấy ngày thứ Hai đầu tuần, sau đó đếm 7 ngày
            start = datetime.strptime(f"{year}-W{week}-1", "%Y-W%W-%w")
            total_days = 7
        elif period_field == "month_period":
            year, month = map(int, period.split("-"))
            total_days = pd.Period(f"{year}-{month}").days_in_month
        elif period_field == "year_period":
            year = int(period)
            total_days = 366 if pd.Timestamp(year, 12, 31).is_leap_year else 365
        else:
            continue

        # --- Tính số ngày người dùng có dữ liệu ---
        unique_days = group["day"].dt.date.nunique()
        coverage = unique_days / total_days

        # --- Bỏ qua nếu không đủ 75% dữ liệu ---
        if coverage < min_ratio:
            continue

        results.append({
            "user_id": user,
            period_field: period,
            "emotion": list(group["emotion"]),
            "another_emotions": list(group["another_emotions"]),
            "people": list(group["people"]),
            "note": " ".join([str(n) for n in group["note"] if pd.notna(n)]),
            "coverage_ratio": round(coverage, 2)
        })

    # --- Nếu không có kết quả thì báo ---
    if not results:
        print(f"⚠️ Không có dữ liệu đạt {min_ratio*100:.0f}% cho {period_field}")
        return

    df_out = pd.DataFrame(results)

    # --- Tạo input_text tổng hợp ---
    def build_input(row):
        e = ", ".join([str(x) for x in row["emotion"] if str(x) != "nan"])
        o = ", ".join([str(x) for x in row["another_emotions"] if str(x) != "nan"])
        p = ", ".join([str(x) for x in row["people"] if str(x) != "nan"])
        n = row["note"] if pd.notna(row["note"]) else "No notes"
        return (
            f"User: {row['user_id']}. Period: {row[period_field]}. "
            f"Emotions: [{e}]. OtherEmotions: [{o}]. People: [{p}]. Notes: {n}"
        )

    df_out["input_text"] = df_out.apply(build_input, axis=1)
    df_out["output_text"] = ""

    path = f"ai/data/{period_field}_dataset.csv"
    df_out.to_csv(path, index=False, encoding="utf-8")
    print(f"✅ Xuất {path} ({len(df_out)} dòng, coverage ≥{min_ratio*100:.0f}%).")

# --- Tạo cả 3 file ---
aggregate_and_save(df, "week_period")
aggregate_and_save(df, "month_period")
aggregate_and_save(df, "year_period")
