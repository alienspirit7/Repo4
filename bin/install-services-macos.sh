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
