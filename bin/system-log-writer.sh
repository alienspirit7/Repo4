#!/bin/bash
# System Log Writer - Shell Script Version
# Writes current system time to log file every 10 seconds

REPO_PATH="/usr/local/repo4"
LOG_FILE="$REPO_PATH/logs/system-logs.log"
INTERVAL=10

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function for graceful shutdown
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') System Log Writer stopped" >&2
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

echo "$(date '+%Y-%m-%d %H:%M:%S') System Log Writer starting..." >&2

# Main loop
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    sleep $INTERVAL
done
