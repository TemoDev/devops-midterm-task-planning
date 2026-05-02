#!/usr/bin/env bash
set -e

echo "[1/5] Checking Python 3 installation..."
if python3 -c "import sys; sys.exit(0)" &> /dev/null; then
    PYTHON=python3
elif python -c "import sys; sys.exit(0)" &> /dev/null; then
    PYTHON=python
else
    echo "Error: Python 3 is not installed. Please install it and try again."
    exit 1
fi

echo "[2/5] Creating virtual environment..."
if [ ! -d "venv" ]; then
    $PYTHON -m venv venv
fi

echo "[3/5] Activating virtual environment..."
if [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

echo "[4/5] Upgrading pip..."
python -m pip install --upgrade pip

echo "[5/5] Installing dependencies..."
pip install -r requirements.txt

echo ""
if [ -f "venv/Scripts/activate" ]; then
    echo "Setup complete. Run 'source venv/Scripts/activate' then 'python manage.py runserver' to start."
else
    echo "Setup complete. Run 'source venv/bin/activate' then 'python manage.py runserver' to start."
fi
