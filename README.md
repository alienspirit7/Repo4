# System Log Writer & Last Timestamp Reader

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-blue.svg)](https://github.com)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/Python-3.7%2B-blue.svg)](https://www.python.org/)

> **A robust interdependent timestamp logging system with two complementary programs that provide continuous system monitoring and audit trail capabilities.**

## 🎯 Overview

This project implements two interdependent background services:

- **System Log Writer** - Writes current system timestamps to a log file every 10 seconds
- **Last Timestamp Reader** - Reads and displays the last timestamp from the log file every 7 seconds

The system provides real-time monitoring of logging activity and serves as a foundation for system health monitoring, audit trails, and timestamp-based analytics.

## ✨ Features

- **🔄 Continuous Operation**: Both programs run as persistent background daemons
- **🚀 Auto-Start**: Services automatically start on system boot
- **🛡️ Robust Error Handling**: Comprehensive error handling and graceful recovery
- **📊 Health Monitoring**: Built-in service monitoring and status reporting
- **🔧 Cross-Platform**: Supports both Linux (systemd) and macOS (launchd)
- **🐍 Dual Implementation**: Python and Bash script versions available
- **📝 Comprehensive Logging**: Detailed service logs and error reporting
- **🔒 Security-First**: Proper permission management and access controls

## 📋 System Requirements

### Minimum Requirements
- **OS**: Linux (Ubuntu 18.04+, CentOS 7+, RHEL 7+) or macOS 10.14+
- **Shell**: Bash 4.0+ 
- **Python**: 3.7+ (for Python implementation)
- **Disk Space**: 100MB free space
- **Memory**: 50MB available RAM

### Recommended Requirements
- **OS**: Linux with systemd or macOS with launchd
- **Python**: 3.8+ with pip
- **Disk Space**: 1GB for logs and rotation
- **Memory**: 100MB available RAM

## 🚀 Quick Start

### 1. Repository Setup
```bash
# Clone or download to the recommended location
mkdir -p ~/Documents/25D/L2/Repo4
cd ~/Documents/25D/L2/Repo4

# Or clone from repository
git clone <repository-url> ~/Documents/25D/L2/Repo4
cd ~/Documents/25D/L2/Repo4
```

### 2. Choose Your Implementation

#### Option A: Python Implementation (Recommended)
```bash
# Set up Python environment
python3 -m venv venv
source venv/bin/activate
pip install pytest

# Make scripts executable
chmod 755 bin/*.py
```

#### Option B: Shell Script Implementation
```bash
# Make scripts executable
chmod 755 bin/*.sh
```

### 3. Install Services

#### For macOS:
```bash
./bin/install-services-macos.sh
```

#### For Linux:
```bash
# Copy the appropriate service files and install
mkdir -p ~/.config/systemd/user
cp config/*.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable system-log-writer.service
systemctl --user enable last-timestamp-reader.service
systemctl --user start system-log-writer.service
systemctl --user start last-timestamp-reader.service
```

### 4. Verify Installation
```bash
# Check service status
./bin/monitor-services-macos.sh  # macOS
# OR
systemctl --user status system-log-writer.service  # Linux

# Check log output
tail -f logs/system-logs.log
```

## 📁 Project Structure

```
~/Documents/25D/L2/Repo4/
├── bin/                              # Executable scripts
│   ├── system-log-writer.py         # Python implementation (Writer)
│   ├── system-log-writer.sh         # Shell implementation (Writer)
│   ├── last-timestamp-reader.py     # Python implementation (Reader)
│   ├── last-timestamp-reader.sh     # Shell implementation (Reader)
│   ├── install-services-macos.sh    # macOS service installer
│   ├── monitor-services-macos.sh    # Service monitoring script
│   └── verify-permissions.sh        # Permission verification tool
├── config/                           # Service configurations
│   ├── com.user.system-log-writer.plist         # macOS Writer service
│   ├── com.user.last-timestamp-reader.plist     # macOS Reader service
│   ├── system-log-writer.service                # Linux Writer service
│   └── last-timestamp-reader.service            # Linux Reader service
├── logs/                            # Log files (auto-created)
│   ├── system-logs.log              # Main timestamp log (shared)
│   ├── system-log-writer.log        # Writer service output
│   ├── last-timestamp-reader.log    # Reader service output
│   └── *-error.log                  # Error logs
├── tests/                           # Test suites
│   ├── test_system_log_writer.py    # Writer unit tests
│   └── test_last_timestamp_reader.py # Reader unit tests
└── docs/                            # Documentation
    ├── implementation_guide.md       # Detailed implementation guide
    └── pdr_timestamp_system.md       # Preliminary Design Review
```

## 🔧 Usage

### Manual Execution

#### Python Version:
```bash
# Terminal 1 - Start the writer
python3 bin/system-log-writer.py

# Terminal 2 - Start the reader  
python3 bin/last-timestamp-reader.py
```

#### Shell Version:
```bash
# Terminal 1 - Start the writer
./bin/system-log-writer.sh

# Terminal 2 - Start the reader
./bin/last-timestamp-reader.sh
```

### Service Management

#### macOS (launchd):
```bash
# Load services
launchctl load ~/Library/LaunchAgents/com.user.system-log-writer.plist
launchctl load ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

# Unload services
launchctl unload ~/Library/LaunchAgents/com.user.system-log-writer.plist
launchctl unload ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

# Check status
launchctl list | grep com.user
```

#### Linux (systemd):
```bash
# Start services
systemctl --user start system-log-writer.service
systemctl --user start last-timestamp-reader.service

# Stop services
systemctl --user stop system-log-writer.service
systemctl --user stop last-timestamp-reader.service

# Check status
systemctl --user status system-log-writer.service
systemctl --user status last-timestamp-reader.service

# View logs
journalctl --user -u system-log-writer.service -f
```

## 📊 Monitoring

### Health Checks
```bash
# Run comprehensive service monitoring
./bin/monitor-services-macos.sh

# Verify file permissions
./bin/verify-permissions.sh

# Check recent log activity
tail -n 10 logs/system-logs.log
```

### Log Analysis
```bash
# Count total entries
wc -l logs/system-logs.log

# Check for gaps in logging
awk '{print $1 " " $2}' logs/system-logs.log | uniq -c

# Monitor real-time updates
tail -f logs/system-logs.log
```

### Performance Monitoring
```bash
# Check service resource usage (Linux)
systemctl --user show system-log-writer.service --property=MemoryCurrent,CPUUsageNSec

# Check disk usage
du -sh logs/
df -h ~/Documents/25D/L2/Repo4/
```

## 🧪 Testing

### Run Unit Tests
```bash
# Activate Python environment (if using Python implementation)
source venv/bin/activate

# Run all tests
python3 -m unittest discover tests/ -v

# Or with pytest
pytest tests/ -v

# Run specific test
python3 -m unittest tests.test_system_log_writer
```

### Integration Testing
```bash
# Run integration tests
./bin/test-integration.sh

# Manual integration test
python3 bin/system-log-writer.py &
WRITER_PID=$!
python3 bin/last-timestamp-reader.py &
READER_PID=$!

# Let run for 30 seconds
sleep 30

# Stop and check results
kill $WRITER_PID $READER_PID
cat logs/system-logs.log
```

## 🔒 Security

### File Permissions
The system uses strict permission controls:

```bash
# Script permissions (executable by owner, readable by others)
chmod 755 bin/*.py bin/*.sh

# Log file permissions (read/write owner, read group, no access others)
chmod 644 logs/*.log

# Verify permissions
./bin/verify-permissions.sh
```

### Access Control Matrix

| Component | Writer Access | Reader Access | Other Users |
|-----------|---------------|---------------|-------------|
| system-logs.log | Read/Write | Read Only | Read Only |
| Writer scripts | Execute | None | Execute |
| Reader scripts | None | Execute | Execute |
| Service configs | Read/Write | Read/Write | Read Only |

## 🛠️ Configuration

### Timing Configuration
Default intervals can be modified in the scripts:

```bash
# system-log-writer: Change INTERVAL=10 to desired seconds
# last-timestamp-reader: Change INTERVAL=7 to desired seconds
```

### Log Rotation
Configure automatic log rotation:

```bash
# Add to /etc/logrotate.d/timestamp-logs or use config/logrotate.conf
~/Documents/25D/L2/Repo4/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
```

### Service Customization
Modify service files in `config/` directory to customize:
- Working directory
- Environment variables  
- Restart policies
- Resource limits

## 🚨 Troubleshooting

### Common Issues

#### Services Won't Start
```bash
# Check service logs
tail logs/*-error.log

# Verify Python path (if using Python implementation)
which python3

# Check service status
launchctl list | grep com.user  # macOS
systemctl --user status system-log-writer.service  # Linux

# Reload service configuration
launchctl unload ~/Library/LaunchAgents/com.user.*.plist  # macOS
systemctl --user daemon-reload  # Linux
```

#### Permission Denied Errors
```bash
# Fix permissions
./bin/verify-permissions.sh
chmod 755 bin/*.py bin/*.sh
chmod 644 logs/*.log

# Check file ownership
ls -la logs/system-logs.log
```

#### Log File Not Created
```bash
# Check directory permissions
ls -la logs/

# Test manual execution
python3 bin/system-log-writer.py
# or
./bin/system-log-writer.sh

# Create logs directory if missing
mkdir -p logs
```

#### Tests Failing
```bash
# Ensure virtual environment is activated
source venv/bin/activate

# Install test dependencies
pip install pytest

# Run with verbose output
python3 -m unittest discover tests/ -v
```

### Performance Issues

#### High Resource Usage
```bash
# Check process status
ps aux | grep -E "(system-log-writer|last-timestamp-reader)"

# Monitor file I/O
iostat -x 1 5

# Check disk space
df -h ~/Documents/25D/L2/Repo4/
```

#### Log File Growing Too Large
```bash
# Implement log rotation
sudo logrotate -f config/logrotate.conf

# Manual log archival
cp logs/system-logs.log logs/system-logs-$(date +%Y%m%d).log
> logs/system-logs.log
```

### Getting Help

#### Enable Debug Mode
```bash
# For Python implementation, add debug logging
# Edit the scripts to set logging level to DEBUG

# For shell implementation, add set -x for debugging
# Edit scripts to add 'set -x' after shebang line
```

#### Collect Diagnostic Information
```bash
# Generate diagnostic report
echo "=== System Information ===" > diagnostic.txt
uname -a >> diagnostic.txt
echo -e "\n=== Service Status ===" >> diagnostic.txt
./bin/monitor-services-macos.sh >> diagnostic.txt
echo -e "\n=== Recent Logs ===" >> diagnostic.txt
tail -20 logs/system-logs.log >> diagnostic.txt
echo -e "\n=== Error Logs ===" >> diagnostic.txt
tail -10 logs/*-error.log >> diagnostic.txt 2>/dev/null
```

## 📈 Performance

### Expected Resource Usage
- **CPU**: <0.1% per service under normal operation
- **Memory**: ~10-15MB per Python service, ~5MB per shell service
- **Disk I/O**: Minimal append operations only
- **Log Growth**: ~50KB per day at default intervals

### Monitoring Metrics
- Service uptime and restart count
- Log file size and growth rate
- Timestamp accuracy and gaps
- Resource utilization trends

## 🔄 Maintenance

### Regular Tasks
- Monitor service health with `./bin/monitor-services-macos.sh`
- Check log file sizes and implement rotation as needed
- Verify permissions with `./bin/verify-permissions.sh`
- Run tests periodically to ensure system integrity

### Updates and Changes
- Test changes in development environment first
- Use `git` for version control of modifications
- Document any configuration changes
- Monitor system after updates for stability

## 📚 Documentation

- **[PDR Document](docs/pdr_timestamp_system.md)** - Comprehensive design review
- **[Implementation Guide](docs/implementation_guide.md)** - Step-by-step implementation
- **[Task Breakdown](tasks_json.json)** - Detailed project task structure

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and add tests
4. Run the test suite (`python3 -m unittest discover tests/`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built for robust system monitoring and audit trail requirements
- Designed with security and reliability as primary concerns
- Implements industry best practices for daemon management
- Cross-platform compatibility for diverse deployment environments

---

**Need Help?** Check the troubleshooting section above or refer to the comprehensive documentation in the `docs/` directory.