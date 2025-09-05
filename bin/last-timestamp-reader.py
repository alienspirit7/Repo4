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
