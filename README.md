# Detection Engineering Laboratory

## Overview

Detection Engineering Laboratory is a hands-on Linux detection engineering project focused on adversary simulation, telemetry collection, behavioral investigation, threat mapping, detection development, and evidence-driven validation.

The project recreates realistic ATT&CK-aligned adversary behaviors within a controlled Linux environment and follows a complete detection engineering lifecycle from attack execution through validated detection content.

Rather than beginning with detection rules, the laboratory begins with attacker behavior. Every scenario is executed, observed, investigated, mapped to known adversary tradecraft, and transformed into behavioral detections supported by evidence.

The repository serves both as a practical learning platform and as a portfolio demonstrating real-world detection engineering workflows.

---

# Project Objectives

This project aims to:

* Develop practical Linux detection engineering skills
* Study Linux telemetry visibility and limitations
* Simulate realistic attacker behaviors
* Perform telemetry-driven investigations
* Reconstruct attacker activity from evidence
* Map observations to MITRE ATT&CK
* Engineer behavioral detections
* Develop Sigma detection content
* Validate detections against collected evidence
* Build reusable detection engineering workflows
* Create a professional detection engineering portfolio

---

# Detection Engineering Methodology

Every scenario follows a structured evidence-driven workflow.

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
Detection Strategy Development
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
* Validation before deployment
* Session reconstruction
* Process lineage analysis
* Correlation-driven analytics
* Detections built from observed behavior

The objective is to understand attacker behavior before building detections.

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
├── samples/
│
├── scenarios/
│
├── scripts/
│
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

* Scheduled task persistence
* Cron-spawned process chains
* Long-term persistence visibility

---

## 2. Systemd Service Persistence

**ATT&CK**

* T1543.002 – Create or Modify System Process: Systemd Service

**Detection Focus**

* Service creation
* Service enablement
* Persistent execution

---

## 3. Reverse Shell Execution

**ATT&CK**

* T1059.004 – Unix Shell
* T1071 – Application Layer Protocol

**Detection Focus**

* Shell-to-network relationships
* Interactive command channels
* Process-network correlation

---

## 4. SSH Brute Force

**ATT&CK**

* T1110 – Brute Force

**Detection Focus**

* Authentication failures
* Threshold-based analytics
* PAM and SSH telemetry

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

* Discovery clustering
* Session reconstruction
* Reconnaissance analytics

---

## 6. Encoded Command Execution

**ATT&CK**

* T1059.004 – Unix Shell
* T1140 – Deobfuscate/Decode Files or Information
* T1027 – Obfuscated/Compressed Files and Information

**Detection Focus**

* Base64 decoding
* Payload reconstruction
* Obfuscated execution workflows

---

## 7. Rogue HTTP Server

**ATT&CK**

* T1105 – Ingress Tool Transfer

**Detection Focus**

* User-owned web services
* Payload staging infrastructure
* Local delivery mechanisms

---

## 8. Sudo Abuse for Privilege Escalation

**ATT&CK**

* T1548.003 – Sudo and Sudo Caching

**Detection Focus**

* Privilege escalation
* GTFOBins abuse
* Root shell creation

---

## 9. Data Staging and Compression

**ATT&CK**

* T1005 – Data from Local System
* T1074.001 – Local Data Staging
* T1560.001 – Archive Collected Data

**Detection Focus**

* Data aggregation
* Temporary staging directories
* Archive creation workflows
* Pre-exfiltration behavior

---

## 10. Beaconing / Periodic Callback

**ATT&CK**

* T1071 – Application Layer Protocol
* TA0011 – Command and Control

**Detection Focus**

* Periodic HTTP callbacks
* Long-lived controller processes
* Parent-child process lineage
* Beaconing correlation analytics

---

## 11. Suspicious File Download and Execution

**ATT&CK**

* T1105 – Ingress Tool Transfer
* T1059.004 – Unix Shell
* T1204 – User Execution

**Simulation Workflow**

```text
wget/curl
      ↓
Download to Temporary Directory
      ↓
chmod +x
      ↓
Payload Execution
      ↓
Child Process Activity
      ↓
Periodic Network Communication
```

**Detection Focus**

* Download-and-execute workflows
* Temporary directory execution
* Permission modification followed by execution
* Execution shortly after download
* Network beaconing after execution
* Multi-event behavioral correlation

**Telemetry Collected**

* Auditd EXECVE telemetry
* Process lineage
* Tcpdump packet captures
* HTTP access logs
* Session reconstruction artifacts

---

## 12. Log Tampering and Defense Evasion

**ATT&CK**

* T1070.001 – Clear Linux or Mac System Logs
* T1070.003 – Clear Command History
* T1562.001 – Impair Defenses

**Simulation Workflow**

```text
Payload Execution
        ↓
History Removal
        ↓
Authentication Log Tampering
        ↓
Logging Service Shutdown
```

**Detection Focus**

* Anti-forensics behavior
* Log destruction activity
* Shell history removal
* Logging suppression
* Multi-stage visibility reduction analytics
* Correlation-based detection engineering

**Telemetry Collected**

* Auditd process telemetry
* Journalctl service telemetry
* Process lineage
* Authentication log activity
* Session reconstruction evidence

---

# Detection Content

Each scenario produces a complete set of artifacts.

## Telemetry Analysis

Evaluates telemetry quality, visibility, and investigative value.

```text
telemetry/
```

## Investigation Reports

Reconstruct attacker activity and session flow.

```text
investigations/
```

## Threat Mapping

Maps observed behavior to known adversary tradecraft and ATT&CK techniques.

```text
docs/threat-mapping/
```

## Detection Logic

Documents behavioral detection strategies.

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

Sample alerts, timelines, process chains, trigger evidence, and screenshots.

```text
evidence/
```

---

# Telemetry Sources

Current telemetry collection includes:

* Auditd EXECVE telemetry
* Auditd SYSCALL telemetry
* Sysmon for Linux
* Journalctl
* Auth.log
* PAM authentication logs
* SSH telemetry
* Process creation telemetry
* Parent-child process lineage
* Cron telemetry
* Systemd telemetry
* HTTP access logs
* Network connection telemetry
* TCP packet captures
* Temporary file activity
* Session reconstruction artifacts

---

# ATT&CK Coverage

## Execution

* T1059.004 – Unix Shell

## Persistence

* T1053.003 – Cron
* T1543.002 – Systemd Service

## Privilege Escalation

* T1548.003 – Sudo and Sudo Caching

## Defense Evasion

* T1027 – Obfuscated/Compressed Files and Information
* T1140 – Deobfuscate/Decode Files or Information
* T1070.001 – Clear Linux Logs
* T1070.003 – Clear Command History
* T1562.001 – Impair Defenses

## Discovery

* T1033 – System Owner/User Discovery
* T1057 – Process Discovery
* T1049 – Network Connections Discovery
* T1082 – System Information Discovery
* T1016 – Network Configuration Discovery
* T1007 – Service Discovery
* T1083 – File and Directory Discovery

## Credential Access

* T1110 – Brute Force

## Collection

* T1005 – Data from Local System
* T1074.001 – Local Data Staging
* T1560.001 – Archive Collected Data

## Command and Control

* T1071 – Application Layer Protocol

## Ingress Tool Transfer

* T1105 – Ingress Tool Transfer

---

# Evidence-Driven Validation

Every scenario includes validation against collected evidence.

Artifacts include:

* Raw telemetry
* Session reconstructions
* Process lineage analysis
* Investigation reports
* Threat mapping reports
* Detection trigger evidence
* Sample alerts
* Timeline reconstruction
* Network captures
* Validation reports

Detections are validated against observed activity rather than assumptions.

---

# Technology Stack

## Platform

* Ubuntu Linux

## Telemetry Collection

* Auditd
* Sysmon for Linux
* Journalctl
* Auth.log
* PAM
* Tcpdump

## Detection Engineering

* Sigma
* MITRE ATT&CK
* Behavioral Analytics
* Correlation Analytics
* Session Reconstruction
* Process Lineage Analysis

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
Completed Scenarios      : 12
Telemetry Analyses       : 12
Investigation Reports    : 12
Threat Mapping Reports   : 12
Detection Logic Reports  : 12
Validation Reports       : 12
Sigma Rules              : 12+
Evidence Collections     : 12
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

The laboratory focuses on understanding:

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
Completed Scenarios : 12
Validation Status   : All Scenarios Validated
Primary Platform    : Linux
Detection Framework : Sigma
Methodology         : Evidence-Driven Detection Engineering
```

The laboratory continues to expand through ATT&CK-aligned adversary simulations, telemetry studies, behavioral investigations, detection development, and validation-driven detection engineering.

