# Systemd Service Persistence Scenario

## Overview

This scenario simulates Linux persistence through a malicious `systemd` service.  
The objective is to emulate how adversaries abuse system services to maintain persistence while generating telemetry for detection engineering and investigation workflows.

The simulation focuses on:
- malicious service creation
- persistence through `systemd`
- suspicious `ExecStart` execution
- daemonized shell activity
- process lineage analysis
- ATT&CK-aligned detection engineering

---

# ATT&CK Mapping

| Technique | Description |
|---|---|
| T1543.002 | Create or Modify System Process: Systemd Service |

---

# Scenario Objective

The objective of this simulation is to:

- create a malicious persistent `systemd` service
- execute a shell-based payload through `ExecStart`
- generate operational Linux telemetry
- engineer ATT&CK-aligned detections
- validate Sigma detection logic
- preserve investigation evidence

---

# Lab Environment

| Component | Value |
|---|---|
| Operating System | Ubuntu Linux |
| Service Manager | systemd |
| Logging Sources | journalctl, auditd |
| Detection Framework | Sigma |
| Shell Payload | updater.sh |

---

# Attack Flow

```text
Attacker Payload
        ↓
Malicious Service File Creation
        ↓
systemctl daemon-reload
        ↓
systemctl enable/start
        ↓
systemd Executes Payload
        ↓
Shell Process Spawned
        ↓
Persistent Execution
        ↓
Telemetry Generation
        ↓
Detection Engineering
```

---

# Payload Description

The payload used in this simulation is:

```bash
#!/bin/bash

while true
do
    echo "[+] Heartbeat active: $(date)" >> /tmp/heartbeat.log
    sleep 60
done
```

The payload continuously writes heartbeat entries to a log file to simulate recurring malicious activity.

---

# Service Configuration

Example malicious service definition:

```ini
[Unit]
Description=Updater Service

[Service]
ExecStart=/bin/bash /home/bunny/Detection-Engineering-Lab/scenarios/systemd-service-persistence/updater.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

---

# Simulation Execution Procedure

## Step 1 — Create Payload Script

Create the malicious payload:

```bash
nano updater.sh
```

Add the payload content and save the file.

---

## Step 2 — Assign Execution Permissions

```bash
chmod +x updater.sh
```

---

## Step 3 — Create Malicious Service

```bash
sudo nano /etc/systemd/system/updater.service
```

Insert the malicious service configuration.

---

## Step 4 — Reload systemd Daemon

```bash
sudo systemctl daemon-reload
```

---

## Step 5 — Enable Persistence

```bash
sudo systemctl enable updater.service
```

---

## Step 6 — Start Service

```bash
sudo systemctl start updater.service
```

---

## Step 7 — Verify Execution

```bash
sudo systemctl status updater.service
```

Verify:
- service is active
- payload is executing
- heartbeat log is generated

---

# Telemetry Generated

The simulation generated the following telemetry:

- `systemctl` execution events
- service enablement activity
- daemon reload activity
- shell execution from `systemd`
- parent-child process lineage
- journal execution logs
- recurring payload execution
- auditd execution telemetry

---

# Key Telemetry Sources

| Source | Purpose |
|---|---|
| journalctl | Service execution logs |
| auditd | Process execution telemetry |
| ps / pstree | Process lineage analysis |
| systemctl | Service management events |

---

# Process Lineage

Expected process chain:

```text
systemd
 └── bash
      └── updater.sh
```

This lineage is a critical detection indicator because `systemd` spawning shell interpreters is suspicious in many enterprise environments.

---

# Investigation Focus Areas

The investigation phase analyzed:

- suspicious service creation
- abnormal `ExecStart` usage
- shell interpreters spawned by `systemd`
- persistence behavior
- recurring daemon execution
- service restart behavior
- process lineage anomalies

---

# Detection Engineering Focus

The detection engineering phase focused on identifying:

- suspicious `systemd` service creation
- shell execution from `systemd`
- interpreter abuse in `ExecStart`
- abnormal daemonized shell activity
- persistence through custom services

---

# Detection Logic Summary

Core detection logic includes:

- monitoring execution of:
  - `/bin/bash`
  - `/bin/sh`
  - `/usr/bin/python`
- identifying parent process:
  - `/usr/lib/systemd/systemd`
- detecting suspicious `ExecStart` patterns
- monitoring service enablement and reload events
- correlating process lineage with daemon execution

---

# Example Detection Conditions

## Suspicious Parent-Child Relationship

```text
ParentImage = /usr/lib/systemd/systemd
Image IN (
    /bin/bash,
    /bin/sh,
    /usr/bin/python
)
```

---

## Suspicious ExecStart Pattern

```text
ExecStart contains:
- bash
- sh
- curl
- wget
- nc
```

---

# Sigma Rule Objectives

The Sigma detection rule aims to identify:

- shell interpreters executed by `systemd`
- suspicious custom services
- persistence-oriented daemon behavior
- malicious `ExecStart` usage

---

# Validation Results

The detection was considered successful because:

- the malicious service executed successfully
- persistence survived session lifecycle
- telemetry was generated consistently
- process lineage confirmed daemon execution
- Sigma detection logic triggered successfully
- evidence artifacts were preserved

---

# Evidence Collected

## Screenshots

Located in:

```text
evidence/systemd-service-persistence/
```

Artifacts include:
- service definition proof
- service enablement proof
- journal execution proof
- process lineage proof
- detection trigger proof
- cleanup verification proof

---

# Logs Collected

Located in:

```text
logs/systemd-service-persistence/
```

Artifacts include:
- journal logs
- process lineage
- service metadata
- daemon reload logs
- auditd execution logs
- restart events
- payload hashes
- service status logs

---

# Detection Artifacts

## Detection Logic

```text
detections/logic/systemd-service-persistence-logic.md
```

## Sigma Rule

```text
detections/sigma/linux/systemd_service_persistence.yml
```

## Validation

```text
detections/validation/systemd-service-persistence.md
```

---

# Investigation Artifacts

```text
investigations/systemd-service-persistence-investigation.md
```

---

# Sample Telemetry

Located in:

```text
samples/systemd-service-persistence/
```

Includes:
- sample alerts
- process creation events
- normalized detection fields
- triggered detection telemetry

---

# Example Normalized Alert

```json
{
  "AlertName": "Suspicious systemd Service Persistence via Interpreter Execution",
  "Severity": "High",
  "Technique": "T1543.002",
  "Host": "ubuntu-lab",
  "User": "root",
  "ParentImage": "/usr/lib/systemd/systemd",
  "Image": "/bin/bash",
  "CommandLine": "/bin/bash /home/user/updater.sh",
  "DetectionType": "Persistence",
  "Status": "Triggered"
}
```

---

# Key Detection Insights

This simulation demonstrates that:

- `systemd` is a powerful Linux persistence mechanism
- malicious services often abuse shell interpreters
- process lineage analysis is critical
- daemon reloads and service enablement generate useful telemetry
- Sigma rules can effectively identify suspicious persistence behavior

---

# Operational Detection Considerations

## High Fidelity Indicators

High-confidence indicators include:
- `systemd` spawning shell interpreters
- custom services executing scripts from user directories
- repeated service restart behavior
- suspicious `ExecStart` commands

---

## Potential False Positives

Potential legitimate activity may include:
- automation frameworks
- DevOps tooling
- maintenance scripts
- internal administration services

Detection tuning may require:
- allowlisting known services
- filtering trusted paths
- excluding approved automation tooling

---

# Cleanup Actions

Cleanup included:

```bash
sudo systemctl stop updater.service
sudo systemctl disable updater.service
sudo rm /etc/systemd/system/updater.service
sudo systemctl daemon-reload
```

Verification confirmed:
- service removal
- process termination
- persistence elimination

---

# Post-Cleanup Verification

## Verify Service Removal

```bash
systemctl list-unit-files | grep updater
```

---

## Verify Process Termination

```bash
ps aux | grep updater
```

---

## Verify No Residual Logs

```bash
journalctl | grep updater
```

---

# Learning Outcomes

This scenario improved understanding of:

- Linux persistence mechanisms
- `systemd` internals
- Linux telemetry collection
- detection engineering workflows
- process lineage analysis
- ATT&CK-aligned detection development
- Sigma rule validation
- evidence preservation techniques

---

# Repository Workflow Alignment

This simulation followed the repository engineering lifecycle:

```text
Simulation
    ↓
Telemetry Collection
    ↓
Investigation
    ↓
Threat Mapping
    ↓
Detection Logic Engineering
    ↓
Sigma Rule Development
    ↓
Validation
    ↓
Evidence Collection
    ↓
Sample Telemetry Creation
```

---

# Repository Structure Alignment

Relevant repository paths:

```text
detections/
investigations/
telemetry/
logs/
evidence/
samples/
scenarios/
```

---

# Recommended Evidence Screenshots

Recommended screenshots for documentation:

1. Service definition file
2. Service enablement confirmation
3. journalctl execution logs
4. Process lineage verification
5. Detection trigger output
6. Cleanup verification

---

# Scenario Status

| Scenario | Status |
|---|---|
| systemd Service Persistence | DONE |

---

# Final Conclusion

This simulation successfully demonstrated how adversaries can abuse Linux `systemd` services for persistence.

The exercise generated realistic operational telemetry and enabled:
- ATT&CK-aligned threat mapping
- process lineage investigation
- detection engineering
- Sigma rule validation
- evidence preservation
- structured detection lifecycle documentation

The scenario now serves as a reusable detection engineering lab for:
- Linux persistence analysis
- Sigma rule testing
- telemetry collection
- SOC investigation training
- adversary emulation workflows
