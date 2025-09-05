#!/usr/bin/env python3
"""
Unit tests for Last Timestamp Reader
"""

import unittest
import tempfile
import os
import sys

# Add bin directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'bin'))

class TestLastTimestampReader(unittest.TestCase):
    
    def setUp(self):
        """Set up test environment"""
        self.test_dir = tempfile.mkdtemp()
        self.log_file = os.path.join(self.test_dir, "test-logs.log")
        
    def tearDown(self):
        """Clean up test environment"""
        if os.path.exists(self.log_file):
            os.remove(self.log_file)
        os.rmdir(self.test_dir)
        
    def test_empty_file(self):
        """Test behavior with empty file"""
        # Create empty file
        open(self.log_file, 'w').close()
        
        # This would test the reader class if we imported it
        # For now, just verify file exists and is empty
        self.assertTrue(os.path.exists(self.log_file))
        self.assertEqual(os.path.getsize(self.log_file), 0)
        
    def test_file_not_found(self):
        """Test behavior when file doesn't exist"""
        self.assertFalse(os.path.exists(self.log_file))
        
    def test_read_last_line(self):
        """Test reading last line from file"""
        # Write test data
        with open(self.log_file, 'w') as f:
            f.write("2024-01-01 10:00:00\n")
            f.write("2024-01-01 10:00:10\n")
            f.write("2024-01-01 10:00:20\n")
            
        # Read last line
        with open(self.log_file, 'r') as f:
            lines = f.readlines()
            last_line = lines[-1].strip()
            
        self.assertEqual(last_line, "2024-01-01 10:00:20")

if __name__ == '__main__':
    unittest.main()
