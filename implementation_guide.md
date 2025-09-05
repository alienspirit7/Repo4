# Implementation Guide: System Log Writer & Last Timestamp Reader

**Project:** Interdependent Timestamp Logging System  
**Based on:** PDR v1.0  
**Implementation Time:** 2-3 days for complete system  

## 📋 Task Overview

This guide breaks down the PDR into actionable tasks for implementing the complete timestamp logging system. Each task includes clear deliverables, dependencies, and verification steps.

## 🎯 Phase 1: Project Setup & Environment (Day 1 Morning)

### Task 1.1: Repository Structure Creation
**Duration:** 30 minutes  
**Dependencies:** None  
**Priority:** High

**Deliverables:**
- Complete directory structure
- Initial configuration files
- Basic documentation framework

**Steps:**
```bash
# Create main repository directory
mkdir -p ~/Documents/25D/L2/Repo4
cd ~/Documents/25D/L2/Repo4

# Create directory structure
mkdir -p bin config logs tests docs

# Create placeholder files
touch bin/.gitkeep config/.gitkeep logs/.gitkeep tests/.gitkeep docs/.gitkeep
```

**Verification:**
```bash
tree ~/Documents/25D/L2/Repo4
```

### Task 1.2: Environment Setup
**Duration:** 20 minutes  
**Dependencies:** Task 1.1  
**Priority:** High

**Deliverables:**
- Python virtual environment
- Testing framework installation
- Development dependencies

**Steps:**
```bash
cd ~/Documents/25D/L2/Repo4

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install development dependencies
pip install pytest

# Create requirements file
echo "pytest>=6.0" > requirements-dev.txt
```

**Verification:**
```bash
which python3
pip list
```

### Task 1.3: Git Repository Initialization
**Duration:** 15 minutes  
**Dependencies:** Task 1.1  
**Priority:** Medium

**Deliverables:**
- Git repository with proper .gitignore
- Initial commit with structure

**Steps:**
```bash
cd ~/Documents/25D/L2/Repo4

# Initialize git repository
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
*.pyc
__pycache__/
*.pyo
*.pyd
.Python
venv/
env/

# Logs (optional - you might want to include sample logs)
logs/*.log
logs/*-error.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Temporary files
*.tmp
*.temp
EOF

# Initial commit
git add .
git commit -m "Initial project structure"
```

**Verification:**
```bash
git status
git log --oneline
```

## 🔧 Phase 2: Core Program Implementation (Day 1 Afternoon)

### Task 2.1: System Log Writer Implementation
**Duration:** 1.5 hours  
**Dependencies:** Task 1.2  
**Priority:** High

**Deliverables:**
- Complete Python implementation of system-log-writer.py
- Shell script alternative
- Signal handling and error management

**Steps:**

1. **Create main Python implementation:**
```python
# bin/system-log-writer.py
#!/usr/bin/env python3
"""
System Log Writer - Program A
Writes current system time to log file every 10 seconds
"""

import time
import datetime
import os
import signal
import sys
import logging

class SystemLogWriter:
    def __init__(self):
        # Set log file path relative to repository
        repo_path = os.path.expanduser("~/Documents/25D/L2/Repo4")
        self.log_file_path = os.path.join(repo_path, "logs", "system-logs.log")
        self.running = True
        self.interval = 10
        
        # Ensure logs directory exists
        os.makedirs(os.path.dirname(self.log_file_path), exist_ok=True)
        
        # Set up logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
    def signal_handler(self, signum, frame):
        """Handle shutdown signals gracefully"""
        self.logger.info(f"Received signal {signum}, shutting down...")
        self.running = False
        
    def write_timestamp(self):
        """Write current timestamp to log file"""
        try:
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            with open(self.log_file_path, 'a') as f:
                f.write(f"{timestamp}\n")
                f.flush()
            self.logger.debug(f"Wrote timestamp: {timestamp}")
        except Exception as e:
            self.logger.error(f"Error writing timestamp: {e}")
            
    def run(self):
        """Main daemon loop"""
        self.logger.info("System Log Writer starting...")
        
        # Register signal handlers
        signal.signal(signal.SIGTERM, self.signal_handler)
        signal.signal(signal.SIGINT, self.signal_handler)
        
        try:
            while self.running:
                self.write_timestamp()
                time.sleep(self.interval)
        except Exception as e:
            self.logger.error(f"Unexpected error: {e}")
        finally:
            self.logger.info("System Log Writer stopped.")

if __name__ == "__main__":
    writer = SystemLogWriter()
    writer.run()
```

2. **Make executable:**
```bash
chmod 755 bin/system-log-writer.py
```

3. **Create shell script alternative:**
```bash
# bin/system-log-writer.sh
#!/bin/bash
"""
System Log Writer - Shell Script Alternative
Writes current system time to log file every 10 seconds
"""

REPO_PATH="$HOME/Documents/25D/L2/Repo4"
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
```

4. **Make executable:**
```bash
chmod 755 bin/system-log-writer.sh
```

**Verification:**
```bash
# Test Python version
python3 bin/system-log-writer.py &
WRITER_PID=$!
sleep 15
kill $WRITER_PID

# Check log file was created and has entries
cat logs/system-logs.log
```

### Task 2.2: Last Timestamp Reader Implementation
**Duration:** 1 hour  
**Dependencies:** Task 2.1  
**Priority:** High

**Deliverables:**
- Complete Python implementation of last-timestamp-reader.py
- Shell script alternative
- Error handling for various file states

**Steps:**

1. **Create main Python implementation:**
```python
# bin/last-timestamp-reader.py
#!/usr/bin/env python3
"""
Last Timestamp Reader - Program B
Reads last timestamp from log file every 7 seconds
"""

import time
import os
import sys
import signal
import logging

class LastTimestampReader:
    def __init__(self):
        # Set log file path relative to repository
        repo_path = os.path.expanduser("~/Documents/25D/L2/Repo4")
        self.log_file_path = os.path.join(repo_path, "logs", "system-logs.log")
        self.running = True
        self.interval = 7
        
        # Set up logging
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger(__name__)
        
    def signal_handler(self, signum, frame):
        """Handle shutdown signals gracefully"""
        self.logger.info(f"Received signal {signum}, shutting down...")
        self.running = False
        
    def read_last_timestamp(self):
        """Read last timestamp from log file"""
        try:
            if not os.path.exists(self.log_file_path):
                return "Log file not found"
                
            if os.path.getsize(self.log_file_path) == 0:
                return "Log file is empty"
                
            with open(self.log_file_path, 'r') as f:
                lines = f.readlines()
                if lines:
                    last_line = lines[-1].strip()
                    return last_line if last_line else "Empty last line"
                else:
                    return "No lines in file"
                    
        except PermissionError:
            return "Permission denied reading log file"
        except Exception as e:
            return f"Error reading log file: {e}"
            
    def run(self):
        """Main daemon loop"""
        self.logger.info("Last Timestamp Reader starting...")
        
        # Register signal handlers
        signal.signal(signal.SIGTERM, self.signal_handler)
        signal.signal(signal.SIGINT, self.signal_handler)
        
        try:
            while self.running:
                last_timestamp = self.read_last_timestamp()
                print(f"Last timestamp: {last_timestamp}")
                time.sleep(self.interval)
        except Exception as e:
            self.logger.error(f"Unexpected error: {e}")
        finally:
            self.logger.info("Last Timestamp Reader stopped.")

if __name__ == "__main__":
    reader = LastTimestampReader()
    reader.run()
```

2. **Make executable and create shell alternative:**
```bash
chmod 755 bin/last-timestamp-reader.py

# Create shell script alternative (similar pattern as writer)
chmod 755 bin/last-timestamp-reader.sh
```

**Verification:**
```bash
# Test both programs together
python3 bin/system-log-writer.py &
WRITER_PID=$!

python3 bin/last-timestamp-reader.py &
READER_PID=$!

# Let them run for 30 seconds
sleep 30

# Stop both
kill $WRITER_PID $READER_PID

# Check results
cat logs/system-logs.log
```

## ⚙️ Phase 3: Service Configuration (Day 2 Morning)

### Task 3.1: macOS Service Configuration
**Duration:** 45 minutes  
**Dependencies:** Task 2.2  
**Priority:** High (if deploying on macOS)

**Deliverables:**
- launchd plist files for both services
- Service installation script

**Steps:**

1. **Create writer service plist:**
```xml
<!-- config/com.user.system-log-writer.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.system-log-writer</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/$(whoami)/Documents/25D/L2/Repo4/venv/bin/python3</string>
        <string>/Users/$(whoami)/Documents/25D/L2/Repo4/bin/system-log-writer.py</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/$(whoami)/Documents/25D/L2/Repo4</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/$(whoami)/Documents/25D/L2/Repo4/logs/system-log-writer.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/$(whoami)/Documents/25D/L2/Repo4/logs/system-log-writer-error.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/Users/$(whoami)/Documents/25D/L2/Repo4/venv/bin:/usr/bin:/bin</string>
    </dict>
</dict>
</plist>
```

2. **Create reader service plist (similar structure)**

3. **Create installation script:**
```bash
# bin/install-services-macos.sh
#!/bin/bash
echo "Installing System Log Writer and Last Timestamp Reader services for macOS..."

# Copy plist files to LaunchAgents
mkdir -p ~/Library/LaunchAgents
cp config/com.user.system-log-writer.plist ~/Library/LaunchAgents/
cp config/com.user.last-timestamp-reader.plist ~/Library/LaunchAgents/

# Load and start services
launchctl load ~/Library/LaunchAgents/com.user.system-log-writer.plist
sleep 3
launchctl load ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

echo "Installation complete!"
```

**Verification:**
```bash
./bin/install-services-macos.sh
launchctl list | grep com.user
```

### Task 3.2: Linux Service Configuration
**Duration:** 45 minutes  
**Dependencies:** Task 2.2  
**Priority:** High (if deploying on Linux)

**Deliverables:**
- systemd service files for both services
- Service installation script

**Steps:**

1. **Create writer service file:**
```ini
# config/system-log-writer.service
[Unit]
Description=System Log Writer Service
After=multi-user.target

[Service]
Type=simple
ExecStart=%h/Documents/25D/L2/Repo4/bin/system-log-writer.py
WorkingDirectory=%h/Documents/25D/L2/Repo4
Restart=always
RestartSec=5
User=%i
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

2. **Create reader service file (similar structure with dependency)**

3. **Create installation script:**
```bash
# bin/install-services.sh
#!/bin/bash
echo "Installing System Log Writer and Last Timestamp Reader services..."

# Copy service files
mkdir -p ~/.config/systemd/user
cp config/system-log-writer.service ~/.config/systemd/user/
cp config/last-timestamp-reader.service ~/.config/systemd/user/

# Enable and start services
systemctl --user daemon-reload
systemctl --user enable system-log-writer.service
systemctl --user enable last-timestamp-reader.service
systemctl --user start system-log-writer.service
sleep 2
systemctl --user start last-timestamp-reader.service

echo "Installation complete!"
```

**Verification:**
```bash
./bin/install-services.sh
systemctl --user status system-log-writer.service
```

## 🧪 Phase 4: Testing Implementation (Day 2 Afternoon)

### Task 4.1: Unit Test Development
**Duration:** 2 hours  
**Dependencies:** Task 2.2  
**Priority:** High

**Deliverables:**
- Complete unit test suite for both programs
- Test automation framework
- Code coverage reporting

**Steps:**

1. **Create writer unit tests:**
```python
# tests/test_system_log_writer.py
#!/usr/bin/env python3
"""
Unit tests for System Log Writer
"""

import unittest
import tempfile
import os
import sys
import datetime

# Add bin directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'bin'))

class TestSystemLogWriter(unittest.TestCase):
    
    def setUp(self):
        """Set up test environment"""
        self.test_dir = tempfile.mkdtemp()
        self.log_file = os.path.join(self.test_dir, "test-logs.log")
        
    def tearDown(self):
        """Clean up test environment"""
        if os.path.exists(self.log_file):
            os.remove(self.log_file)
        os.rmdir(self.test_dir)
        
    def test_timestamp_format(self):
        """Test timestamp format compliance"""
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.assertRegex(timestamp, r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')
        
    def test_file_creation(self):
        """Test log file creation"""
        self.assertFalse(os.path.exists(self.log_file))
        
        with open(self.log_file, 'w') as f:
            f.write("test\n")
            
        self.assertTrue(os.path.exists(self.log_file))
        
    def test_file_append(self):
        """Test that timestamps are appended to log file"""
        # Implementation continues...

if __name__ == '__main__':
    unittest.main()
```

2. **Create reader unit tests (similar structure)**

3. **Create test runner script:**
```bash
# bin/run-tests.sh
#!/bin/bash
echo "Running unit tests..."

cd ~/Documents/25D/L2/Repo4
source venv/bin/activate

# Run tests with verbose output
python3 -m unittest discover tests/ -v

# Or with pytest if available
python3 -m pytest tests/ -v
```

**Verification:**
```bash
chmod 755 bin/run-tests.sh
./bin/run-tests.sh
```

### Task 4.2: Integration Testing
**Duration:** 1 hour  
**Dependencies:** Task 4.1  
**Priority:** Medium

**Deliverables:**
- Integration test scenarios
- Service coordination tests
- End-to-end validation

**Steps:**

1. **Create integration test script:**
```bash
# bin/test-integration.sh
#!/bin/bash
echo "Running integration tests..."

# Start both programs
python3 bin/system-log-writer.py &
WRITER_PID=$!

python3 bin/last-timestamp-reader.py &
READER_PID=$!

# Test for 30 seconds
sleep 30

# Verify log file has multiple entries
ENTRY_COUNT=$(wc -l < logs/system-logs.log)
if [ $ENTRY_COUNT -ge 3 ]; then
    echo "✅ Integration test PASSED: $ENTRY_COUNT entries found"
else
    echo "❌ Integration test FAILED: Only $ENTRY_COUNT entries found"
fi

# Clean up
kill $WRITER_PID $READER_PID
```

**Verification:**
```bash
chmod 755 bin/test-integration.sh
./bin/test-integration.sh
```

## 📊 Phase 5: Monitoring & Management Tools (Day 3 Morning)

### Task 5.1: Service Monitoring Implementation
**Duration:** 1.5 hours  
**Dependencies:** Task 3.1 or 3.2  
**Priority:** High

**Deliverables:**
- Comprehensive service monitoring script
- Health check automation
- Status reporting

**Steps:**

1. **Create macOS monitoring script:**
```bash
# bin/monitor-services-macos.sh
#!/bin/bash
echo "=== macOS Service Status Check ==="
echo "Timestamp: $(date)"

REPO_PATH="$HOME/Documents/25D/L2/Repo4"
LOG_FILE="$REPO_PATH/logs/system-logs.log"

# Check service load status
echo "System Log Writer Service:"
if launchctl list | grep -q com.user.system-log-writer; then
    echo "LOADED by launchctl"
    launchctl list | grep com.user.system-log-writer
else
    echo "NOT LOADED"
fi

# Health check implementation
CURRENT_TIME=$(date +%s)

if [ -f "$LOG_FILE" ]; then
    LAST_ENTRY=$(tail -n 1 "$LOG_FILE")
    echo "Last log entry: $LAST_ENTRY"
    
    if [ ! -z "$LAST_ENTRY" ]; then
        LAST_LOG_TIME=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_ENTRY" "+%s" 2>/dev/null)
        
        if [ ! -z "$LAST_LOG_TIME" ]; then
            TIME_DIFF=$((CURRENT_TIME - LAST_LOG_TIME))
            echo "Last log entry was $TIME_DIFF seconds ago"
            
            if [ $TIME_DIFF -lt 30 ]; then
                echo "✅ System Log Writer: ACTUALLY WORKING"
            else
                echo "❌ System Log Writer: NOT WORKING (stale)"
            fi
        fi
    fi
fi
```

2. **Create permission verification script:**
```bash
# bin/verify-permissions.sh
#!/bin/bash
echo "=== Permission Verification ==="

REPO_PATH="$HOME/Documents/25D/L2/Repo4"
ERRORS=0

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

if [ $ERRORS -eq 0 ]; then
    echo "All permissions are correct!"
    exit 0
else
    echo "Found $ERRORS permission errors!"
    exit 1
fi
```

**Verification:**
```bash
chmod 755 bin/monitor-services-macos.sh bin/verify-permissions.sh
./bin/monitor-services-macos.sh
./bin/verify-permissions.sh
```

### Task 5.2: Log Management Configuration
**Duration:** 30 minutes  
**Dependencies:** Task 2.1  
**Priority:** Medium

**Deliverables:**
- Log rotation configuration
- Log cleanup automation
- Archive management

**Steps:**

1. **Create logrotate configuration:**
```bash
# config/logrotate.conf
~/Documents/25D/L2/Repo4/logs/system-logs.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 user staff
}
```

2. **Create log cleanup script:**
```bash
# bin/cleanup-logs.sh
#!/bin/bash
echo "Cleaning up old log files..."

REPO_PATH="$HOME/Documents/25D/L2/Repo4"
LOGS_DIR="$REPO_PATH/logs"

# Remove error logs older than 7 days
find "$LOGS_DIR" -name "*-error.log" -mtime +7 -delete

# Compress logs older than 1 day
find "$LOGS_DIR" -name "*.log" -mtime +1 ! -name "*error*" -exec gzip {} \;

echo "Log cleanup complete"
```

**Verification:**
```bash
chmod 755 bin/cleanup-logs.sh
./bin/cleanup-logs.sh
```

## 📖 Phase 6: Documentation & Finalization (Day 3 Afternoon)

### Task 6.1: README Documentation
**Duration:** 1 hour  
**Dependencies:** All previous tasks  
**Priority:** Medium

**Deliverables:**
- Comprehensive README.md
- Quick start guide
- Troubleshooting section

**Steps:**

1. **Create main README.md** (use the content from the repository as template)
2. **Document installation procedures**
3. **Add troubleshooting guide**
4. **Include usage examples**

### Task 6.2: Technical Documentation
**Duration:** 1 hour  
**Dependencies:** Task 6.1  
**Priority:** Medium

**Deliverables:**
- API documentation
- Configuration reference
- Performance specifications

**Steps:**

1. **Create technical specs in docs/ directory**
2. **Document configuration options**
3. **Add performance benchmarks**

### Task 6.3: Final System Validation
**Duration:** 1 hour  
**Dependencies:** All tasks  
**Priority:** High

**Deliverables:**
- Complete system validation
- Performance testing
- Documentation review

**Steps:**

1. **Run complete test suite:**
```bash
./bin/run-tests.sh
./bin/test-integration.sh
```

2. **Install and validate services:**
```bash
./bin/install-services-macos.sh  # or install-services.sh
./bin/monitor-services-macos.sh
```

3. **Performance validation:**
```bash
# Let system run for extended period
sleep 300  # 5 minutes

# Check resource usage
./bin/monitor-services-macos.sh

# Validate log file growth
wc -l logs/system-logs.log
```

## ✅ Success Criteria

### Phase 1 Completion
- [ ] Repository structure created
- [ ] Development environment ready
- [ ] Git repository initialized

### Phase 2 Completion
- [ ] Both programs implemented and tested
- [ ] Signal handling working correctly
- [ ] Error handling comprehensive

### Phase 3 Completion
- [ ] Service configuration complete
- [ ] Auto-start on boot configured
- [ ] Service management working

### Phase 4 Completion
- [ ] Unit tests passing (>90% coverage)
- [ ] Integration tests successful
- [ ] Performance within specifications

### Phase 5 Completion
- [ ] Monitoring scripts functional
- [ ] Health checks accurate
- [ ] Log management configured

### Phase 6 Completion
- [ ] Documentation complete and accurate
- [ ] System fully validated
- [ ] Ready for production deployment

## 🚨 Common Issues & Solutions

### Issue: Permission Denied Errors
**Solution:**
```bash
./bin/verify-permissions.sh
chmod 755 bin/*.py bin/*.sh
chmod 644 logs/*.log
```

### Issue: Services Won't Start
**Solution:**
```bash
# Check service logs
tail logs/*-error.log

# Verify Python path in service configs
which python3

# Check service status
launchctl list | grep com.user  # macOS
systemctl --user status system-log-writer.service  # Linux
```

### Issue: Log File Not Created
**Solution:**
```bash
# Check directory permissions
ls -la logs/

# Test manual execution
python3 bin/system-log-writer.py
```

### Issue: Tests Failing
**Solution:**
```bash
# Activate virtual environment
source venv/bin/activate

# Install test dependencies
pip install pytest

# Run with verbose output
python3 -m unittest discover tests/ -v
```

## 📈 Performance Expectations

### Resource Usage
- **CPU:** <0.1% per service
- **Memory:** ~10-15MB per service
- **Disk I/O:** Minimal (append-only writes)

### Timing Accuracy
- **Writer:** 10-second intervals (±1 second acceptable)
- **Reader:** 7-second intervals (±1 second acceptable)

### Reliability
- **Uptime:** >99.9% (excluding planned maintenance)
- **Data Loss:** <0.01% acceptable
- **Recovery Time:** <30 seconds after failure

## 🎉 Final Checklist

Before considering the implementation complete:

- [ ] All phases completed successfully
- [ ] All tests passing
- [ ] Services running automatically
- [ ] Monitoring functional
- [ ] Documentation accurate
- [ ] Performance within specifications
- [ ] Security model implemented correctly
- [ ] Ready for production use

This implementation guide provides a comprehensive roadmap for building the complete timestamp logging system based on the PDR specifications. Follow each phase sequentially for best results.