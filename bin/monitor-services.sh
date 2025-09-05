#!/bin/bash
"""
Service Status Monitoring Script
Checks status of both services and log file health
"""

REPO_PATH="$HOME/Documents/25D/L2/Repo4"
LOG_FILE="$REPO_PATH/logs/system-logs.log"

echo "=== Service Status Check ==="
echo "Timestamp: $(date)"
echo

# Check service status
echo "System Log Writer Service:"
systemctl --user is-active system-log-writer.service || echo "INACTIVE"

echo "Last Timestamp Reader Service:"
systemctl --user is-active last-timestamp-reader.service || echo "INACTIVE"

echo
echo "=== Log File Health ==="
if [ -f "$LOG_FILE" ]; then
    echo "Log file exists: $LOG_FILE"
    echo "File size: $(wc -c < "$LOG_FILE") bytes"
    echo "Line count: $(wc -l < "$LOG_FILE") lines"
    echo "Last 3 entries:"
    tail -n 3 "$LOG_FILE"
else
    echo "ERROR: Log file not found!"
fi
