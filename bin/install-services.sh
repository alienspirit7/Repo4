#!/bin/bash
"""
Service Installation Script
Installs and starts both systemd services
"""

echo "Installing System Log Writer and Last Timestamp Reader services..."

# Copy service files
mkdir -p ~/.config/systemd/user
cp config/system-log-writer.service ~/.config/systemd/user/
cp config/last-timestamp-reader.service ~/.config/systemd/user/

# Reload systemd
systemctl --user daemon-reload

# Enable services
systemctl --user enable system-log-writer.service
systemctl --user enable last-timestamp-reader.service

# Start services
systemctl --user start system-log-writer.service
sleep 2
systemctl --user start last-timestamp-reader.service

# Check status
echo "Service Status:"
systemctl --user status system-log-writer.service --no-pager
systemctl --user status last-timestamp-reader.service --no-pager

echo "Installation complete!"
