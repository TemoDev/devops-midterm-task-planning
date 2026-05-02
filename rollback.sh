#!/usr/bin/env bash
set -e

echo "=== Blue-Green Rollback ==="

# Step 1: Read active slot
echo "[1/5] Reading active slot..."
ACTIVE_PORT=8001
if [ -f ".active_slot" ]; then
    ACTIVE_PORT=$(cat .active_slot)
fi

# Step 2: Determine previous port
if [ "$ACTIVE_PORT" = "8001" ]; then
    PREVIOUS_PORT=8002
else
    PREVIOUS_PORT=8001
fi
echo "Current active: port $ACTIVE_PORT — rolling back to port $PREVIOUS_PORT"

# Step 3: Verify previous instance is healthy
echo "[2/5] Checking previous instance on port $PREVIOUS_PORT..."
if ! curl -sf "http://127.0.0.1:$PREVIOUS_PORT/health/" > /dev/null; then
    echo "Rollback failed - previous instance not running on port $PREVIOUS_PORT"
    exit 1
fi
echo "Previous instance is healthy."

# Step 4: Update nginx.conf and reload
echo "[3/5] Updating nginx.conf..."
sed -i "s/server 127.0.0.1:[0-9]\+;/server 127.0.0.1:$PREVIOUS_PORT;/" nginx.conf

echo "[4/5] Applying nginx config..."
sudo cp nginx.conf /etc/nginx/sites-available/taskmanager
sudo ln -sf /etc/nginx/sites-available/taskmanager /etc/nginx/sites-enabled/taskmanager
sudo nginx -t
sudo systemctl reload nginx

# Step 5: Save rolled-back slot
echo "[5/5] Updating active slot..."
echo "$PREVIOUS_PORT" > .active_slot

echo "Rolled back to port $PREVIOUS_PORT"
