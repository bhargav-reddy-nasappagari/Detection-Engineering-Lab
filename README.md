# Detection Engineering Repository

## Overview

This repository contains adversary simulations, telemetry analysis, threat investigations, and detection engineering artifacts focused on Linux-based attack techniques.

The project is designed to simulate realistic attacker behaviors, analyze resulting telemetry, and engineer detections aligned with MITRE ATT&CK methodologies.

---

# Objectives

- Develop practical detection engineering skills
- Simulate Linux persistence techniques
- Analyze process and system telemetry
- Create ATT&CK-aligned detection logic
- Build Sigma detection rules
- Validate detections using collected evidence
- Document the complete detection lifecycle

---

# Repository Structure

```text
.
├── detections/
├── docs/
├── investigations/
├── logs/
├── notes/
├── rules/
├── samples/
├── scenarios/
├── scripts/
└── telemetry/
```

---

# Detection Engineering Workflow

```text
Attack Simulation
        ↓
Telemetry Collection
        ↓
Threat Investigation
        ↓
Threat Mapping
        ↓
Detection Logic Engineering
        ↓
Sigma Rule Creation
        ↓
Detection Validation
        ↓
Tuning & Improvements
```

---

# Simulations Covered

## 1. Linux Cron Persistence

Technique:
- Scheduled Task/Job: Cron

MITRE ATT&CK:
- T1053.003

Scenario:
- A cron job executes a shell script periodically to simulate persistence behavior.

Detection Focus:
- cron spawning shell interpreters
- suspicious script execution
- recurring execution behavior

Artifacts:
- telemetry analysis
- investigation report
- Sigma detection rule
- validation documentation

---

## 2. Rogue HTTP Server

Scenario:
- Unauthorized local HTTP service execution on Linux.

Detection Focus:
- suspicious listening services
- unexpected process bindings
- local web server telemetry

Artifacts:
- process investigation
- telemetry observations
- detection notes

---

# Detection Artifacts

## Detection Logic
Contains engineering rationale behind detection development.

Location:
```text
detections/logic/
```

## Sigma Rules
Platform-agnostic detection rules.

Location:
```text
detections/sigma/
```

## Validation Reports
Detection testing and verification results.

Location:
```text
detections/validation/
```

---

# Telemetry Sources

Telemetry observed and analyzed includes:

- process creation events
- parent-child process relationships
- cron execution behavior
- shell interpreter execution
- file modification activity
- recurring scheduled execution patterns

Potential telemetry providers:
- auditd
- Sysmon for Linux
- Elastic Defend
- Microsoft Defender for Endpoint

---

# Tools & Technologies

- Linux
- Bash
- cron
- Sigma
- process telemetry analysis
- MITRE ATT&CK framework

---

# Future Improvements

Planned additions:

- systemd persistence detection
- reverse shell detections
- privilege escalation scenarios
- network beaconing analytics
- SIEM correlation rules
- alert triage workflows
- Sigma rule tuning
- ATT&CK coverage mapping

---

# Project Goal

The goal of this repository is to develop operationally realistic detection engineering skills through hands-on simulation, telemetry analysis, and detection validation workflows.
