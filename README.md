# Detection Engineering Laboratory

## Overview

Detection Engineering Laboratory is a hands-on Linux detection engineering repository focused on adversary simulation, telemetry collection, behavioral investigation, threat mapping, detection development, and evidence-driven validation.

The project recreates realistic ATT&CK-aligned adversary behaviors within a controlled Linux environment and follows a complete detection engineering lifecycle from attack execution through validated detection content.

Unlike rule-centric repositories, this laboratory prioritizes understanding attacker behavior through telemetry analysis, reconstructing activity through investigation, mapping observations to MITRE ATT&CK, and engineering detections directly from observed evidence.

Each scenario is treated as a complete detection engineering case study and produces:

* Telemetry Analysis
* Investigation Report
* Threat Mapping
* Detection Logic
* Sigma Rule
* Validation Report
* Sample Detection Artifacts
* Evidence Collection

The objective is to build practical detection engineering skills while creating a portfolio of realistic Linux detection content grounded in observable telemetry and validated behaviors.

---

# Project Objectives

This repository aims to:

* Develop practical Linux detection engineering skills
* Simulate realistic adversary tradecraft
* Study Linux telemetry visibility and limitations
* Perform telemetry-driven investigations
* Reconstruct attacker activity from evidence
* Map observed behaviors to MITRE ATT&CK
* Engineer behavioral detections
* Develop Sigma detection content
* Validate detections against observed activity
* Build a reusable Linux detection engineering methodology
* Create a professional detection engineering portfolio

---

# Detection Engineering Methodology

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

Core Principles:

* Telemetry-first analysis
* Evidence-backed investigation
* Behavioral detection engineering
* ATT&CK alignment
* Detection validation
* Process lineage analysis
* Session reconstruction
* Correlation-driven analytics

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
├──samples/
│
├── scenarios/
│
├── scripts/
|
├── telemetry/
│
└── README.md
```

---

# Completed Detection Scenarios

## 1. Cron Persistence

**ATT&CK**

* T1053.003 – Scheduled Task/Job: Cron

**Detection Focus**

* Cron execution telemetry
* Scheduled task persistence
* Cron-spawned process chains
* Long-term persistence detection

---

## 2. Systemd Service Persistence

**ATT&CK**

* T1543.002 – Create or Modify System Process: Systemd Service

**Detection Focus**

* Service creation
* Service enablement
* Daemon reload activity
* Persistent service execution

---

## 3. Reverse Shell Execution

**ATT&CK**

* T1059.004 – Unix Shell
* T1071 – Application Layer Protocol

**Detection Focus**

* Shell-to-network relationships
* Interactive shell activity
* Outbound command channels
* Process and network correlation

---

## 4. SSH Brute Force

**ATT&CK**

* T1110 – Brute Force

**Detection Focus**

* Authentication failures
* PAM telemetry
* Invalid user activity
* Threshold-based detections

---

## 5. Suspicious Enumeration Activity

**ATT&CK**

* T1033 – System Owner/User Discovery
* T1057 – Process Discovery
* T1049 – System Network Connections Discovery
* T1082 – System Information Discovery
* T1016 – Network Configuration Discovery
* T1007 – Service Discovery
* T1083 – File and Directory Discovery

**Detection Focus**

* Host reconnaissance
* Session correlation
* Discovery clustering
* Behavioral scoring

---

## 6. Encoded Command Execution

**ATT&CK**

* T1059.004 – Unix Shell
* T1140 – Deobfuscate/Decode Files or Information
* T1027 – Obfuscated/Compressed Files and Information

**Variants**

* Direct Pipe Execution
* Payload Reconstruction
* Python Decoder
* Multi-Stage Decode

**Detection Focus**

* Base64 decoding activity
* Multi-stage decode chains
* Payload reconstruction workflows
* Obfuscated execution detection

---

## 7. Rogue HTTP Server

**ATT&CK**

* T1105 – Ingress Tool Transfer
* T1059.004 – Unix Shell

**Detection Focus**

* User-owned listening services
* Python HTTP server execution
* Payload staging
* Download-and-execute workflows

---

## 8. Sudo Abuse for Privilege Escalation

**ATT&CK**

* T1548.003 – Sudo and Sudo Caching
* T1059.004 – Unix Shell

**Detection Focus**

* Sudo privilege enumeration
* GTFOBins abuse
* Find-to-bash execution chains
* Root shell creation

---

## 9. Data Staging and Compression

**ATT&CK**

* T1083 – File and Directory Discovery
* T1005 – Data from Local System
* T1074.001 – Local Data Staging
* T1560.001 – Archive Collected Data via Utility

**Detection Focus**

* File discovery
* Data aggregation
* Temporary staging directories
* Archive creation
* Compression workflows
* Pre-exfiltration analytics

---

## 10. Beaconing / Periodic Callback

**ATT&CK**

* T1071 – Application Layer Protocol
* TA0011 – Command and Control

**Simulation Workflow**

```text
bash
 ├── curl http://127.0.0.1:8080/checkin
 └── sleep 60
```

repeating for approximately twenty minutes.

**Detection Focus**

* Periodic HTTP callbacks
* Repeated process execution
* Common process lineage
* Consistent destination targeting
* Long-lived controller processes
* Beaconing correlation analytics

**Telemetry Collected**

* Auditd EXECVE telemetry
* Sysmon Process Creation telemetry
* Parent-child process lineage
* HTTP server access logs
* Session reconstruction artifacts

---

# Detection Content

Each scenario contains:

## Telemetry Analysis

Visibility assessment, telemetry quality analysis, and evidence review.

```text
telemetry/
```

## Investigation Reports

Behavioral reconstruction and attacker workflow analysis.

```text
investigations/
```

## ATT&CK Threat Mapping

Behavior-to-technique mapping and threat assessment.

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
detections/sigma/
```

## Validation Reports

Evidence-backed validation and false-positive assessment.

```text
detections/validation/
```

## Detection Artifacts

Sample alerts, process chains, timelines, screenshots, and trigger evidence.

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
* Session reconstruction artifacts
* Network connection telemetry
* HTTP access logs
* TCP packet captures

---

# ATT&CK Coverage

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

## Defense Evasion

* T1027 – Obfuscated/Compressed Files and Information
* T1140 – Deobfuscate/Decode Files or Information

---

# Evidence-Driven Validation

Every scenario includes validation against collected evidence.

Artifacts include:

* Auditd telemetry
* Sysmon telemetry
* Raw process events
* Session reconstructions
* Process chain analysis
* Detection trigger evidence
* Timeline reconstruction
* Authentication logs
* Network captures
* Sample alerts
* Validation reports

Detections are validated against observed activity rather than assumptions.

---

# Technology Stack

## Platform

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
* Correlation Analytics
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
Completed Scenarios      : 10
Telemetry Analyses       : 10
Investigation Reports    : 10
Threat Mapping Reports   : 10
Detection Logic Reports  : 10
Validation Reports       : 10
Sigma Rules              : 10+
Evidence Collections     : 10
ATT&CK Techniques Covered: 20+
Primary Telemetry        : Auditd + Sysmon for Linux
```

---

# Future Roadmap

Planned areas of expansion:

* SUID Abuse
* Credential Dumping
* Service Abuse
* Linux Malware Persistence
* Lateral Movement
* Defense Evasion
* Container Security Detection
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

The goal is to develop practical detection engineering expertise through repeatable adversary simulation and evidence-driven analysis.

---

# Current Status

```text
Project Status      : Active Development
Completed Scenarios : 10
Validation Status   : All Scenarios Validated
Primary Platform    : Linux
Detection Framework : Sigma
Methodology         : Evidence-Driven Detection Engineering
```

The laboratory continues to expand through ATT&CK-aligned adversary simulations, telemetry studies, behavioral investigations, detection development, and validation-driven detection engineering.

