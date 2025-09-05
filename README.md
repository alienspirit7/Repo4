

# **System Log Writer & Last Timestamp Reader 🚀**

This repository contains the source code for an interdependent timestamp logging system. It consists of two primary services, a **System Log Writer** and a **Last Timestamp Reader**, designed to run as persistent background daemons. The system is built with BASH scripts and configured for automatic service management on macOS using launchd.

---

## **✨ Features**

* **System-wide deployment** in /usr/local/repo4.  
* **Automatic service management** via launchd for macOS.  
* **Comprehensive monitoring** with health checks and status reporting.  
* **Robust error handling** and recovery mechanisms.  
* **Production-ready** with proper logging and maintenance procedures.  
* **Minimal dependencies** using standard Unix utilities.  
* **Lightweight resource usage** with a minimal memory footprint.

---

## **🏃‍♀️ Quick Start (macOS)**

This guide will get the services running on your macOS system.

1. **Clone the Repository**  
   Bash  
   git clone \[repository-url\] /usr/local/repo4  
   cd /usr/local/repo4

2. Install Services  
   The installation script handles setting executable permissions, copying the launchd .plist files, and loading the services.  
   Bash  
   sudo ./bin/install-services-macos.sh

3. Verify Status  
   After waiting a few seconds for the services to load, you can check their status with the built-in monitoring script.  
   Bash  
   ./bin/monitor-services-macos.sh

   This script provides information on whether the services are loaded and actively working by checking for recent log activity.

---

## **📂 Project Structure**

/usr/local/repo4/  
├── .gitignore              \# Files to ignore in version control  
├── bin/                    \# Executable scripts (installation, monitoring, services)  
├── config/                 \# Service configuration files (.plist files)  
├── logs/                   \# Log files (created at runtime)  
├── README.md               \# This file  
├── task\_implementation\_guide.md \# Detailed task roadmap  
├── tasks\_json\_complete.json \# Detailed project tasks in JSON format  
└── unified\_pdr\_timestamp\_system.md \# Preliminary Design Review document

---

## **🏗️ Architecture**

The system is comprised of two core BASH scripts managed by launchd services:

1. **System Log Writer (system-log-writer.sh):** This service runs as a persistent background daemon that writes the current system timestamp to a shared log file, logs/system-logs.log, every 10 seconds. It includes signal handling for graceful shutdowns.  
2. **Last Timestamp Reader (last-timestamp-reader.sh):** This service continuously reads the last timestamp from the shared log file every 7 seconds and outputs it to its own log file. It is designed to monitor the writer's health by checking for recent log file updates. The reader handles errors gracefully, such as when the log file is not found or is empty.

Both services are configured with KeepAlive and RunAtLoad keys in their .plist files to ensure they automatically start on boot and restart on failure.

---

## **⚙️ Service Management**

The launchd files handle the service lifecycle for macOS users.

**Start Services**

Bash

launchctl load \~/Library/LaunchAgents/com.user.system-log-writer.plist  
launchctl load \~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

**Stop Services**

Bash

launchctl unload \~/Library/LaunchAgents/com.user.system-log-writer.plist  
launchctl unload \~/Library/LaunchAgents/com.user.last-timestamp-reader.plist

**Check Status**

Bash

launchctl list | grep com.user

---

## **📊 Monitoring & Health Checks**

The monitor-services-macos.sh script provides a comprehensive health check for the system.

Bash

./bin/monitor-services-macos.sh

This script checks the service load status with launchctl, performs a "liveness check" by verifying the main log file has been updated within the last 30 seconds, and checks for recent errors in the dedicated error log files. It provides a clear, color-coded output.

---

## **🛠️ Troubleshooting**

| Issue | Quick Fix | Prevention |
| :---- | :---- | :---- |
| Services won't start | Check permissions: chmod 755 /usr/local/repo4/bin/\*.sh | Use the installation script |
| No log entries | Verify scripts are executable and running | Monitor service status |
| Reader shows "file not found" | Ensure the writer is running first | Service dependencies |
| High resource usage | Check for multiple instances running with pgrep \-f \[script-name\] | Proper service management |
| Log file corruption | Stop services, restore from backup | Implement proper log rotation |

---

## **🔒 Security & Maintenance**

* **Permissions:** The system is designed to run with the principle of least privilege. Services run under a user context, not as root. The log file, \~/system-logs.log, has permissions that only allow read and write access for the owner and read-only access for the group, preventing unauthorized modifications.  
* **Log Management:** A daily log rotation is planned to manage disk space, with logs compressed and retained for 7 days. An automated cleanup script, cleanup-logs.sh, is also part of the maintenance plan.  
* **Reliability:** The system is engineered for high availability with an uptime target of \>99.9%. The automatic restart functionality ensures service recovery within 30 seconds of a failure.

---

## **🗺️ Development Roadmap**

The project was structured into six phases, detailing the development lifecycle from initial setup to final deployment and documentation.

* **Phase 1:** Environment & Setup (Repository structure, permissions, Git).  
* **Phase 2:** Core Implementation (System Log Writer & Last Timestamp Reader scripts).  
* **Phase 3:** Service Configuration (macOS launchd configuration and installation script).  
* **Phase 4:** Testing & Validation (Integration, performance, and stress testing).  
* **Phase 5:** Monitoring & Tools (Log management and advanced health checks).  
* **Phase 6:** Documentation & Deployment (README creation, final validation).

---

## **🤝 Contributing**

Contributions are welcome\! Please refer to the task\_implementation\_guide.md and unified\_pdr\_timestamp\_system.md for a deeper understanding of the project's design and planned future enhancements.