#!/bin/bash

# ============================================================
# Encoded Command Execution Simulation Payload
# Detection Engineering Lab
# Purpose:
#   Simulate post-compromise reconnaissance activity executed
#   through an encoded payload.
# ============================================================

LOG_FILE="/tmp/encoded_execution.log"
MARKER_FILE="/tmp/.enc_exec_marker"

log_event() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_event "PAYLOAD_START"

# ------------------------------------------------------------
# Identity Discovery
# ------------------------------------------------------------

log_event "IDENTITY_DISCOVERY_START"

whoami >> "$LOG_FILE" 2>&1
id >> "$LOG_FILE" 2>&1

log_event "IDENTITY_DISCOVERY_COMPLETE"

# ------------------------------------------------------------
# Host Discovery
# ------------------------------------------------------------

log_event "HOST_DISCOVERY_START"

hostname >> "$LOG_FILE" 2>&1
uname -a >> "$LOG_FILE" 2>&1

log_event "HOST_DISCOVERY_COMPLETE"

# ------------------------------------------------------------
# Process Discovery
# ------------------------------------------------------------

log_event "PROCESS_DISCOVERY_START"

ps aux >> "$LOG_FILE" 2>&1

log_event "PROCESS_DISCOVERY_COMPLETE"

# ------------------------------------------------------------
# Artifact Creation
# ------------------------------------------------------------

log_event "ARTIFACT_CREATION_START"

touch "$MARKER_FILE"

log_event "ARTIFACT_CREATED:$MARKER_FILE"

# ------------------------------------------------------------
# Local Network Activity
# ------------------------------------------------------------

log_event "NETWORK_ACTIVITY_START"

curl -s http://127.0.0.1:8080/ping >> "$LOG_FILE" 2>&1

log_event "NETWORK_ACTIVITY_COMPLETE"

# ------------------------------------------------------------
# Payload Completion
# ------------------------------------------------------------

log_event "PAYLOAD_COMPLETE"

exit 0
