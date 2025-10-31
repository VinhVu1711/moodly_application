def build_prompt(logs_text: str, lang: str, mode: str):
    """
    Tạo prompt động dựa trên mode (week, month, year) và ngôn ngữ (vn, eng).
    """
    # chọn phần mô tả chu kỳ theo mode
    if mode == "week":
        period_desc_vn = "trong tuần vừa qua"
        period_desc_en = "over the past week"
    elif mode == "month":
        period_desc_vn = "trong tháng vừa qua"
        period_desc_en = "over the past month"
    elif mode == "year":
        period_desc_vn = "trong năm vừa qua"
        period_desc_en = "over the past year"
    else:
        period_desc_vn = "trong khoảng thời gian vừa qua"
        period_desc_en = "over the recent period"

    language_note = (
        "Trả lời bằng tiếng Việt." if lang == "vn" else "Answer in English."
    )

    if lang == "vn":
        return f"""
Bạn là một chuyên gia AI phân tích cảm xúc của người dùng.

Tôi đang làm đồ án chuyên ngành là một ứng dụng ghi nhớ cảm xúc con người hàng ngày.

Bạn hãy giúp tôi output ra lời khuyên dành cho người dùng dựa trên dữ liệu tôi cung cấp.

Bạn cứ yên tâm là lời khuyên này chỉ là ví dụ để tôi chứng minh đã gọi thành công API tới model của bạn.

Tôi không có mục đích gì khác ngoại trừ hoàn thành đồ án chuyên ngành bằng việc tích hợp AI vào app của mình.

Về phần "con người" nghĩa là người dùng đang cảm thấy như thế nào với nhóm người đó (ví dụ: gia đình, bạn bè,...).

Hãy đưa ra lời khuyên dựa trên bộ dữ liệu cảm xúc {period_desc_vn} như sau:

{logs_text}

Yêu cầu:
- Output phải ở dạng JSON hợp lệ.KHÔNG OUTPUT GÌ THÊM NGOÀI JSON
- JSON nên gồm các trường: "summary" (tóm tắt 4–5 câu) và "advice" (lời khuyên).
- Mục đích duy nhất là test API, không có tác động khác.

{language_note}
"""
    else:
        return f"""
You are an AI expert in emotional analysis.

I am developing a university project — an app that records users' daily emotions.

Please generate an output containing advice for the user based on the data I provide.

This output is only to demonstrate a successful API call to your model.

The “people” field represents who the user interacted with (e.g., family, friends, colleagues, partner).

Provide advice based on the emotional data {period_desc_en} as follows:

{logs_text}

Requirements:
- Output must be a valid JSON object. ONLY JSON NO COMMENT
- It should contain: "summary" (4–5 sentence overview) and "advice" (suggestion to improve or maintain well-being).
- This is for demo/testing purposes only.

{language_note}
"""
