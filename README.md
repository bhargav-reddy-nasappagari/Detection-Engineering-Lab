# Detection Engineering Repository

## Overview

This repository is a hands-on Linux detection engineering laboratory focused on adversary simulation, telemetry analysis, behavioral investigation, and ATT&CK-aligned detection development.

The project recreates realistic attacker behaviors in a controlled Linux environment and follows the complete detection engineering lifecycle:

* attack simulation
* telemetry acquisition
* investigation and reconstruction
* threat mapping
* detection logic engineering
* Sigma rule development
* validation and tuning
* evidence collection
* documentation

The repository emphasizes behavioral detection engineering rather than signature-only detections.

---

# Project Goals

## Core Objectives

* Develop operational detection engineering skills
* Simulate realistic Linux attack techniques
* Analyze Linux process and system telemetry
* Engineer behavioral detections
* Build ATT&CK-aligned Sigma rules
* Perform telemetry-driven investigations
* Validate detections using collected evidence
* Create reusable detection engineering workflows

---

# Detection Engineering Methodology

The repository follows a structured workflow modeled after real-world SOC and threat detection pipelines.

```text
Attack Simulation
        ↓
Baseline Collection
        ↓
Telemetry Acquisition
        ↓
Threat Investigation
        ↓
Behavioral Reconstruction
        ↓
Threat Mapping (MITRE ATT&CK)
        ↓
Detection Logic Engineering
        ↓
Sigma Rule Development
        ↓
Validation & Evidence Collection
        ↓
Tuning & Improvement
```

The project intentionally prioritizes:

* telemetry context
* behavioral analytics
* process lineage analysis
* session correlation
* investigation methodology
* operational realism

rather than simplistic IOC-only detections.

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
├── rules/
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

### MITRE ATT&CK

* T1053.003 — Scheduled Task/Job: Cron

### Scenario

A recurring cron job executes a shell payload to simulate Linux persistence.

### Detection Focus

* cron spawning shell interpreters
* suspicious script execution
* recurring process execution
* scheduled persistence behavior
* parent-child process lineage

### Artifacts Produced

* telemetry analysis
* investigation report
* ATT&CK mapping
* detection logic
* Sigma rule
* validation report
* process evidence
* sample detection events

---

## 2. Systemd Service Persistence

### MITRE ATT&CK

* T1543.002 — Create or Modify System Process: Systemd Service

### Scenario

A malicious systemd service is created and enabled to simulate persistent execution across reboot cycles.

### Detection Focus

* suspicious service creation
* service enablement activity
* daemon reload execution
* malicious script execution via systemd
* persistence through service units

### Telemetry Observed

* `systemctl enable`
* `daemon-reload`
* service file creation
* recurring service execution
* parent-child process lineage

### Artifacts Produced

* service telemetry analysis
* investigation report
* ATT&CK mapping
* Sigma rule
* validation workflow
* evidence screenshots
* raw auditd logs
* sample detection events

---

## 3. Reverse Shell Execution

### MITRE ATT&CK

* T1059 — Command and Scripting Interpreter
* T1071 — Application Layer Protocol
* T1105 — Ingress Tool Transfer (behaviorally related)

### Scenario

A reverse shell connection is established from the victim machine to an external listener to simulate interactive remote command execution.

### Detection Focus

* shell spawning network connections
* suspicious outbound connections
* shell-to-network behavioral correlation
* bash spawning network utilities
* interactive command execution

### Telemetry Observed

* outbound TCP connections
* shell interpreter execution
* process lineage
* listener activity
* auditd EXECVE telemetry

### Artifacts Produced

* telemetry report
* investigation workflow
* Sigma rule
* validation report
* process lineage evidence
* network evidence
* normalized sample events
* sample alerts

---

## 4. SSH Brute Force

### MITRE ATT&CK

* T1110 — Brute Force

### Scenario

Repeated SSH authentication attempts are generated to simulate credential brute force activity against a Linux SSH service.

### Detection Focus

* repeated authentication failures
* PAM authentication events
* invalid user attempts
* connection termination behavior
* threshold-based detection correlation

### Telemetry Observed

* `/var/log/auth.log`
* PAM failures
* SSH daemon logs
* disconnect events
* authentication telemetry
* packet capture evidence

### Artifacts Produced

* detection logic
* Sigma rule
* validation report
* PCAP evidence
* authentication telemetry
* sample alert events
* aggregated detection fields

---

## 5. Suspicious Enumeration Activity

### MITRE ATT&CK

* T1082 — System Information Discovery
* T1033 — System Owner/User Discovery
* T1057 — Process Discovery
* T1049 — System Network Connections Discovery
* T1016 — System Network Configuration Discovery
* T1007 — System Service Discovery
* T1083 — File and Directory Discovery

### Scenario

A scripted post-compromise enumeration sequence is executed to simulate attacker reconnaissance after gaining shell access.

### Detection Focus

* privilege escalation reconnaissance
* network discovery
* service discovery
* user and host discovery
* sensitive file discovery
* session correlation
* temporal command clustering

### Telemetry Observed

* auditd EXECVE events
* shell command execution
* shared session identifiers
* TTY correlation
* process lineage
* command sequencing

### Key Behavioral Insights

The simulation demonstrated that:

* individual commands are weak indicators
* grouped reconnaissance behavior creates stronger detection context
* auditd preserves short-lived process activity effectively
* session correlation significantly improves investigation quality

### Artifacts Produced

* telemetry report
* investigation workflow
* ATT&CK mapping
* detection logic
* Sigma rule
* validation report
* normalized events
* sample alerts
* session reconstruction samples
* evidence screenshots

---

# Detection Artifacts

## Detection Logic

Engineering rationale and behavioral analysis used during detection development.

Location:

```text
detections/logic/
```

---

## Sigma Rules

Platform-agnostic behavioral detection rules.

Location:

```text
detections/sigma/linux/
```

---

## Validation Reports

Detection verification, false-positive analysis, and evidence-backed validation.

Location:

```text
detections/validation/
```

---

## Threat Investigations

Investigation workflows and telemetry reconstruction analysis.

Location:

```text
investigations/
```

---

## Telemetry Reports

Observed telemetry patterns and analysis documentation.

Location:

```text
telemetry/
```

---

# Telemetry Sources

The project currently leverages and analyzes telemetry from:

* Linux auditd EXECVE events
* SSH authentication logs
* PAM authentication logs
* process creation telemetry
* parent-child process relationships
* shell interpreter execution
* network connection telemetry
* service management telemetry
* cron execution telemetry
* session correlation data
* TTY association
* journalctl logs

Potential telemetry integrations:

* auditd
* Sysmon for Linux
* Elastic Defend
* Wazuh
* Microsoft Defender for Endpoint
* Splunk
* Elastic SIEM

---

# Detection Engineering Concepts Covered

This repository currently covers:

* behavioral detection engineering
* Linux process telemetry analysis
* process lineage reconstruction
* session correlation
* ATT&CK mapping
* persistence detection
* reverse shell analytics
* authentication attack detection
* privilege escalation reconnaissance
* network telemetry analysis
* Sigma rule engineering
* telemetry normalization
* evidence-based validation
* adversary emulation methodology

---

# Evidence-Driven Validation

Every completed scenario includes operational evidence such as:

* auditd telemetry
* process lineage screenshots
* network telemetry
* validation screenshots
* timeline reconstruction
* session correlation evidence
* service execution proof
* detection trigger proof

This ensures detections are validated against observed attacker behavior rather than theoretical assumptions.

---

# Tools & Technologies

## Operating Systems

* Linux
* Ubuntu

## Detection & Telemetry

* auditd
* Sigma
* journalctl
* auth.log
* process telemetry analysis

## Offensive Simulation

* Bash
* cron
* systemd
* SSH
* reverse shells
* Linux reconnaissance commands

## Analysis & Investigation

* MITRE ATT&CK
* behavioral analytics
* process lineage reconstruction
* telemetry correlation
* session reconstruction

---

# Future Roadmap

Planned future scenarios and improvements:

* privilege escalation detections
* credential dumping analytics
* Linux malware persistence
* lateral movement simulations
* defense evasion techniques
* container security detections
* SIEM correlation rules
* ATT&CK coverage matrices
* detection severity scoring
* automated validation pipelines
* Elastic detection rules
* Sysmon for Linux integrations
* threat hunting playbooks

---

# Project Philosophy

This repository is built around a core principle:

> Effective detection engineering is built from telemetry understanding and behavioral analysis — not just writing detection rules.

The project prioritizes understanding:

* how attacks behave,
* how telemetry captures those behaviors,
* how investigations reconstruct attacker actions,
* and how reliable detections are engineered from that telemetry.

---

# Author Notes

This repository is an active detection engineering lab environment and will continue expanding with:

* additional Linux attack simulations
* improved telemetry pipelines
* advanced behavioral detections
* investigation methodologies
* validation workflows
* ATT&CK-aligned detection coverage

The long-term objective is to build operationally realistic detection engineering experience through iterative adversary simulation and telemetry-driven analysis.

