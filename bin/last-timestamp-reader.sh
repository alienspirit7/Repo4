#!/bin/bash
# Last Timestamp Reader - Shell Script Version
# Reads last timestamp from log file every 7 seconds

REPO_PATH="/usr/local/repo4"
LOG_FILE="$REPO_PATH/logs/system-logs.log"
INTERVAL=7

# Function for graceful shutdown
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') Last Timestamp Reader stopped" >&2
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

echo "$(date '+%Y-%m-%d %H:%M:%S') Last Timestamp Reader starting..." >&2

# Main loop
while true; do
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        LAST_TIMESTAMP=$(tail -n 1 "$LOG_FILE")
        echo "Last timestamp: $LAST_TIMESTAMP"
    else
        echo "Log file not found or empty"
    fi
    sleep $INTERVAL
done
