from google import genai
import os
from dotenv import load_dotenv

# 1. Đọc biến môi trường (nếu bạn dùng .env)
load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

# 2. Truyền API key trực tiếp vào client
client = genai.Client(api_key=api_key)

# 3. Gọi model
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="1+1=?",
)

print(response.text)
