#!/bin/bash
echo "=== LaunchD Environment Debug ===" >> /usr/local/repo4/logs/debug.log
echo "Date: $(date)" >> /usr/local/repo4/logs/debug.log
echo "PWD: $PWD" >> /usr/local/repo4/logs/debug.log
echo "PATH: $PATH" >> /usr/local/repo4/logs/debug.log
echo "USER: $USER" >> /usr/local/repo4/logs/debug.log
echo "HOME: $HOME" >> /usr/local/repo4/logs/debug.log
which date >> /usr/local/repo4/logs/debug.log
ls -la /usr/local/repo4/ >> /usr/local/repo4/logs/debug.log
