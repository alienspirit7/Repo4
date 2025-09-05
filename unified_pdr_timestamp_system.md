# Preliminary Design Review: System Log Writer & Last Timestamp Reader

**Document Version:** 2.0  
**Date:** September 2025  
**Project:** Interdependent Timestamp Logging System  
**Implementation:** BASH Scripts with systemd Management  

## 1. Introduction

This document presents the preliminary design for two interdependent Linux programs that provide continuous timestamp logging and monitoring capabilities. The system consists of two BASH scripts operating as systemd-managed daemons:

**Program A: System Log Writer** - A persistent background daemon that captures the current system time and writes it to a shared log file at regular 10-second intervals. This program serves as the primary data source for timestamp monitoring and provides a continuous audit trail of system activity.

**Program B: Last Timestamp Reader** - A complementary monitoring daemon that reads the log file produced by Program A and extracts the most recent timestamp entry every 7 seconds. This program enables real-time monitoring of the logging system's health and provides immediate visibility into the last recorded system activity.

Both programs operate as independent systemd services but share a common log file located at `~/system-logs.log`, creating an interdependent system where the reader depends on the writer's output for monitoring the overall system health.

## 2. Functional Requirements

### 2.1 Program A: System Log Writer Requirements

- **FR-A1:** Write current system timestamp to `~/system-logs.log` every 10 seconds
- **FR-A2:** Use exact timestamp format: `YYYY-MM-DD hh:mm:ss` (note: lowercase 'hh' for 24-hour format)
- **FR-A3:** Operate as persistent background daemon managed by systemd
- **FR-A4:** Handle graceful shutdown on SIGTERM/SIGINT signals
- **FR-A5:** Create log file if it does not exist
- **FR-A6:** Append timestamps to existing log file without overwriting previous entries
- **FR-A7:** Continue operation through system reboots via systemd auto-start
- **FR-A8:** Maintain exclusive write access to the log file during operation
- **FR-A9:** Log service status and errors to systemd journal

### 2.2 Program B: Last Timestamp Reader Requirements

- **FR-B1:** Read `~/system-logs.log` every 7 seconds to extract the last timestamp
- **FR-B2:** Output the last timestamp to stdout for monitoring and logging
- **FR-B3:** Operate as persistent background daemon managed by systemd
- **FR-B4:** Handle file not found, empty file, and permission error scenarios gracefully
- **FR-B5:** Process malformed timestamp entries without crashing
- **FR-B6:** Maintain read-only access to the shared log file
- **FR-B7:** Continue operation through system reboots via systemd auto-start
- **FR-B8:** Provide clear error messages for debugging purposes
- **FR-B9:** Log service status and errors to systemd journal

### 2.3 System Integration Requirements

- **FR-S1:** Both services must auto-start on system boot
- **FR-S2:** Reader service should start after writer service to ensure log file availability
- **FR-S3:** Services must restart automatically on failure with exponential backoff
- **FR-S4:** Shared log file must support concurrent read/write access safely
- **FR-S5:** System must handle log file rotation and growth management

## 3. Technical Design

### 3.1 Implementation Plan

Both programs will be implemented as BASH scripts utilizing standard Unix utilities and shell built-ins. This approach ensures:

- **Minimal dependencies:** Only standard Linux tools required
- **Lightweight resource usage:** Shell scripts have minimal memory footprint
- **High reliability:** Simple implementation reduces potential failure points
- **Easy maintenance:** BASH scripts are widely understood and debuggable

**Program A Implementation Strategy:**
```bash
#!/bin/bash
# system-log-writer.sh - Writes system timestamps every 10 seconds

LOG_FILE="$HOME/system-logs.log"
INTERVAL=10

# Signal handling for graceful shutdown
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') System Log Writer stopped" >&2
    exit 0
}

trap cleanup SIGTERM SIGINT

# Main execution loop
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    sleep $INTERVAL
done
```

**Program B Implementation Strategy:**
```bash
#!/bin/bash
# last-timestamp-reader.sh - Reads last timestamp every 7 seconds

LOG_FILE="$HOME/system-logs.log"
INTERVAL=7

# Signal handling for graceful shutdown
cleanup() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') Last Timestamp Reader stopped" >&2
    exit 0
}

trap cleanup SIGTERM SIGINT

# Main execution loop
while true; do
    if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
        LAST_TIMESTAMP=$(tail -n 1 "$LOG_FILE")
        echo "Last timestamp: $LAST_TIMESTAMP"
    else
        echo "Log file not found or empty"
    fi
    sleep $INTERVAL
done
```

### 3.2 Scheduling and Daemon Management

Both programs will be managed as systemd user services, providing robust process management, automatic restart capabilities, and integration with the system logging infrastructure.

**systemd Service Configuration for Program A:**
```ini
[Unit]
Description=System Log Writer Service
After=multi-user.target

[Service]
Type=simple
ExecStart=%h/bin/system-log-writer.sh
WorkingDirectory=%h
Restart=always
RestartSec=5
User=%i
Environment=HOME=%h
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

**systemd Service Configuration for Program B:**
```ini
[Unit]
Description=Last Timestamp Reader Service
After=multi-user.target system-log-writer.service
Wants=system-log-writer.service

[Service]
Type=simple
ExecStart=%h/bin/last-timestamp-reader.sh
WorkingDirectory=%h
Restart=always
RestartSec=7
User=%i
Environment=HOME=%h
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

**Key systemd Features Utilized:**
- **Automatic Restart:** `Restart=always` ensures service recovery after failures
- **Dependency Management:** Reader service depends on writer service availability
- **User Service:** Services run in user context for security isolation
- **Journal Integration:** All output captured in systemd journal for centralized logging
- **Environment Preservation:** HOME environment variable maintained for path resolution

## 4. File & Directory Structure

### 4.1 Program Script Locations

```
/home/[username]/
├── bin/
│   ├── system-log-writer.sh     # Program A executable
│   └── last-timestamp-reader.sh # Program B executable
├── .config/systemd/user/
│   ├── system-log-writer.service    # systemd service file for Program A
│   └── last-timestamp-reader.service # systemd service file for Program B
└── system-logs.log              # Shared log file (created automatically)
```

### 4.2 Installation Directory Structure

**Script Installation:**
```bash
# Create bin directory if it doesn't exist
mkdir -p ~/bin

# Copy executable scripts
cp system-log-writer.sh ~/bin/
cp last-timestamp-reader.sh ~/bin/

# Ensure bin directory is in PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
```

**Service Installation:**
```bash
# Create systemd user directory
mkdir -p ~/.config/systemd/user

# Copy service files
cp system-log-writer.service ~/.config/systemd/user/
cp last-timestamp-reader.service ~/.config/systemd/user/

# Reload systemd configuration
systemctl --user daemon-reload
```

### 4.3 Log File Management

**Log File Location:** `~/system-logs.log`
- **Purpose:** Central storage for all timestamp entries
- **Format:** One timestamp per line in `YYYY-MM-DD hh:mm:ss` format
- **Growth Rate:** Approximately 8,640 entries per day (~260KB daily at full operation)
- **Rotation:** Managed through logrotate or manual archival procedures

## 5. Security & Permissions

### 5.1 File Permission Matrix

**Critical Security Implementation:**

| File/Directory | Owner | Group | Others | Numeric | Command |
|---------------|-------|-------|--------|---------|---------|
| ~/bin/system-log-writer.sh | rwx | r-x | r-x | 755 | `chmod 755 ~/bin/system-log-writer.sh` |
| ~/bin/last-timestamp-reader.sh | rwx | r-x | r-x | 755 | `chmod 755 ~/bin/last-timestamp-reader.sh` |
| ~/system-logs.log | rw- | r-- | --- | 640 | `chmod 640 ~/system-logs.log` |
| ~/.config/systemd/user/*.service | rw- | r-- | r-- | 644 | `chmod 644 ~/.config/systemd/user/*.service` |
| ~/bin/ | rwx | r-x | r-x | 755 | `chmod 755 ~/bin` |

### 5.2 Ownership Configuration

**User Ownership Setup:**
```bash
# Set proper ownership for all files
chown $(whoami):$(whoami) ~/bin/system-log-writer.sh
chown $(whoami):$(whoami) ~/bin/last-timestamp-reader.sh
chown $(whoami):$(whoami) ~/system-logs.log
chown $(whoami):$(whoami) ~/.config/systemd/user/system-log-writer.service
chown $(whoami):$(whoami) ~/.config/systemd/user/last-timestamp-reader.service
```

### 5.3 Security Implementation Commands

**Complete Permission Setup Script:**
```bash
#!/bin/bash
# setup-permissions.sh - Configure proper file permissions

echo "Setting up file permissions for timestamp logging system..."

# Executable permissions for scripts
chmod 755 ~/bin/system-log-writer.sh
chmod 755 ~/bin/last-timestamp-reader.sh

# Log file permissions (read/write for owner, read for group, no access for others)
touch ~/system-logs.log
chmod 640 ~/system-logs.log

# Service file permissions
chmod 644 ~/.config/systemd/user/system-log-writer.service
chmod 644 ~/.config/systemd/user/last-timestamp-reader.service

# Directory permissions
chmod 755 ~/bin
chmod 755 ~/.config/systemd/user

# Verify permissions
echo "Verification of permissions:"
ls -la ~/bin/system-log-writer.sh
ls -la ~/bin/last-timestamp-reader.sh
ls -la ~/system-logs.log
ls -la ~/.config/systemd/user/*.service

echo "Permission setup complete!"
```

### 5.4 Access Control Verification

**Security Validation Commands:**
```bash
# Verify Program A can write to log file
sudo -u $(whoami) test -w ~/system-logs.log && echo "Program A: Write access OK" || echo "Program A: Write access FAILED"

# Verify Program B can read from log file
sudo -u $(whoami) test -r ~/system-logs.log && echo "Program B: Read access OK" || echo "Program B: Read access FAILED"

# Verify scripts are executable
test -x ~/bin/system-log-writer.sh && echo "Writer script: Executable OK" || echo "Writer script: Executable FAILED"
test -x ~/bin/last-timestamp-reader.sh && echo "Reader script: Executable OK" || echo "Reader script: Executable FAILED"

# Check that other users cannot write to log file
ls -la ~/system-logs.log | grep -q "rw-r-----" && echo "Log file permissions: SECURE" || echo "Log file permissions: INSECURE"
```

### 5.5 Security Hardening Measures

**Additional Security Considerations:**
- **Principle of Least Privilege:** Reader has read-only access to log file
- **User Isolation:** Services run under individual user context, not root
- **File System Security:** Log file protected from modification by other users
- **Service Isolation:** Each program runs as separate systemd service
- **Input Validation:** Reader validates timestamp format before processing
- **Resource Limits:** systemd provides built-in resource limiting capabilities

## 6. Risks & Mitigation

### 6.1 File System Risks

**Risk R1: Log File Corruption**
- **Probability:** Low
- **Impact:** Medium (loss of historical data)
- **Root Cause:** Concurrent write operations, system crashes during write
- **Mitigation Strategies:**
  - Use atomic write operations with temporary files
  - Implement file locking mechanisms
  - Regular backup procedures
  - File integrity checking

**Risk R2: Disk Space Exhaustion**
- **Probability:** Medium (long-term operation)
- **Impact:** High (system-wide impact)
- **Root Cause:** Unlimited log file growth over time
- **Mitigation Strategies:**
  - Implement logrotate configuration
  - Monitor disk usage with alerts
  - Automatic archival of old logs
  - Configurable retention policies

**Risk R3: Permission Drift**
- **Probability:** Low
- **Impact:** High (service failure)
- **Root Cause:** System updates, manual permission changes
- **Mitigation Strategies:**
  - Regular permission auditing
  - Automated permission restoration scripts
  - Configuration management tools
  - Documentation of proper permissions

### 6.2 Service Availability Risks

**Risk R4: systemd Service Failure**
- **Probability:** Low
- **Impact:** Medium (temporary service outage)
- **Root Cause:** Process crashes, resource exhaustion, configuration errors
- **Mitigation Strategies:**
  - Automatic restart via systemd (`Restart=always`)
  - Health monitoring and alerting
  - Resource limit configuration
  - Regular service status monitoring

**Risk R5: Race Conditions**
- **Probability:** Very Low
- **Impact:** Low (occasional missed reads)
- **Root Cause:** Reader accessing file during writer update
- **Mitigation Strategies:**
  - Different timing intervals (10s vs 7s)
  - File system atomic operations
  - Error handling in reader for partial reads
  - Retry mechanisms

**Risk R6: System Reboot Data Loss**
- **Probability:** Low
- **Impact:** Low (temporary gap in logging)
- **Root Cause:** Services not starting automatically after reboot
- **Mitigation Strategies:**
  - systemd auto-start configuration
  - Service dependency management
  - Boot-time validation scripts
  - Service status monitoring

### 6.3 Operational Risks

**Risk R7: Clock Synchronization Issues**
- **Probability:** Low
- **Impact:** Medium (inaccurate timestamps)
- **Root Cause:** System clock drift, NTP failures
- **Mitigation Strategies:**
  - NTP synchronization configuration
  - Time drift monitoring
  - Timestamp validation procedures
  - External time source verification

**Risk R8: Log File Format Corruption**
- **Probability:** Low
- **Impact:** Medium (reader parsing failures)
- **Root Cause:** Manual file editing, script errors
- **Mitigation Strategies:**
  - Read-only access for monitoring tools
  - Format validation in reader
  - Backup and recovery procedures
  - Input sanitization

### 6.4 Monitoring and Alerting Framework

**Proactive Risk Management:**
```bash
# Service health monitoring script
#!/bin/bash
# monitor-services.sh

echo "=== Timestamp Logging System Health Check ==="
echo "Timestamp: $(date)"

# Check service status
systemctl --user is-active system-log-writer.service
systemctl --user is-active last-timestamp-reader.service

# Check log file health
if [ -f ~/system-logs.log ]; then
    LAST_ENTRY=$(tail -n 1 ~/system-logs.log)
    echo "Last log entry: $LAST_ENTRY"
    
    # Check if entry is recent (within last 30 seconds)
    CURRENT_TIME=$(date +%s)
    LAST_LOG_TIME=$(date -d "$LAST_ENTRY" +%s 2>/dev/null)
    
    if [ ! -z "$LAST_LOG_TIME" ]; then
        TIME_DIFF=$((CURRENT_TIME - LAST_LOG_TIME))
        if [ $TIME_DIFF -lt 30 ]; then
            echo "✅ System Log Writer: HEALTHY"
        else
            echo "❌ System Log Writer: STALE (${TIME_DIFF}s old)"
        fi
    fi
else
    echo "❌ Log file not found"
fi

# Check disk space
DISK_USAGE=$(df -h ~/ | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    echo "⚠️  Disk space warning: ${DISK_USAGE}% used"
fi
```

## 7. Next Steps

### 7.1 Detailed Design Phase

**Phase 1: Implementation Development (Week 1)**
- Create complete BASH script implementations with error handling
- Develop comprehensive test suites for both programs
- Implement signal handling and graceful shutdown procedures
- Create installation and configuration scripts

**Phase 2: Service Integration (Week 2)**
- Design systemd service configurations with proper dependencies
- Implement service monitoring and health check scripts
- Create automated installation procedures
- Develop service management documentation

**Phase 3: Security Hardening (Week 2)**
- Implement comprehensive permission management
- Develop security auditing procedures
- Create backup and recovery mechanisms
- Establish log rotation and archival policies

### 7.2 Testing Strategy

**Unit Testing:**
- Individual script functionality validation
- Error handling verification
- Signal processing testing
- File permission validation

**Integration Testing:**
- Service coordination testing
- Concurrent access validation
- System reboot recovery testing
- Long-term stability testing

**Performance Testing:**
- Resource usage monitoring
- Timing accuracy validation
- Load testing under various conditions
- Memory and CPU utilization analysis

### 7.3 Deployment Planning

**Staging Environment Setup:**
- Replicate production environment conditions
- Implement monitoring and alerting systems
- Conduct comprehensive testing procedures
- Document deployment procedures

**Production Deployment:**
- Gradual rollout with monitoring
- Service health validation
- Performance baseline establishment
- Documentation and training completion

### 7.4 Maintenance Procedures

**Ongoing Operations:**
- Regular service health monitoring
- Log rotation and archival management
- Performance optimization
- Security audit procedures

**Change Management:**
- Version control implementation
- Change approval procedures
- Rollback planning
- Documentation maintenance

This preliminary design review provides a comprehensive foundation for implementing a robust, secure, and maintainable timestamp logging system using BASH scripts and systemd service management.