# Detection Engineering Laboratory

## Overview

Detection Engineering Laboratory is a hands-on Linux detection engineering platform focused on adversary simulation, telemetry collection, behavioral analysis, investigation, threat mapping, detection development, and validation.

The project recreates realistic attacker techniques within a controlled Linux environment and follows a complete detection engineering lifecycle from attack execution through validated detection content.

Rather than focusing exclusively on rule writing, the laboratory emphasizes understanding how attacker behavior manifests in telemetry, how investigations reconstruct activity, how ATT&CK techniques can be identified through observable artifacts, and how reliable detections are engineered from evidence.

Every scenario follows the same workflow and produces telemetry reports, investigation findings, ATT&CK mappings, detection logic, Sigma rules, validation reports, supporting evidence, and sample detection artifacts.

---

# Project Objectives

The objectives of this repository are to:

* Develop practical Linux detection engineering skills.
* Simulate realistic attacker behaviors.
* Understand Linux telemetry sources and visibility gaps.
* Analyze process lineage and execution behavior.
* Reconstruct attacker activity from collected evidence.
* Map observed behavior to MITRE ATT&CK.
* Engineer behavioral detections from real telemetry.
* Develop platform-agnostic Sigma detections.
* Validate detections against observed attack activity.
* Build a reusable ATT&CK-aligned detection engineering workflow.
* Create a practical detection engineering portfolio.

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
Detection Logic Analysis
        ↓
Sigma Rule Engineering
        ↓
Detection Validation
        ↓
Evidence Collection
        ↓
Scenario Documentation
```

The workflow prioritizes:

* Telemetry-first analysis
* Behavioral detection engineering
* Process lineage reconstruction
* Session reconstruction
* ATT&CK alignment
* Detection validation
* Evidence-backed conclusions

The goal is to understand attacker behavior before writing detections.

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

### Scenario Summary

Simulates persistence through recurring cron job execution.

### Detection Focus

* Scheduled task execution
* Cron-spawned shell activity
* Recurring process execution
* Long-lived persistence behavior

---

## 2. Systemd Service Persistence

### ATT&CK

* T1543.002 – Create or Modify System Process: Systemd Service

### Scenario Summary

Simulates persistence through creation and enablement of a malicious systemd service.

### Detection Focus

* Service creation
* Service enablement
* Daemon reload activity
* Persistent service execution
* Systemd-backed payload execution

---

## 3. Reverse Shell Execution

### ATT&CK

* T1059.004 – Unix Shell
* T1071 – Application Layer Protocol

### Scenario Summary

Simulates outbound reverse shell communication and remote command execution.

### Detection Focus

* Shell-to-network relationships
* Interactive shell execution
* Outbound command channels
* Process and network correlation

---

## 4. SSH Brute Force

### ATT&CK

* T1110 – Brute Force

### Scenario Summary

Simulates repeated SSH authentication failures and password guessing behavior.

### Detection Focus

* Authentication failures
* PAM authentication telemetry
* Invalid user activity
* Threshold-based detection logic

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

### Scenario Summary

Simulates structured post-compromise host reconnaissance.

### Detection Focus

* Discovery command execution
* Session correlation
* Temporal clustering
* Behavioral scoring
* Reconnaissance activity detection

---

## 6. Encoded Command Execution

### ATT&CK

* T1059.004 – Unix Shell
* T1140 – Deobfuscate/Decode Files or Information
* T1027 – Obfuscated/Compressed Files and Information

### Scenario Summary

Simulates execution of Base64-encoded payloads through multiple execution methods.

### Variants

#### Variant 1 – Direct Pipe Execution

```text
bash
  ↓
base64
  ↓
bash
```

#### Variant 2 – File Reconstruction

```text
base64
  ↓
payload reconstruction
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
* Multi-stage decoding chains
* Python-based payload execution
* Temporary payload reconstruction
* Process lineage reconstruction

---

## 7. Rogue HTTP Server

### ATT&CK

* T1105 – Ingress Tool Transfer
* T1059.004 – Unix Shell

### Scenario Summary

Simulates an attacker-hosted HTTP server used to stage and deliver payloads to a victim system.

### Detection Focus

* Python HTTP server execution
* User-owned listening services
* Payload delivery behavior
* Download-and-execute workflows
* Network and process correlation

---

## 8. Sudo Abuse for Privilege Escalation

### ATT&CK

* T1548.003 – Sudo and Sudo Caching
* T1059.004 – Unix Shell
* T1033 – System Owner/User Discovery
* T1082 – System Information Discovery

### Scenario Summary

Simulates abuse of sudo-authorized binaries to obtain root access through GTFOBins techniques.

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
* Find-to-bash process relationships
* Root shell creation
* Privilege escalation telemetry

---

# Detection Content

Each completed scenario produces:

## Telemetry Analysis

Observed telemetry, visibility assessment, and investigation-oriented breakdown.

```text
telemetry/
```

## Investigation Reports

Session reconstruction and behavioral analysis.

```text
investigations/
```

## ATT&CK Threat Mapping

Mapping of observed behaviors to known adversary techniques.

```text
docs/threat-mapping/
```

## Detection Logic

Detection engineering rationale and behavioral logic derivation.

```text
detections/logic/
```

## Sigma Rules

Platform-agnostic detection content.

```text
detections/sigma/linux/
```

## Validation Reports

Evidence-backed detection validation.

```text
detections/validation/
```

## Detection Samples

Example alerts, process events, process chains, detection triggers, and validation artifacts.

```text
samples/
```

---

# Telemetry Sources

Current telemetry sources include:

* Auditd EXECVE telemetry
* Sysmon for Linux process events
* SSH authentication logs
* PAM authentication logs
* Auth.log
* Journalctl
* Process creation telemetry
* Parent-child process lineage
* Service management telemetry
* Cron execution telemetry
* Temporary file activity
* Session reconstruction data
* Network connection telemetry
* TCP packet captures

---

# Detection Engineering Topics Covered

The repository currently covers:

## Execution

* Reverse shells
* Encoded command execution
* Rogue HTTP server activity

## Persistence

* Cron persistence
* Systemd service persistence

## Discovery

* Host reconnaissance
* User discovery
* Process discovery
* Service discovery
* Network discovery

## Credential Access

* SSH brute force

## Privilege Escalation

* Sudo abuse
* GTFOBins techniques

## Detection Engineering

* Telemetry analysis
* Investigation workflows
* ATT&CK mapping
* Sigma rule development
* Detection validation
* Process lineage analysis
* Session reconstruction

---

# Evidence-Driven Validation

Every completed scenario contains validation artifacts collected during execution.

Examples include:

* Auditd telemetry
* Sysmon telemetry
* Process lineage screenshots
* Detection trigger evidence
* Session reconstructions
* Attack timelines
* Authentication logs
* Network captures
* Service execution proof
* Privilege escalation proof

The objective is to validate detections using observed behavior rather than assumptions.

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
* GTFOBins Techniques

---

# Current Project Statistics

```text
Completed Scenarios      : 8
Sigma Rules              : 8
Detection Logic Reports  : 8
Validation Reports       : 8
Investigation Reports    : 8
Threat Mapping Reports   : 8
Telemetry Reports        : 8
Evidence Collections     : 8
ATT&CK Techniques Covered: 15+
```

---

# Future Roadmap

Planned future work includes:

* Defense evasion techniques
* Credential dumping simulations
* Linux malware persistence
* Service abuse techniques
* SUID abuse scenarios
* Container security detections
* Lateral movement simulations
* ATT&CK coverage matrix
* Detection severity framework
* Automated validation workflows
* Elastic detection content
* Wazuh detection content
* Threat hunting playbooks

---

# Project Philosophy

> Reliable detections are engineered from telemetry, investigation, behavioral analysis, and validation—not from signatures alone.

This repository focuses on understanding:

* How attacks behave
* How telemetry captures behavior
* How investigations reconstruct activity
* How ATT&CK techniques manifest on Linux
* How detections are engineered
* How detections are validated

The objective is to develop practical detection engineering expertise through repeatable adversary simulation and evidence-driven analysis.

---

# Current Status

```text
Project Status      : Active Development
Completed Scenarios : 8
Validation Status   : All Scenarios Validated
Primary Platform    : Linux
Detection Framework : Sigma
Methodology         : Evidence-Driven Detection Engineering
```

The laboratory continues to expand through new ATT&CK-aligned attack simulations, telemetry studies, detection content, and validation workflows.

