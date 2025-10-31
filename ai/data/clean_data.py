import pandas as pd
import ast

# mapping tiếng Việt
emotion5_map = {
    "very_sad": "rất buồn",
    "sad": "buồn",
    "neutral": "bình thường",
    "happy": "vui",
    "very_happy": "rất vui",
}

another_map = {
    "excited": "phấn khích",
    "relaxed": "thư giãn",
    "proud": "tự hào",
    "hopeful": "hy vọng",
    "happy": "hạnh phúc",
    "enthusiastic": "nhiệt huyết",
    "pitAPart": "tách biệt",
    "refreshed": "tươi mới",
    "depressed": "chán nản",
    "lonely": "cô đơn",
    "anxious": "lo lắng",
    "sad": "buồn",
    "angry": "tức giận",
    "pressured": "áp lực",
    "annoyed": "khó chịu",
    "tired": "mệt mỏi",
}

people_map = {
    "stranger": "người lạ",
    "family": "gia đình",
    "friends": "bạn bè",
    "partner": "đồng nghiệp",   # giữ nguyên “người yêu”
    "lover": "người yêu",
    "alone": "một mình",
}

def _parse_list(value):
    if value is None or str(value).strip() == "" or str(value).lower() in ["nan", "none", "null"]:
        return []
    s = str(value).strip()
    try:
        parsed = ast.literal_eval(s)
        if isinstance(parsed, list):
            return [str(x) for x in parsed if str(x).strip()]
    except Exception:
        pass
    return [x.strip() for x in s.split(",") if x.strip()]

def clean_logs(input_path="ai/data/logs_raw.csv", output_path="ai/data/logs_clean.csv"):
    """
    Làm sạch toàn bộ dữ liệu của tất cả user.
    - Dịch enum -> tiếng Việt
    - Nếu 'people' rỗng thì hiển thị 'một mình'
    """
    df = pd.read_csv(input_path)
    if df.empty:
        print("⚠️ Không có dữ liệu để clean.")
        return []

    cleaned_rows = []
    for _, row in df.iterrows():
        date = row.get("day", "")
        uid = row.get("user_id", "")
        main = emotion5_map.get(str(row.get("emotion", "")).strip(), "không có")

        another_raw = row.get("another_emotions", "")
        subs = _parse_list(another_raw)
        sub = ", ".join([another_map.get(x, x) for x in subs]) if subs else "không có"

        # xử lý people
        people_raw = row.get("people", "")
        ppl = _parse_list(people_raw)
        if ppl:
            # lấy phần tử đầu tiên và map
            people_key = ppl[0].lower().strip()
            people_vi = people_map.get(people_key, people_key)
        else:
            people_vi = "một mình"

        note = row.get("note", "")
        note = "không có" if not note or str(note).lower() == "nan" else str(note)

        text = f"{date}, cảm xúc chính: {main}, cảm xúc phụ: {sub}, con người: {people_vi}, note: {note}"
        cleaned_rows.append({"user_id": uid, "formatted": text, "day": date})

    out_df = pd.DataFrame(cleaned_rows)
    out_df.to_csv(output_path, index=False, encoding="utf-8-sig")
    print(f"✅ Cleaned → {output_path} rows={len(out_df)}")
    return cleaned_rows
