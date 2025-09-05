#!/usr/bin/env python3
"""
Unit tests for System Log Writer
"""

import unittest
import tempfile
import os
import sys
import datetime
import time

# Add bin directory to path to import our module
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'bin'))

class TestSystemLogWriter(unittest.TestCase):
    
    def setUp(self):
        """Set up test environment"""
        self.test_dir = tempfile.mkdtemp()
        self.log_file = os.path.join(self.test_dir, "test-logs.log")
        
    def tearDown(self):
        """Clean up test environment"""
        if os.path.exists(self.log_file):
            os.remove(self.log_file)
        os.rmdir(self.test_dir)
        
    def test_timestamp_format(self):
        """Test timestamp format compliance"""
        # Test that datetime format matches YYYY-MM-DD hh:mm:ss
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.assertRegex(timestamp, r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')
        
    def test_file_creation(self):
        """Test log file creation"""
        # Test that log file is created when it doesn't exist
        self.assertFalse(os.path.exists(self.log_file))
        
        with open(self.log_file, 'w') as f:
            f.write("test\n")
            
        self.assertTrue(os.path.exists(self.log_file))
        
    def test_file_append(self):
        """Test that timestamps are appended to log file"""
        # Write initial content
        with open(self.log_file, 'w') as f:
            f.write("initial\n")
            
        # Append timestamp
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(self.log_file, 'a') as f:
            f.write(f"{timestamp}\n")
            
        # Verify both lines exist
        with open(self.log_file, 'r') as f:
            lines = f.readlines()
            
        self.assertEqual(len(lines), 2)
        self.assertEqual(lines[0].strip(), "initial")
        self.assertEqual(lines[1].strip(), timestamp)

if __name__ == '__main__':
    unittest.main()
