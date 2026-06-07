#!/bin/bash

LOGFILE="/tmp/lab-heartbeat.log"

echo "========== PAYLOAD EXECUTION ==========" >> "$LOGFILE"
echo "Timestamp: $(date)" >> "$LOGFILE"
echo "User: $(whoami)" >> "$LOGFILE"
echo "Hostname: $(hostname)" >> "$LOGFILE"
echo "PID: $$" >> "$LOGFILE"
echo "=======================================" >> "$LOGFILE"

sleep 5
