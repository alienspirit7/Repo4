#!/bin/bash
# macOS Service Installation Script - BASH VERSION
# Installs and starts both launchd services using bash scripts

REPO_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Installing System Log Writer and Last Timestamp Reader services (BASH VERSION)..."
echo "Repository path: $REPO_PATH"

# Ensure bash scripts are executable
chmod +x "$REPO_PATH/bin/system-log-writer.sh"
chmod +x "$REPO_PATH/bin/last-timestamp-reader.sh"

# Create LaunchAgents directory
mkdir -p ~/Library/LaunchAgents

# Stop any existing services
launchctl unload ~/Library/LaunchAgents/com.user.system-log-writer.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist 2>/dev/null

# Create system-log-writer service (BASH)
cat > ~/Library/LaunchAgents/com.user.system-log-writer.plist << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.system-log-writer</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$REPO_PATH/bin/system-log-writer.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$REPO_PATH</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$REPO_PATH/logs/system-log-writer.log</string>
    <key>StandardErrorPath</key>
    <string>$REPO_PATH/logs/system-log-writer-error.log</string>
</dict>
</plist>
PLIST

# Create last-timestamp-reader service (BASH)
cat > ~/Library/LaunchAgents/com.user.last-timestamp-reader.plist << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.last-timestamp-reader</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$REPO_PATH/bin/last-timestamp-reader.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$REPO_PATH</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$REPO_PATH/logs/last-timestamp-reader.log</string>
    <key>StandardErrorPath</key>
    <string>$REPO_PATH/logs/last-timestamp-reader-error.log</string>
</dict>
</plist>
PLIST

# Load and start services
echo "Loading System Log Writer service (bash)..."
launchctl load ~/Library/LaunchAgents/com.user.system-log-writer.plist

echo "Waiting 3 seconds..."
sleep 3

echo "Loading Last Timestamp Reader service (bash)..."
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
echo "Services are now running BASH versions!"
echo "No Python dependencies required!"
