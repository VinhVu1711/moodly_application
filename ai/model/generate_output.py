import google.generativeai as genai
from dotenv import load_dotenv
import os

load_dotenv()

def generate_output(prompt: str, model_name: str = "gemini-2.5-flash"):
    genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
    model = genai.GenerativeModel(model_name)
    resp = model.generate_content(prompt)
    print("✅ Gemini output")
    return resp.text
