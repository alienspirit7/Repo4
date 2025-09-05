#!/bin/bash
# macOS Service Status Monitoring Script - IMPROVED VERSION
# Actually checks if services are working, not just loaded

REPO_PATH="$HOME/Documents/25D/L2/Repo4"
LOG_FILE="$REPO_PATH/logs/system-logs.log"

echo "=== macOS Service Status Check ==="
echo "Timestamp: $(date)"
echo

# Check service load status
echo "System Log Writer Service:"
if launchctl list | grep -q com.user.system-log-writer; then
    echo "LOADED by launchctl"
    launchctl list | grep com.user.system-log-writer
else
    echo "NOT LOADED"
fi

echo ""
echo "Last Timestamp Reader Service:"
if launchctl list | grep -q com.user.last-timestamp-reader; then
    echo "LOADED by launchctl"
    launchctl list | grep com.user.last-timestamp-reader
else
    echo "NOT LOADED"
fi

echo
echo "=== Actual Service Health Check ==="
CURRENT_TIME=$(date +%s)

if [ -f "$LOG_FILE" ]; then
    # Get the last log entry and its timestamp
    LAST_ENTRY=$(tail -n 1 "$LOG_FILE")
    echo "Last log entry: $LAST_ENTRY"
    
    if [ ! -z "$LAST_ENTRY" ]; then
        # Convert last entry to epoch time for comparison
        LAST_LOG_TIME=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_ENTRY" "+%s" 2>/dev/null)
        
        if [ ! -z "$LAST_LOG_TIME" ]; then
            TIME_DIFF=$((CURRENT_TIME - LAST_LOG_TIME))
            echo "Last log entry was $TIME_DIFF seconds ago"
            
            # Writer should update every 10 seconds, so anything older than 30 seconds is concerning
            if [ $TIME_DIFF -lt 30 ]; then
                echo "✅ System Log Writer: ACTUALLY WORKING (recent activity)"
            else
                echo "❌ System Log Writer: LOADED BUT NOT WORKING (no recent activity)"
            fi
        else
            echo "❌ System Log Writer: LOADED BUT NOT WORKING (invalid timestamp format)"
        fi
    else
        echo "❌ System Log Writer: LOADED BUT NOT WORKING (empty log file)"
    fi
    
    # Check if reader is working by looking at reader service logs
    if [ -f "$REPO_PATH/logs/last-timestamp-reader.log" ]; then
        READER_LOG_MOD=$(stat -f "%m" "$REPO_PATH/logs/last-timestamp-reader.log" 2>/dev/null)
        if [ ! -z "$READER_LOG_MOD" ]; then
            READER_TIME_DIFF=$((CURRENT_TIME - READER_LOG_MOD))
            if [ $READER_TIME_DIFF -lt 30 ]; then
                echo "✅ Last Timestamp Reader: ACTUALLY WORKING (recent log activity)"
            else
                echo "❌ Last Timestamp Reader: LOADED BUT NOT WORKING (no recent log activity)"
            fi
        fi
    else
        echo "❌ Last Timestamp Reader: NO LOG FILE (not working)"
    fi
    
else
    echo "❌ System Log Writer: NOT WORKING (no log file created)"
    echo "❌ Last Timestamp Reader: NOT WORKING (no log file to read)"
fi

echo
echo "=== Error Logs ==="
if [ -f "$REPO_PATH/logs/system-log-writer-error.log" ] && [ -s "$REPO_PATH/logs/system-log-writer-error.log" ]; then
    echo "System Log Writer ERRORS found:"
    tail -n 3 "$REPO_PATH/logs/system-log-writer-error.log"
else
    echo "No System Log Writer errors"
fi

if [ -f "$REPO_PATH/logs/last-timestamp-reader-error.log" ] && [ -s "$REPO_PATH/logs/last-timestamp-reader-error.log" ]; then
    echo "Last Timestamp Reader ERRORS found:"
    tail -n 3 "$REPO_PATH/logs/last-timestamp-reader-error.log"
else
    echo "No Last Timestamp Reader errors"
fi
