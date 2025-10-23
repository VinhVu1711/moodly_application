import pandas as pd
import random
from pathlib import Path

# --- Đường dẫn dataset ---
DATA_DIR = Path("ai/data")
PERIOD_FILES = {
    "Tuần": DATA_DIR / "week_period_dataset.csv",
    "Tháng": DATA_DIR / "month_period_dataset.csv",
    "Năm": DATA_DIR / "year_period_dataset.csv",
}

# --- Kiểm tra file nào tồn tại ---
available_files = {k: v for k, v in PERIOD_FILES.items() if v.exists()}
if not available_files:
    raise FileNotFoundError("❌ Không tìm thấy file period dataset nào. Hãy chạy aggerate_period_data.py trước.")

print("📂 Đang tạo train_dataset từ các file:", list(available_files.values()))

# --- Danh sách cảm xúc và người liên quan ---
main_emotions = ["verySad", "sad", "neutral", "happy", "veryHappy"]
other_emotions = [
    "excited", "relaxed", "proud", "hopeful", "happy", "enthusiastic",
    "pitAPart", "refreshed", "depressed", "lonely", "anxious", "sad",
    "angry", "pressured", "annoyed", "tired",
]
people_list = ["stranger", "family", "friends", "partner", "lover"]


# --- Hàm gợi ý logic ---
def build_output(emotion, other, people, period_type):
    e = str(emotion).lower()
    o = str(other).lower()
    p = str(people).lower()

    if any(x in e for x in ["happy", "veryhappy"]) or any(x in o for x in ["relaxed", "refreshed", "hopeful", "excited"]):
        if any(x in p for x in ["partner", "lover", "stranger"]):
            return f"{period_type} này bạn có vẻ rất vui vẻ và thư giãn cùng người thân quen hoặc người lạ. Hãy cân bằng thời gian cho gia đình, vì đó vẫn là mái nhà ấm áp nhất."
        elif "family" in p:
            return f"{period_type} này bạn tận hưởng nhiều niềm vui cùng gia đình. Duy trì năng lượng tích cực và chia sẻ yêu thương nhiều hơn nhé."
        elif "friends" in p:
            return f"{period_type} này bạn có nhiều khoảnh khắc tuyệt vời bên bạn bè. Đừng quên dành thời gian nghỉ ngơi cho bản thân nhé."
        else:
            return f"{period_type} này tinh thần bạn khá ổn định, hãy duy trì thói quen tốt và lan tỏa năng lượng tích cực."
    if any(x in e for x in ["sad", "verysad"]) or any(x in o for x in ["tired", "pressured", "depressed", "anxious", "angry"]):
        if "family" in p:
            return f"{period_type} này bạn có vẻ đang trải qua giai đoạn khó khăn. Hãy chia sẻ với gia đình, vì họ luôn là điểm tựa tinh thần vững chắc."
        elif "friends" in p:
            return f"{period_type} này tâm trạng của bạn hơi nặng nề, nhưng việc gặp gỡ bạn bè sẽ giúp bạn thoải mái hơn. Hãy cho mình thời gian nghỉ ngơi."
        else:
            return f"{period_type} này bạn có vẻ mệt mỏi và cần nghỉ ngơi. Hãy ngủ sớm, ăn uống đều đặn và dành thời gian hít thở sâu."
    if "neutral" in e:
        return f"{period_type} này tâm trạng bạn khá cân bằng. Hãy tiếp tục duy trì sự ổn định và tìm thêm hoạt động khiến bạn thấy ý nghĩa."
    return f"{period_type} này cảm xúc của bạn khá đa dạng. Hãy lắng nghe bản thân để hiểu điều mình cần và tìm lại nhịp sống thoải mái hơn."


# --- Tổng hợp dữ liệu từ các file period ---
train_rows = []

for period_type, file_path in available_files.items():
    df = pd.read_csv(file_path)
    print(f"🔹 Đọc {len(df)} dòng từ {file_path.name}")

    # Xác định đúng tên cột period (week/month/year)
    period_field = [c for c in df.columns if "period" in c][0]

    for _, row in df.iterrows():
        user = row.get("user_id", "unknown")
        period_val = row.get(period_field, "unknown")  # ✅ lấy đúng cột period
        emotion = row.get("emotion", "")
        other = row.get("another_emotions", "")
        people = row.get("people", "")
        note = row.get("note", "")

        input_text = (
            f"User: {user}. Period: {period_val}. "
            f"Emotions: {emotion}. OtherEmotion: {other}. People: {people}. Notes: {note}"
        )
        output_text = build_output(emotion, other, people, period_type)
        train_rows.append(
            {"user_id": user, "input_text": input_text, "output_text": output_text}
        )

# --- Thêm dữ liệu demo gợi ý ngẫu nhiên ---
templates = [
    "Bạn đã trải qua một {period} đầy cảm xúc, hãy trân trọng từng khoảnh khắc dù vui hay buồn.",
    "{period} này là cơ hội tốt để bạn nhìn lại bản thân và đặt ra mục tiêu mới.",
    "Dù {period} này có thử thách, hãy tin rằng bạn đủ mạnh mẽ để vượt qua.",
    "Cảm xúc là điều tự nhiên, quan trọng là bạn luôn học cách kiểm soát và hiểu chính mình.",
    "Đôi khi im lặng cũng là cách để chữa lành. Hãy cho bản thân thời gian hồi phục trong {period} này.",
]

for _ in range(100):
    period = random.choice(["Tuần", "Tháng", "Năm"])
    emotion = random.choice(main_emotions)
    other = random.choice(other_emotions)
    people = random.choice(people_list)
    train_rows.append(
        {
            "user_id": "demo",
            "input_text": f"User: demo. Period: random-{period}. Emotion: {emotion}. OtherEmotion: {other}. People: {people}. Note: generated sample.",
            "output_text": random.choice(templates).format(period=period),
        }
    )

# --- Ghi ra file train_dataset ---
train_df = pd.DataFrame(train_rows)
output_path = DATA_DIR / "train_dataset.csv"
train_df.to_csv(output_path, index=False, encoding="utf-8")

print(f"✅ Đã tạo {output_path} với {len(train_df)} dòng (đã sửa period đúng, gồm week/month/year + demo).")
