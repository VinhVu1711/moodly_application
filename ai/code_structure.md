ai/
│
├── data/ # dữ liệu gốc và sau xử lý
│ ├── raw/ # dữ liệu lấy từ Supabase (CSV, JSON)
│ ├── processed/ # dữ liệu đã làm sạch, chuẩn hóa
│ └── embeddings/ # file FAISS hoặc SQLite-vec
│
├── retrieval/ # tạo, truy xuất embedding
│ ├── build_index.py # sinh embedding + lưu
│ ├── search_index.py # truy xuất log theo vector
│
├── generation/ # phần gọi model lớn để sinh summary/advice
│ ├── prompt_templates.py
│ ├── generate_summary.py
│ └── generate_advice.py
│
├── api/ # API nội bộ phục vụ Flutter
│ ├── app.py # Flask/FastAPI server
│
├── notebooks/ # notebook test tạm
│
└── utils/ # xử lý chung
├── supabase_fetch.py
└── preprocess.py

Pipeline

1. utils/supabase_fetch.py → export data
2. retrieval/build_index.py → tạo embedding
3. generation/generate_summary.py → gọi model lớn
4. api/app.py → expose endpoint
