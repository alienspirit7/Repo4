# System Log Writer & Last Timestamp Reader

## Project Overview
Implementation of two interdependent Linux programs for timestamp logging and monitoring.

## Repository Structure
~/Documents/25D/L2/Repo4/
├── bin/           # Executable scripts
├── config/        # Service configurations
├── logs/          # Log files
├── docs/          # Documentation
└── tests/         # Unit tests

## Installation Instructions
[To be completed during implementation]

## Usage
[To be completed during implementation]

## Troubleshooting
[To be completed during implementation]

## Quick Start

1. Clone or download the repository to ~/Documents/25D/L2/Repo4
2. Set up the environment:
   ```bash
   cd ~/Documents/25D/L2/Repo4
   ./bin/verify-permissions.sh

Install and start services:
bash./bin/install-services.sh

Monitor the system:
bash./bin/monitor-services.sh


Manual Testing
Test Program A (System Log Writer)
bashpython3 bin/system-log-writer.py
# Press Ctrl+C to stop
Test Program B (Last Timestamp Reader)
bashpython3 bin/last-timestamp-reader.py
# Press Ctrl+C to stop
Test Both Programs Together
bash# Terminal 1
python3 bin/system-log-writer.py

# Terminal 2
python3 bin/last-timestamp-reader.py
Troubleshooting
Services won't start

Check permissions: ./bin/verify-permissions.sh
Check service status: systemctl --user status system-log-writer.service

Log file not being created

Verify directory permissions
Check Python 3 installation
Review service logs: journalctl --user -u system-log-writer.service

Reader can't access log file

Verify log file exists and has correct permissions (644)
Ensure reader has read access to the logs directory

Maintenance
Log Rotation
Configure logrotate using the provided config:
bashsudo cp config/logrotate.conf /etc/logrotate.d/system-log-writer
Service Management
bash# Stop services
systemctl --user stop system-log-writer.service last-timestamp-reader.service

# Start services
systemctl --user start system-log-writer.service last-timestamp-reader.service

# Restart services
systemctl --user restart system-log-writer.service last-timestamp-reader.service

# Check logs
journalctl --user -u system-log-writer.service -f

## Quick Start

1. Clone or download the repository to ~/Documents/25D/L2/Repo4
2. Set up the environment:
   ```bash
   cd ~/Documents/25D/L2/Repo4
   ./bin/verify-permissions.sh

Install and start services:
bash./bin/install-services.sh

Monitor the system:
bash./bin/monitor-services.sh


Manual Testing
Test Program A (System Log Writer)
bashpython3 bin/system-log-writer.py
# Press Ctrl+C to stop
Test Program B (Last Timestamp Reader)
bashpython3 bin/last-timestamp-reader.py
# Press Ctrl+C to stop
Test Both Programs Together
bash# Terminal 1
python3 bin/system-log-writer.py

# Terminal 2
python3 bin/last-timestamp-reader.py
Troubleshooting
Services won't start

Check permissions: ./bin/verify-permissions.sh
Check service status: systemctl --user status system-log-writer.service

Log file not being created

Verify directory permissions
Check Python 3 installation
Review service logs: journalctl --user -u system-log-writer.service

Reader can't access log file

Verify log file exists and has correct permissions (644)
Ensure reader has read access to the logs directory

Maintenance
Log Rotation
Configure logrotate using the provided config:
bashsudo cp config/logrotate.conf /etc/logrotate.d/system-log-writer
Service Management
bash# Stop services
systemctl --user stop system-log-writer.service last-timestamp-reader.service

# Start services
systemctl --user start system-log-writer.service last-timestamp-reader.service

# Restart services
systemctl --user restart system-log-writer.service last-timestamp-reader.service

# Check logs
journalctl --user -u system-log-writer.service -f
