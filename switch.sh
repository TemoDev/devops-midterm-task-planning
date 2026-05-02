#!/usr/bin/env bash
set -e

echo "=== Blue-Green Switch ==="

# Step 1: Read active slot
echo "[1/7] Reading active slot..."
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

echo "Current active: port $ACTIVE_PORT — switching to port $INACTIVE_PORT"

# Step 3: Update nginx.conf upstream
echo "[2/7] Updating nginx.conf..."
sed -i "s/server 127.0.0.1:[0-9]\+;/server 127.0.0.1:$INACTIVE_PORT;/" nginx.conf

# Step 4: Copy config to sites-available
echo "[3/7] Copying config to /etc/nginx/sites-available/taskmanager..."
sudo cp nginx.conf /etc/nginx/sites-available/taskmanager

# Step 5: Create symlink in sites-enabled
echo "[4/7] Enabling site..."
sudo ln -sf /etc/nginx/sites-available/taskmanager /etc/nginx/sites-enabled/taskmanager

# Step 6: Remove default Nginx site to avoid conflicts
echo "[5/7] Removing default Nginx site..."
sudo rm -f /etc/nginx/sites-enabled/default

# Step 7: Test nginx config
echo "[6/7] Testing nginx configuration..."
sudo nginx -t

# Step 8: Reload nginx
echo "[7/7] Reloading nginx..."
sudo systemctl reload nginx

# Step 9: Save new active slot
echo "$INACTIVE_PORT" > .active_slot

echo "Switched traffic to port $INACTIVE_PORT"