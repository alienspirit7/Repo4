#!/bin/bash
# macOS Service Installation Script
# Installs and starts both launchd services

echo "Installing System Log Writer and Last Timestamp Reader services for macOS..."

# Copy plist files to LaunchAgents
mkdir -p ~/Library/LaunchAgents
cp config/com.user.system-log-writer.plist ~/Library/LaunchAgents/
cp config/com.user.last-timestamp-reader.plist ~/Library/LaunchAgents/

# Load and start services using launchctl
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
echo "Services will start automatically on login."
