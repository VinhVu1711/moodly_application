import sys
import subprocess
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
scripts = [
    PROJECT_ROOT / "ai/data/fetch_data_from_supabase.py",
    PROJECT_ROOT / "ai/data/generate_period_column.py",
    PROJECT_ROOT / "ai/data/aggerate_period_data.py",
    PROJECT_ROOT / "ai/data/prepare_train_dataset.py",
]

print("🚀 BẮT ĐẦU CHẠY PIPELINE XỬ LÝ DỮ LIỆU...")
for script in scripts:
    print(f"\n▶️ Đang chạy: {script}")
    subprocess.run([sys.executable, str(script)], check=True, cwd=PROJECT_ROOT)
print("\n✅ HOÀN TẤT. Tạo xong train_dataset.csv + 3 dataset period (week/month/year).")
