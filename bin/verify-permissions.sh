#!/bin/bash
"""
Permission Verification Script
Verifies all file permissions are correctly set
"""

REPO_PATH="$HOME/Documents/25D/L2/Repo4"
ERRORS=0

echo "=== Permission Verification ==="

# Check executable permissions (should be 755)
for script in bin/*.py bin/*.sh; do
    if [ -f "$script" ]; then
        perms=$(stat -f "%Lp" "$script" 2>/dev/null || stat -c "%a" "$script" 2>/dev/null)
        if [ "$perms" != "755" ]; then
            echo "ERROR: $script has permissions $perms, should be 755"
            ((ERRORS++))
        else
            echo "OK: $script has correct permissions (755)"
        fi
    fi
done

# Check log file permissions (should be 644)
if [ -f "$REPO_PATH/logs/system-logs.log" ]; then
    perms=$(stat -f "%Lp" "$REPO_PATH/logs/system-logs.log" 2>/dev/null || stat -c "%a" "$REPO_PATH/logs/system-logs.log" 2>/dev/null)
    if [ "$perms" != "644" ]; then
        echo "ERROR: system-logs.log has permissions $perms, should be 644"
        ((ERRORS++))
    else
        echo "OK: system-logs.log has correct permissions (644)"
    fi
fi

# Check config file permissions (should be 644)
for config in config/*.service; do
    if [ -f "$config" ]; then
        perms=$(stat -f "%Lp" "$config" 2>/dev/null || stat -c "%a" "$config" 2>/dev/null)
        if [ "$perms" != "644" ]; then
            echo "ERROR: $config has permissions $perms, should be 644"
            ((ERRORS++))
        else
            echo "OK: $config has correct permissions (644)"
        fi
    fi
done

echo
if [ $ERRORS -eq 0 ]; then
    echo "All permissions are correct!"
    exit 0
else
    echo "Found $ERRORS permission errors!"
    exit 1
fi
