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
