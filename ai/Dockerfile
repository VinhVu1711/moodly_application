# --- ai/Dockerfile ---
FROM python:3.10-slim

# Thư mục làm việc trong container
WORKDIR /app

# Copy file yêu cầu
COPY requirements.txt .

# Cài thư viện
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ thư mục "ai" vào container
COPY . /app/ai
ENV PYTHONUNBUFFERED=1
# Mở cổng
EXPOSE 8000

# Chạy API từ root package "ai"
CMD ["uvicorn", "ai.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
