#!/usr/bin/env bash
set -e

mkdir -p logs

trap 'echo ""; echo "Monitoring stopped."; exit 0' INT TERM

echo "Starting health monitor — checking http://localhost/health/ every 30 seconds."
echo "Logging to logs/health.log. Press Ctrl+C to stop."
echo ""

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    RESPONSE=$(curl -4 -s -o /tmp/health_body -w "%{http_code}" --max-time 5 http://localhost/health/ 2>/dev/null || echo "000")
    HTTP_CODE="$RESPONSE"

    if [ -f /tmp/health_body ] && [ -s /tmp/health_body ]; then
        BODY=$(cat /tmp/health_body)
    else
        BODY="no response"
    fi

    if [ "$HTTP_CODE" = "200" ]; then
        STATUS="UP"
    else
        STATUS="DOWN"
    fi

    LINE="[$TIMESTAMP] STATUS: $STATUS | HTTP: $HTTP_CODE | Response: $BODY"

    echo "$LINE"
    echo "$LINE" >> logs/health.log

    sleep 30
done
