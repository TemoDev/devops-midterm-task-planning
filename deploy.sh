#!/usr/bin/env bash
set -e

echo "=== Blue-Green Deploy ==="

# Step 1: Read active slot
echo "[1/6] Reading active slot..."
ACTIVE_PORT=8001
if [ -f ".active_slot" ]; then
    ACTIVE_PORT=$(cat .active_slot)
fi

# Step 2: Determine inactive port
if [ "$ACTIVE_PORT" = "8001" ]; then
    INACTIVE_PORT=8002
else
    INACTIVE_PORT=8001
fi

echo "Active slot: port $ACTIVE_PORT — deploying to port $INACTIVE_PORT"

# Step 3: Activate venv
echo "[2/6] Activating virtual environment..."
source ./venv/bin/activate

echo "[3/6] Installing dependencies..."
pip install -q -r requirements.txt

# Step 4: Kill any existing process on inactive port
echo "[4/6] Clearing port $INACTIVE_PORT..."
fuser -k "$INACTIVE_PORT/tcp" 2>/dev/null || true
sleep 1

# Step 5: Start Django on inactive port (disable autoreload with --noreload)
echo "[5/6] Starting Django on port $INACTIVE_PORT..."
mkdir -p logs
nohup ./venv/bin/python manage.py runserver --noreload "0.0.0.0:$INACTIVE_PORT" > "logs/app_$INACTIVE_PORT.log" 2>&1 &
APP_PID=$!
echo "Started process PID $APP_PID"
disown

# Step 6: Health check
echo "[6/6] Waiting for app to be ready..."
for i in {1..10}; do
    sleep 2
    STATUS=$(curl -4 -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:$INACTIVE_PORT/health/" || echo "000")
    echo "Attempt $i: status code '$STATUS'"
    if [ "$STATUS" = "200" ]; then
        echo "Deploy successful on port $INACTIVE_PORT"
        exit 0
    fi
done

echo "Deploy failed - health check did not pass on port $INACTIVE_PORT"
echo "--- Last log output ---"
tail -20 "logs/app_$INACTIVE_PORT.log"
exit 1