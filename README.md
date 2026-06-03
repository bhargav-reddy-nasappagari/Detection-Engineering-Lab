# Detection Engineering Laboratory

## Overview

Detection Engineering Laboratory is a hands-on Linux detection engineering platform focused on adversary simulation, telemetry collection, behavioral analysis, investigation, threat mapping, detection development, and evidence-driven validation.

The project recreates realistic ATT&CK-aligned adversary behaviors within a controlled Linux environment and follows a complete detection engineering lifecycle from attack execution through validated detection content.

Unlike traditional detection repositories that focus primarily on rule creation, this laboratory emphasizes understanding attacker behavior through telemetry, reconstructing activity through investigation, mapping observations to MITRE ATT&CK, and engineering detections from evidence.

Every completed scenario produces:

* Telemetry Analysis
* Investigation Report
* Threat Mapping
* Detection Logic
* Sigma Rule
* Validation Report
* Sample Detection Artifacts
* Evidence Collection

The result is a repeatable and evidence-backed detection engineering workflow that mirrors real-world security operations and detection development practices.

---

# Project Objectives

The objectives of this repository are to:

* Develop practical Linux detection engineering skills
* Simulate realistic adversary tradecraft
* Study Linux telemetry visibility and limitations
* Perform telemetry-first investigations
* Reconstruct attacker activity from evidence
* Map observed behavior to MITRE ATT&CK
* Engineer behavioral detections from telemetry
* Develop Sigma detection content
* Validate detections against observed activity
* Build a reusable Linux detection engineering methodology
* Create a practical detection engineering portfolio

---

# Detection Engineering Workflow

Every scenario follows the same evidence-driven workflow.

```text
Attack Simulation
        ↓
Baseline Collection
        ↓
Telemetry Collection
        ↓
Telemetry Analysis
        ↓
Investigation & Reconstruction
        ↓
Threat Mapping
        ↓
Detection Logic Engineering
        ↓
Sigma Rule Development
        ↓
Detection Validation
        ↓
Evidence Collection
        ↓
Scenario Documentation
```

Core principles:

* Telemetry-first analysis
* Evidence-backed investigation
* Behavioral detection engineering
* ATT&CK alignment
* Detection validation
* Process lineage analysis
* Session reconstruction

The objective is to understand behavior before building detections.

---

# Repository Structure

```text
.
├── detections/
│   ├── logic/
│   ├── sigma/
│   └── validation/
│
├── docs/
│   └── threat-mapping/
│
├── evidence/
│   
├── investigations/
│
├── logs/
│
├── notes/
│
├── samples/
│
├── scenarios/
│
├── telemetry/
│
└── README.md
```

---

# Completed Detection Scenarios

## 1. Cron Persistence

### ATT&CK

* T1053.003 – Scheduled Task/Job: Cron

### Detection Focus

* Cron execution telemetry
* Scheduled task persistence
* Cron-spawned process chains
* Long-term persistence detection

---

## 2. Systemd Service Persistence

### ATT&CK

* T1543.002 – Create or Modify System Process: Systemd Service

### Detection Focus

* Service creation
* Service enablement
* Daemon reload activity
* Persistent service execution

---

## 3. Reverse Shell Execution

### ATT&CK

* T1059.004 – Unix Shell
* T1071 – Application Layer Protocol

### Detection Focus

* Shell-to-network relationships
* Interactive shell activity
* Outbound command channels
* Process and network correlation

---

## 4. SSH Brute Force

### ATT&CK

* T1110 – Brute Force

### Detection Focus

* Authentication failures
* PAM telemetry
* Invalid user activity
* Threshold-based detections

---

## 5. Suspicious Enumeration Activity

### ATT&CK

* T1033 – System Owner/User Discovery
* T1057 – Process Discovery
* T1049 – System Network Connections Discovery
* T1082 – System Information Discovery
* T1016 – Network Configuration Discovery
* T1007 – Service Discovery
* T1083 – File and Directory Discovery

### Detection Focus

* Host reconnaissance
* Session correlation
* Discovery command clustering
* Behavioral scoring

---

## 6. Encoded Command Execution

### ATT&CK

* T1059.004 – Unix Shell
* T1140 – Deobfuscate/Decode Files or Information
* T1027 – Obfuscated/Compressed Files and Information

### Variants

#### Variant 1 – Direct Pipe Execution

```text
bash
  ↓
base64
  ↓
bash
```

#### Variant 2 – Payload Reconstruction

```text
base64
  ↓
file reconstruction
  ↓
chmod
  ↓
execution
```

#### Variant 3 – Python Decoder

```text
bash
  ↓
python3
  ↓
decoded payload
```

#### Variant 4 – Multi-Stage Decode

```text
bash
  ↓
base64
  ↓
base64
  ↓
bash
```

### Detection Focus

* Base64 decoding activity
* Multi-stage decode chains
* Python-based payload execution
* Process lineage reconstruction

---

## 7. Rogue HTTP Server

### ATT&CK

* T1105 – Ingress Tool Transfer
* T1059.004 – Unix Shell

### Detection Focus

* Python HTTP server execution
* User-owned listening services
* Payload staging
* Download-and-execute workflows

---

## 8. Sudo Abuse for Privilege Escalation

### ATT&CK

* T1548.003 – Sudo and Sudo Caching
* T1059.004 – Unix Shell

### Attack Workflow

```text
sudo -l
        ↓
sudo find . -exec /bin/bash \; -quit
        ↓
root shell
        ↓
whoami
id
hostname
```

### Detection Focus

* Sudo privilege enumeration
* GTFOBins abuse
* Find-to-bash process chains
* Root shell creation

---

## 9. Data Staging and Compression

### ATT&CK

* T1083 – File and Directory Discovery
* T1005 – Data from Local System
* T1074.001 – Local Data Staging
* T1560.001 – Archive Collected Data via Utility

### Attack Workflow

```text
File Discovery
        ↓
Local Staging
        ↓
Data Collection
        ↓
Archive Creation
        ↓
Archive Validation
```

### Simulated Activity

```text
find
        ↓
mkdir /tmp/archive_stage
        ↓
cp
        ↓
tar -czf
        ↓
gzip
        ↓
tar -tzf
```

### Detection Focus

* Discovery of sensitive file types
* Temporary staging directory creation
* File aggregation behavior
* Archive creation using native utilities
* Compression workflow detection
* Pre-exfiltration behavioral analytics

---

# Detection Content

Each completed scenario contains:

## Telemetry Analysis

Observed telemetry, visibility assessment, and investigative breakdown.

```text
telemetry/
```

## Investigation Reports

Behavioral reconstruction and attacker workflow analysis.

```text
investigations/
```

## ATT&CK Threat Mapping

Behavior-to-technique mapping.

```text
docs/threat-mapping/
```

## Detection Logic

Behavioral detection strategy and analytic development.

```text
detections/logic/
```

## Sigma Rules

Platform-agnostic detection content.

```text
detections/sigma/linux/
```

## Validation Reports

Evidence-backed validation.

```text
detections/validation/
```

## Detection Artifacts

Example alerts, raw events, process chains, trigger evidence, and screenshots.

```text
evidence/
```

---

# Telemetry Sources

Current telemetry collection includes:

* Auditd EXECVE telemetry
* Auditd SYSCALL telemetry
* Sysmon for Linux
* Auth.log
* PAM authentication logs
* Journalctl
* Process creation telemetry
* Parent-child process lineage
* Cron telemetry
* Systemd telemetry
* SSH telemetry
* Temporary file activity
* Session reconstruction data
* Network connection telemetry
* TCP packet captures

---

# ATT&CK Coverage

Current ATT&CK coverage includes:

## Execution

* T1059.004 – Unix Shell

## Persistence

* T1053.003 – Cron
* T1543.002 – Systemd Service

## Discovery

* T1033 – System Owner/User Discovery
* T1057 – Process Discovery
* T1049 – System Network Connections Discovery
* T1082 – System Information Discovery
* T1016 – Network Configuration Discovery
* T1007 – Service Discovery
* T1083 – File and Directory Discovery

## Credential Access

* T1110 – Brute Force

## Privilege Escalation

* T1548.003 – Sudo and Sudo Caching

## Collection

* T1005 – Data from Local System
* T1074.001 – Local Data Staging
* T1560.001 – Archive Collected Data via Utility

## Command and Control

* T1071 – Application Layer Protocol
* T1105 – Ingress Tool Transfer

## Defense Evasion / Obfuscation

* T1027 – Obfuscated/Compressed Files and Information
* T1140 – Deobfuscate/Decode Files or Information

---

# Evidence-Driven Validation

Every scenario includes validation artifacts collected during execution.

Examples:

* Auditd telemetry
* Sysmon telemetry
* Process creation events
* Detection trigger evidence
* Session reconstructions
* Attack timelines
* Authentication logs
* Network captures
* Service execution evidence
* Privilege escalation proof
* Sample alerts
* Process chain reconstructions

Detections are validated against observed behavior rather than assumptions.

---

# Technology Stack

## Operating System

* Ubuntu Linux

## Telemetry Collection

* Auditd
* Sysmon for Linux
* Auth.log
* PAM
* Journalctl

## Detection Engineering

* Sigma
* MITRE ATT&CK
* Behavioral Analytics
* Process Lineage Analysis
* Session Reconstruction

## Adversary Simulation

* Bash
* Python
* Cron
* Systemd
* SSH
* Base64
* HTTP Services
* GTFOBins
* Native Linux Utilities

---

# Current Project Statistics

```text
Completed Scenarios      : 9
Detection Logic Reports  : 9
Threat Mapping Reports   : 9
Investigation Reports    : 9
Validation Reports       : 9
Sigma Rules              : 9
Evidence Collections     : 9
ATT&CK Techniques Covered: 18+
Telemetry Sources        : Auditd + Sysmon + Native Linux Logs
```

---

# Future Roadmap

Planned areas of expansion:

* Defense Evasion
* SUID Abuse
* Credential Dumping
* Linux Malware Persistence
* Service Abuse
* Container Security Detection
* Lateral Movement
* ATT&CK Coverage Matrix
* Detection Severity Framework
* Automated Validation Pipelines
* Elastic Detection Content
* Wazuh Detection Content
* Threat Hunting Playbooks

---

# Project Philosophy

> Reliable detections are engineered from telemetry, investigation, behavioral analysis, and validation—not from signatures alone.

This laboratory focuses on understanding:

* How attacks behave
* How telemetry captures behavior
* How investigations reconstruct activity
* How ATT&CK techniques manifest on Linux
* How detections are engineered
* How detections are validated

The goal is to build practical detection engineering expertise through repeatable adversary simulation and evidence-driven analysis.

---

# Current Status

```text
Project Status      : Active Development
Completed Scenarios : 9
Validation Status   : All Scenarios Validated
Primary Platform    : Linux
Detection Framework : Sigma
Methodology         : Evidence-Driven Detection Engineering
```

The laboratory continues to expand through ATT&CK-aligned adversary simulations, telemetry studies, behavioral investigations, detection content development, and validation-driven detection engineering.

