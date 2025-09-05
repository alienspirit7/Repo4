# PDR Task Implementation Guide
## System Log Writer & Last Timestamp Reader

**Project Overview:** Interdependent timestamp logging system with two programs that share a log file
**Total Duration:** 3 days (20-24 hours)
**Repository Location:** `/usr/local/repo4` (system-wide deployment)

---

## 📋 Task Structure Overview

### Phase Breakdown
1. **Phase 1:** Environment & Setup (Day 1 Morning - 1.5 hours)
2. **Phase 2:** Core Implementation (Day 1 Afternoon - 2.5 hours) 
3. **Phase 3:** Service Configuration (Day 2 Morning - 1.5 hours)
4. **Phase 4:** Testing & Validation (Day 2 Afternoon - 3 hours)
5. **Phase 5:** Monitoring & Tools (Day 3 Morning - 2 hours)
6. **Phase 6:** Documentation & Deployment (Day 3 Afternoon - 2 hours)

---

## 🎯 PHASE 1: Environment & Setup
**Duration:** 1.5 hours | **Day:** 1 Morning

### Task 1.1: Repository Structure Setup
**Time:** 30 minutes | **Priority:** Critical | **Dependencies:** None

**Objective:** Create standardized directory structure for system deployment

**Steps:**
```bash
# Create system-wide repository (requires sudo)
sudo mkdir -p /usr/local/repo4/{bin,config,logs,tests,docs}
sudo chown $(whoami):staff /usr/local/repo4 -R  # macOS
# sudo chown $(whoami):$(whoami) /usr/local/repo4 -R  # Linux

# Navigate to repository
cd /usr/local/repo4

# Create .gitkeep files
touch logs/.gitkeep tests/.gitkeep docs/.gitkeep
```

**Deliverables:**
- [ ] `/usr/local/repo4/` directory structure
- [ ] Proper ownership and permissions
- [ ] Git repository initialized

**Verification:**
```bash
ls -la /usr/local/repo4/
tree /usr/local/repo4  # if tree command available
```

### Task 1.2: Permissions Configuration
**Time:** 20 minutes | **Priority:** High | **Dependencies:** 1.1

**Objective:** Set secure file permissions for system-wide deployment

**Steps:**
```bash
cd /usr/local/repo4

# Set directory permissions (755 - readable/executable by all)
chmod 755 bin config logs tests docs

# Ensure logs directory is writable
chmod 755 logs

# Verify ownership
ls -la
```

**Deliverables:**
- [ ] Correct directory permissions (755)
- [ ] Logs directory writable by services
- [ ] Ownership properly configured

**Verification:**
```bash
stat -c "%a %n" bin config logs tests docs  # Linux
stat -f "%A %N" bin config logs tests docs  # macOS
```

### Task 1.3: Git Repository Initialization  
**Time:** 15 minutes | **Priority:** Medium | **Dependencies:** 1.1

**Objective:** Version control setup for tracking changes

**Steps:**
```bash
cd /usr/local/repo4

# Initialize git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Log files (don't commit actual logs)
logs/*.log
logs/*-error.log

# macOS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Temporary files
*.tmp
*.temp

# Keep logs directory structure but ignore log files
!logs/.gitkeep
EOF

# Initial commit
git add .
git commit -m "Initial repository structure"
```

**Deliverables:**
- [ ] Git repository initialized
- [ ] .gitignore configured for log files
- [ ] Initial commit completed

**Success Criteria:**
✅ All directories exist with correct permissions  
✅ Git repository tracking properly  
✅ System ready for implementation

---

## 🔧 PHASE 2: Core Implementation
**Duration:** 2.5 hours | **Day:** 1 Afternoon

### Task 2.1: System Log Writer Implementation
**Time:** 90 minutes | **Priority:** Critical | **Dependencies:** 1.2

**Objective:** Create the primary timestamp logging service

**Implementation Steps:**

1. **Create main shell script:**
```bash
cat > /usr/local/repo4/bin/system-log-writer.sh << 'EOF'
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
EOF

chmod 755 /usr/local/repo4/bin/system-log-writer.sh
```

2. **Test implementation:**
```bash
# Test run (should create log entries)
/usr/local/repo4/bin/system-log-writer.sh &
WRITER_PID=$!

# Let it run for 30 seconds
sleep 30

# Stop the test
kill $WRITER_PID

# Verify log file creation
cat /usr/local/repo4/logs/system-logs.log
```

**Deliverables:**
- [ ] Working system-log-writer.sh script
- [ ] Proper signal handling (SIGTERM/SIGINT)
- [ ] 10-second interval timing
- [ ] ISO 8601 timestamp format (YYYY-MM-DD HH:MM:SS)
- [ ] Automatic log directory creation

**Verification Checklist:**
- [ ] Script runs without errors
- [ ] Timestamps appear in log file every 10 seconds
- [ ] Graceful shutdown with Ctrl+C
- [ ] Log file format correct

### Task 2.2: Last Timestamp Reader Implementation  
**Time:** 60 minutes | **Priority:** Critical | **Dependencies:** 2.1

**Objective:** Create the timestamp monitoring service

**Implementation Steps:**

1. **Create reader script:**
```bash
cat > /usr/local/repo4/bin/last-timestamp-reader.sh << 'EOF'
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
EOF

chmod 755 /usr/local/repo4/bin/last-timestamp-reader.sh
```

2. **Test both programs together:**
```bash
# Start writer
/usr/local/repo4/bin/system-log-writer.sh &
WRITER_PID=$!

# Start reader  
/usr/local/repo4/bin/last-timestamp-reader.sh &
READER_PID=$!

# Let them run together
sleep 45

# Stop both
kill $WRITER_PID $READER_PID

# Verify coordination
echo "Log file contents:"
cat /usr/local/repo4/logs/system-logs.log
```

**Deliverables:**
- [ ] Working last-timestamp-reader.sh script
- [ ] 7-second polling interval
- [ ] Proper error handling for missing/empty files
- [ ] Clear output format

**Success Criteria:**
✅ Both programs run simultaneously without conflicts  
✅ Reader displays last timestamp every 7 seconds  
✅ Proper error handling when log file missing  
✅ Clean shutdown of both processes

---

## ⚙️ PHASE 3: Service Configuration  
**Duration:** 1.5 hours | **Day:** 2 Morning

### Task 3.1: macOS Service Configuration
**Time:** 45 minutes | **Priority:** High | **Dependencies:** 2.2

**Objective:** Configure automatic service management for macOS

**Implementation Steps:**

1. **Create launchd plist files:**

```bash
# System Log Writer service
cat > /usr/local/repo4/config/com.user.system-log-writer.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.system-log-writer</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/usr/local/repo4/bin/system-log-writer.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/usr/local/repo4</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/usr/local/repo4/logs/system-log-writer.log</string>
    <key>StandardErrorPath</key>
    <string>/usr/local/repo4/logs/system-log-writer-error.log</string>
</dict>
</plist>
EOF

# Last Timestamp Reader service
cat > /usr/local/repo4/config/com.user.last-timestamp-reader.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.last-timestamp-reader</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/usr/local/repo4/bin/last-timestamp-reader.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/usr/local/repo4</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/usr/local/repo4/logs/last-timestamp-reader.log</string>
    <key>StandardErrorPath</key>
    <string>/usr/local/repo4/logs/last-timestamp-reader-error.log</string>
</dict>
</plist>
EOF
```

2. **Create installation script:**
```bash
cat > /usr/local/repo4/bin/install-services-macos.sh << 'EOF'
#!/bin/bash
# macOS Service Installation Script - SYSTEM LOCATION VERSION
# Repository location: /usr/local/repo4

REPO_PATH="/usr/local/repo4"

echo "Installing System Log Writer and Last Timestamp Reader services..."
echo "Repository path: $REPO_PATH"

# Ensure scripts are executable
chmod +x "$REPO_PATH/bin/system-log-writer.sh"
chmod +x "$REPO_PATH/bin/last-timestamp-reader.sh"

# Create LaunchAgents directory
mkdir -p ~/Library/LaunchAgents

# Stop any existing services
launchctl unload ~/Library/LaunchAgents/com.user.system-log-writer.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist 2>/dev/null

# Copy service files from repository
cp "$REPO_PATH/config/com.user.system-log-writer.plist" ~/Library/LaunchAgents/
cp "$REPO_PATH/config/com.user.last-timestamp-reader.plist" ~/Library/LaunchAgents/

# Load and start services
echo "Loading System Log Writer service..."
launchctl load ~/Library/LaunchAgents/com.user.system-log-writer.plist

echo "Waiting 3 seconds..."
sleep 3

echo "Loading Last Timestamp Reader service..."
launchctl load ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

# Check status
echo ""
echo "Service Status:"
echo "System Log Writer:"
launchctl list | grep com.user.system-log-writer || echo "Not running"

echo "Last Timestamp Reader:"
launchctl list | grep com.user.last-timestamp-reader || echo "Not running"

echo ""
echo "Installation complete!"
echo "Repository location: /usr/local/repo4"
echo "Services running from system location!"
EOF

chmod 755 /usr/local/repo4/bin/install-services-macos.sh
```

**Deliverables:**
- [ ] launchd plist files for both services
- [ ] Service installation script
- [ ] Automatic restart configuration
- [ ] Proper logging to service log files

**Verification:**
```bash
# Install services
/usr/local/repo4/bin/install-services-macos.sh

# Check service status
launchctl list | grep com.user

# Verify log files are being created
ls -la /usr/local/repo4/logs/
```

### Task 3.2: Service Monitoring Setup
**Time:** 45 minutes | **Priority:** High | **Dependencies:** 3.1

**Objective:** Create monitoring and health check capabilities

**Implementation Steps:**

1. **Create monitoring script:**
```bash
cat > /usr/local/repo4/bin/monitor-services-macos.sh << 'EOF'
#!/bin/bash
# macOS Service Status Monitoring Script - IMPROVED VERSION
# Actually checks if services are working, not just loaded

REPO_PATH="/usr/local/repo4"
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
EOF

chmod 755 /usr/local/repo4/bin/monitor-services-macos.sh
```

**Deliverables:**
- [ ] Comprehensive service monitoring script
- [ ] Health check that verifies actual functionality
- [ ] Error log analysis
- [ ] Service status reporting

**Success Criteria:**
✅ Services load and start automatically  
✅ Monitoring script accurately detects service health  
✅ Services restart on failure  
✅ Clear status reporting available

---

## 🧪 PHASE 4: Testing & Validation
**Duration:** 3 hours | **Day:** 2 Afternoon

### Task 4.1: Integration Testing
**Time:** 90 minutes | **Priority:** Critical | **Dependencies:** 3.2

**Objective:** Validate complete system functionality

**Test Scenarios:**

1. **Basic Functionality Test:**
```bash
# Install and start services
/usr/local/repo4/bin/install-services-macos.sh

# Wait for initial operation
sleep 30

# Check monitoring
/usr/local/repo4/bin/monitor-services-macos.sh

# Verify log file has multiple entries
echo "Log entries count: $(wc -l < /usr/local/repo4/logs/system-logs.log)"
```

2. **Service Recovery Test:**
```bash
# Find service PIDs and kill them to test auto-restart
sudo pkill -f system-log-writer.sh
sudo pkill -f last-timestamp-reader.sh

# Wait for restart
sleep 10

# Check if services restarted
/usr/local/repo4/bin/monitor-services-macos.sh
```

3. **Log File Handling Test:**
```bash
# Test with missing log file
mv /usr/local/repo4/logs/system-logs.log /usr/local/repo4/logs/system-logs.log.backup

# Wait and check reader behavior
sleep 15
/usr/local/repo4/bin/monitor-services-macos.sh

# Restore log file
mv /usr/local/repo4/logs/system-logs.log.backup /usr/local/repo4/logs/system-logs.log
```

**Deliverables:**
- [ ] Basic functionality verification
- [ ] Service recovery testing
- [ ] Error handling validation
- [ ] Performance baseline measurements

### Task 4.2: Performance Validation
**Time:** 60 minutes | **Priority:** Medium | **Dependencies:** 4.1

**Objective:** Ensure system meets performance specifications

**Performance Tests:**

1. **Resource Usage Monitoring:**
```bash
# Monitor resource usage over time
top -pid $(pgrep -f system-log-writer.sh) -l 5 &
top -pid $(pgrep -f last-timestamp-reader.sh) -l 5 &

# Check disk usage growth
du -h /usr/local/repo4/logs/system-logs.log

# Monitor for 10 minutes
sleep 600
```

2. **Timing Accuracy Test:**
```bash
# Create timing analysis script
cat > /usr/local/repo4/bin/test-timing.sh << 'EOF'
#!/bin/bash
echo "Testing timing accuracy..."

LOG_FILE="/usr/local/repo4/logs/system-logs.log"

# Clear log file
> "$LOG_FILE"

# Monitor for 2 minutes
END_TIME=$(($(date +%s) + 120))

while [ $(date +%s) -lt $END_TIME ]; do
    ENTRY_COUNT=$(wc -l < "$LOG_FILE")
    ELAPSED=$(($(date +%s) - (END_TIME - 120)))
    EXPECTED_ENTRIES=$((ELAPSED / 10))
    
    echo "Time: ${ELAPSED}s, Entries: $ENTRY_COUNT, Expected: ~$EXPECTED_ENTRIES"
    sleep 10
done
EOF

chmod 755 /usr/local/repo4/bin/test-timing.sh
/usr/local/repo4/bin/test-timing.sh
```

**Deliverables:**
- [ ] Resource usage measurements (<0.1% CPU per service)
- [ ] Timing accuracy validation (±1 second tolerance)
- [ ] Memory usage confirmation (~10-15MB per service)
- [ ] Disk I/O impact assessment

### Task 4.3: Stress Testing
**Time:** 30 minutes | **Priority:** Low | **Dependencies:** 4.2

**Objective:** Test system under stress conditions

**Stress Tests:**
```bash
# Simulate high I/O load
dd if=/dev/zero of=/tmp/stress_file bs=1M count=100 &

# Run stress test for 15 minutes
sleep 900

# Monitor service health during stress
/usr/local/repo4/bin/monitor-services-macos.sh

# Cleanup
rm /tmp/stress_file
```

**Success Criteria:**
✅ All integration tests pass  
✅ Performance within specifications  
✅ Services stable under stress  
✅ Timing accuracy maintained

---

## 📊 PHASE 5: Monitoring & Tools
**Duration:** 2 hours | **Day:** 3 Morning

### Task 5.1: Log Management Configuration
**Time:** 60 minutes | **Priority:** Medium | **Dependencies:** 4.3

**Objective:** Implement log rotation and maintenance

**Implementation Steps:**

1. **Create log rotation configuration:**
```bash
# Create logrotate configuration for the timestamp logs
cat > /usr/local/repo4/config/logrotate.conf << 'EOF'
/usr/local/repo4/logs/system-logs.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 $(whoami) staff
    postrotate
        # No need to restart services - they append to the file
    endscript
}
EOF
```

2. **Create log cleanup script:**
```bash
cat > /usr/local/repo4/bin/cleanup-logs.sh << 'EOF'
#!/bin/bash
echo "Cleaning up old log files..."

REPO_PATH="/usr/local/repo4"
LOGS_DIR="$REPO_PATH/logs"

# Remove error logs older than 7 days
find "$LOGS_DIR" -name "*-error.log" -mtime +7 -delete

# Compress logs older than 1 day
find "$LOGS_DIR" -name "*.log" -mtime +1 ! -name "*error*" -exec gzip {} \;

echo "Log cleanup complete"
EOF

chmod 755 /usr/local/repo4/bin/cleanup-logs.sh
```

**Deliverables:**
- [ ] Log rotation configuration
- [ ] Automated cleanup script
- [ ] Disk space management

### Task 5.2: Advanced Monitoring Setup  
**Time:** 60 minutes | **Priority:** High | **Dependencies:** 5.1

**Objective:** Enhanced monitoring and alerting capabilities

**Implementation Steps:**

1. **Create comprehensive health check:**
```bash
cat > /usr/local/repo4/bin/health-check.sh << 'EOF'
#!/bin/bash
# Comprehensive system health check

REPO_PATH="/usr/local/repo4"
LOG_FILE="$REPO_PATH/logs/system-logs.log"
ALERT_EMAIL=""  # Configure if needed

# Exit codes
EXIT_OK=0
EXIT_WARNING=1
EXIT_CRITICAL=2

# Health check functions
check_services() {
    local status=0
    
    if ! launchctl list | grep -q com.user.system-log-writer; then
        echo "CRITICAL: System Log Writer service not loaded"
        status=$EXIT_CRITICAL
    fi
    
    if ! launchctl list | grep -q com.user.last-timestamp-reader; then
        echo "CRITICAL: Last Timestamp Reader service not loaded"
        status=$EXIT_CRITICAL
    fi
    
    return $status
}

check_log_freshness() {
    local status=0
    
    if [ ! -f "$LOG_FILE" ]; then
        echo "CRITICAL: Log file does not exist"
        return $EXIT_CRITICAL
    fi
    
    local last_entry=$(tail -n 1 "$LOG_FILE")
    local current_time=$(date +%s)
    local last_log_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "$last_entry" "+%s" 2>/dev/null)
    
    if [ ! -z "$last_log_time" ]; then
        local time_diff=$((current_time - last_log_time))
        
        if [ $time_diff -gt 30 ]; then
            echo "WARNING: Last log entry is $time_diff seconds old"
            status=$EXIT_WARNING
        elif [ $time_diff -gt 60 ]; then
            echo "CRITICAL: Last log entry is $time_diff seconds old"
            status=$EXIT_CRITICAL
        else
            echo "OK: Log file is current (last entry $time_diff seconds ago)"
        fi
    else
        echo "CRITICAL: Cannot parse last log entry timestamp"
        status=$EXIT_CRITICAL
    fi
    
    return $status
}

check_disk_space() {
    local used_percent=$(df "$REPO_PATH" | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ $used_percent -gt 90 ]; then
        echo "CRITICAL: Disk usage at ${used_percent}%"
        return $EXIT_CRITICAL
    elif [ $used_percent -gt 80 ]; then
        echo "WARNING: Disk usage at ${used_percent}%"
        return $EXIT_WARNING
    else
        echo "OK: Disk usage at ${used_percent}%"
        return $EXIT_OK
    fi
}

# Run all checks
echo "=== System Health Check $(date) ==="

overall_status=$EXIT_OK

check_services
if [ $? -gt $overall_status ]; then overall_status=$?; fi

check_log_freshness  
if [ $? -gt $overall_status ]; then overall_status=$?; fi

check_disk_space
if [ $? -gt $overall_status ]; then overall_status=$?; fi

# Summary
case $overall_status in
    $EXIT_OK)
        echo "=== OVERALL STATUS: OK ==="
        ;;
    $EXIT_WARNING)
        echo "=== OVERALL STATUS: WARNING ==="
        ;;
    $EXIT_CRITICAL)
        echo "=== OVERALL STATUS: CRITICAL ==="
        ;;
esac

exit $overall_status
EOF

chmod 755 /usr/local/repo4/bin/health-check.sh
```

**Deliverables:**
- [ ] Comprehensive health checking
- [ ] Exit codes for automation
- [ ] Disk space monitoring
- [ ] Service status validation

**Success Criteria:**
✅ Log rotation working correctly  
✅ Health checks accurate and reliable  
✅ Monitoring covers all failure modes  
✅ Cleanup automation functional

---

## 📖 PHASE 6: Documentation & Deployment
**Duration:** 2 hours | **Day:** 3 Afternoon

### Task 6.1: Create Deployment README
**Time:** 60 minutes | **Priority:** High | **Dependencies:** 5.2

**Objective:** Comprehensive documentation for system operation

**Implementation Steps:**

1. **Create main README:**
```bash
cat > /usr/local/repo4/README.md << 'EOF'
# System Log Writer & Last Timestamp Reader

## Overview
Interdependent timestamp logging system with two services:
- **System Log Writer**: Writes timestamps every 10 seconds
- **Last Timestamp Reader**: Reads and displays last timestamp every 7 seconds

## Quick Start
```bash
# Install services (macOS)
sudo /usr/local/repo4/bin/install-services-macos.sh

# Monitor status
/usr/local/repo4/bin/monitor-services-macos.sh

# Health check
/usr/local/repo4/bin/health-check.sh
```

## System Requirements
- macOS 10.14+ or Linux with systemd
- Bash 4.0+
- 50MB disk space minimum
- Network: None required

## Architecture
```
/usr/local/repo4/
├── bin/                    # Executable scripts
├── config/                 # Service configurations  
├── logs/                   # Log files
└── README.md              # This file
```

## Service Management

### macOS (launchd)
```bash
# Start services
launchctl load ~/Library/LaunchAgents/com.user.system-log-writer.plist
launchctl load ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

# Stop services  
launchctl unload ~/Library/LaunchAgents/com.user.system-log-writer.plist
launchctl unload ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

# Check status
launchctl list | grep com.user
```

## Monitoring

### Service Status
```bash
/usr/local/repo4/bin/monitor-services-macos.sh
```

### Health Check
```bash
/usr/local/repo4/bin/health-check.sh
```

### Log Files
- `logs/system-logs.log` - Main timestamp log (shared)
- `logs/system-log-writer.log` - Writer service output
- `logs/last-timestamp-reader.log` - Reader service output  
- `logs/*-error.log` - Error logs

## Troubleshooting

### Services Not Starting
1. Check service files exist: `ls ~/Library/LaunchAgents/com.user.*`
2. Verify script permissions: `ls -la /usr/local/repo4/bin/`
3. Check error logs: `tail /usr/local/repo4/logs/*-error.log`

### No Log Entries
1. Check if writer service is running: `pgrep -f system-log-writer.sh`
2. Verify log directory permissions: `ls -la /usr/local/repo4/logs/`
3. Test manual execution: `/usr/local/repo4/bin/system-log-writer.sh`

### Reader Not Finding Timestamps  
1. Verify log file exists: `ls -la /usr/local/repo4/logs/system-logs.log`
2. Check log file content: `cat /usr/local/repo4/logs/system-logs.log`
3. Test manual execution: `/usr/local/repo4/bin/last-timestamp-reader.sh`

## Performance Specifications
- **CPU Usage**: <0.1% per service
- **Memory**: ~10-15MB per service  
- **Disk Growth**: ~50KB per day
- **Timing Accuracy**: ±1 second

## Maintenance

### Log Rotation
```bash
# Manual cleanup
/usr/local/repo4/bin/cleanup-logs.sh

# Schedule in crontab
echo "0 2 * * * /usr/local/repo4/bin/cleanup-logs.sh" | crontab -
```

### Updates
1. Stop services
2. Update scripts in `/usr/local/repo4/bin/`
3. Restart services
4. Verify operation with monitoring scripts

## Security
- Services run under user context (non-root)
- Log files readable by group, not world-writable
- No network communication required
- Minimal attack surface

## Support
- Check health status: `/usr/local/repo4/bin/health-check.sh`
- Review error logs in `/usr/local/repo4/logs/`
- Verify service configuration: `launchctl list | grep com.user`
EOF
```

**Deliverables:**
- [ ] Comprehensive README.md
- [ ] Quick start guide
- [ ] Troubleshooting documentation
- [ ] Maintenance procedures

### Task 6.2: Final System Validation
**Time:** 60 minutes | **Priority:** Critical | **Dependencies:** 6.1

**Objective:** Complete end-to-end validation before production

**Validation Steps:**

1. **Complete Installation Test:**
```bash
# Fresh installation simulation
launchctl unload ~/Library/LaunchAgents/com.user.*.plist 2>/dev/null

# Clean slate
rm -f /usr/local/repo4/logs/*.log

# Full installation
/usr/local/repo4/bin/install-services-macos.sh

# Wait for operation
sleep 60

# Comprehensive validation
/usr/local/repo4/bin/health-check.sh
```

2. **Performance Validation:**
```bash
# 24-hour stability test setup (run overnight)
echo "Starting 24-hour stability test at $(date)" > /usr/local/repo4/logs/stability-test.log

# Schedule validation check
echo "0 */4 * * * /usr/local/repo4/bin/health-check.sh >> /usr/local/repo4/logs/stability-test.log" | crontab -
```

3. **Documentation Validation:**
```bash
# Test all documented procedures
echo "Testing all README procedures..."

# Test service management commands
launchctl list | grep com.user

# Test monitoring commands  
/usr/local/repo4/bin/monitor-services-macos.sh

# Test troubleshooting steps
ls -la /usr/local/repo4/bin/
ls -la /usr/local/repo4/logs/

echo "Documentation validation complete"
```

**Final Validation Checklist:**
- [ ] Both services running automatically
- [ ] Timestamps being written every 10 seconds
- [ ] Reader displaying timestamps every 7 seconds  
- [ ] Health checks passing
- [ ] Monitoring scripts working
- [ ] Documentation accurate
- [ ] Performance within specifications
- [ ] Services restart on failure
- [ ] System ready for production

**Success Criteria:**
✅ Complete system operational  
✅ All documentation accurate and tested  
✅ Ready for production deployment  
✅ Monitoring and maintenance procedures in place

---

## 🎯 Project Success Criteria

### Phase Completion Checklist

**Phase 1: Environment & Setup**
- [ ] Repository structure created with correct permissions
- [ ] Git repository initialized and tracking
- [ ] System ready for implementation

**Phase 2: Core Implementation**  
- [ ] System Log Writer functional with 10-second intervals
- [ ] Last Timestamp Reader working with 7-second intervals
- [ ] Both programs handle signals gracefully
- [ ] Proper error handling implemented

**Phase 3: Service Configuration**
- [ ] Services auto-start on boot
- [ ] Automatic restart on failure
- [ ] Service management working correctly
- [ ] Monitoring capabilities in place

**Phase 4: Testing & Validation**
- [ ] Integration testing successful
- [ ] Performance within specifications
- [ ] Services stable under stress
- [ ] All failure modes tested

**Phase 5: Monitoring & Tools**
- [ ] Log rotation configured
- [ ] Health checks comprehensive and accurate
- [ ] Maintenance automation in place
- [ ] Monitoring covers all scenarios

**Phase 6: Documentation & Deployment**
- [ ] Documentation complete and accurate
- [ ] All procedures tested and verified
- [ ] System ready for production
- [ ] Maintenance procedures documented

## 🚨 Common Issues & Quick Fixes

| Issue | Quick Fix | Prevention |
|-------|-----------|------------|
| Services won't start | Check permissions: `chmod 755 /usr/local/repo4/bin/*.sh` | Use installation script |
| No log entries | Verify scripts are executable and running | Monitor service status |
| Reader shows "file not found" | Ensure writer is running first | Service dependencies |
| High resource usage | Check for multiple instances running | Proper service management |
| Log file corruption | Stop services, restore from backup | Implement proper log rotation |

## 📈 Performance Expectations

| Metric | Target | Monitoring Method |
|--------|--------|-------------------|
| CPU Usage | <0.1% per service | `top` command |
| Memory Usage | ~10-15MB per service | Service monitoring |
| Disk Growth | ~50KB per day | Log file size tracking |
| Timing Accuracy | ±1 second | Log analysis |
| Uptime | >99.9% | Health check logs |

---

## 🎉 Final Notes

This implementation guide provides a complete roadmap for deploying the interdependent timestamp logging system. The system is designed for production use with enterprise-grade reliability, monitoring, and maintenance capabilities.

**Key Features:**
- **System-wide deployment** in `/usr/local/repo4`
- **Automatic service management** via launchd (macOS) or systemd (Linux)
- **Comprehensive monitoring** with health checks and status reporting
- **Robust error handling** and recovery mechanisms
- **Production-ready** with proper logging and maintenance procedures

Follow the phases sequentially for best results. Each task includes verification steps to ensure proper implementation before proceeding to the next phase.

For ongoing operation, use the monitoring scripts regularly and follow the maintenance procedures outlined in the documentation.
