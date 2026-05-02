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
    VENV_PIP="venv/Scripts/pip"
    ACTIVATE_CMD="source venv/Scripts/activate"
else
    VENV_PIP="venv/bin/pip"
    ACTIVATE_CMD="source venv/bin/activate"
fi

echo "[4/5] Upgrading pip..."
$VENV_PIP install --upgrade pip

echo "[5/5] Installing dependencies..."
$VENV_PIP install -r requirements.txt

echo ""
echo "Setup complete. Run '$ACTIVATE_CMD' then 'python manage.py runserver' to start."