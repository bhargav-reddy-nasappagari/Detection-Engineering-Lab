# Detection Engineering Laboratory

## Overview

Detection Engineering Laboratory is a hands-on Linux detection engineering project focused on adversary simulation, telemetry collection, behavioral analysis, threat investigation, ATT&CK-aligned threat mapping, Sigma rule development, and evidence-driven validation.

The project recreates realistic post-compromise and persistence behaviors in a controlled Linux environment and follows a complete detection engineering workflow from attack execution through validated detection development.

Unlike repositories that focus solely on detection content, this project emphasizes understanding how attacks behave, how telemetry captures those behaviors, how investigations reconstruct attacker actions, and how reliable detections are engineered from observed evidence.

---

# Project Objectives

The primary goals of this repository are:

* Develop practical detection engineering skills
* Simulate realistic Linux attacker behaviors
* Collect and analyze security telemetry
* Reconstruct attacker activity through investigations
* Map observed behavior to MITRE ATT&CK
* Engineer behavioral detections
* Develop Sigma detection rules
* Validate detections using collected evidence
* Build reusable detection engineering workflows
* Create a portfolio of ATT&CK-aligned detection use cases

---

# Detection Engineering Workflow

Every scenario follows a structured workflow modeled after operational SOC and threat detection processes.

```text
Attack Simulation
        ↓
Baseline Collection
        ↓
Telemetry Acquisition
        ↓
Telemetry Analysis
        ↓
Investigation & Reconstruction
        ↓
Threat Mapping (MITRE ATT&CK)
        ↓
Detection Logic Engineering
        ↓
Sigma Rule Development
        ↓
Detection Validation
        ↓
Evidence Collection
        ↓
Lessons Learned
```

This methodology prioritizes:

* Behavioral analytics
* Telemetry understanding
* Process lineage analysis
* Session reconstruction
* ATT&CK alignment
* Detection validation
* Evidence-backed conclusions

rather than signature-only detection approaches.

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

### ATT&CK Mapping

* T1053.003 – Scheduled Task/Job: Cron

### Summary

A recurring cron job executes a shell script at scheduled intervals to simulate Linux persistence.

### Detection Focus

* Cron spawning shell interpreters
* Recurring script execution
* Scheduled persistence behavior
* Process lineage analysis
* Long-lived persistence mechanisms

### Deliverables

* Telemetry analysis
* Investigation report
* ATT&CK mapping
* Detection logic
* Sigma rule
* Validation report
* Evidence screenshots
* Sample detection artifacts

---

## 2. Systemd Service Persistence

### ATT&CK Mapping

* T1543.002 – Create or Modify System Process: Systemd Service

### Summary

A malicious service unit is created and enabled to simulate persistence through systemd.

### Detection Focus

* Service creation
* Service enablement
* Daemon reload activity
* Service-backed payload execution
* Persistent execution through systemd

### Deliverables

* Telemetry analysis
* Investigation report
* ATT&CK mapping
* Detection logic
* Sigma rule
* Validation workflow
* Evidence collection
* Sample detection artifacts

---

## 3. Reverse Shell Execution

### ATT&CK Mapping

* T1059 – Command and Scripting Interpreter
* T1071 – Application Layer Protocol

### Summary

A reverse shell is established from the victim host to a listener to simulate remote command execution after compromise.

### Detection Focus

* Shell-to-network relationships
* Outbound connections from interpreters
* Interactive command execution
* Process lineage reconstruction
* Network telemetry correlation

### Deliverables

* Telemetry analysis
* Investigation workflow
* Detection logic
* Sigma rule
* Validation report
* Network evidence
* Process evidence
* Sample alerts

---

## 4. SSH Brute Force

### ATT&CK Mapping

* T1110 – Brute Force

### Summary

Repeated SSH authentication attempts are generated to simulate password guessing and credential attacks.

### Detection Focus

* Authentication failures
* Invalid account usage
* PAM authentication telemetry
* Connection termination patterns
* Threshold-based detection logic

### Deliverables

* Telemetry analysis
* Investigation report
* Detection logic
* Sigma rule
* Validation report
* Authentication evidence
* PCAP capture
* Sample alerts

---

## 5. Suspicious Enumeration Activity

### ATT&CK Mapping

* T1033 – System Owner/User Discovery
* T1057 – Process Discovery
* T1049 – System Network Connections Discovery
* T1082 – System Information Discovery
* T1016 – Network Configuration Discovery
* T1007 – Service Discovery
* T1083 – File and Directory Discovery

### Summary

A structured post-compromise reconnaissance sequence is executed to simulate attacker situational awareness and environment discovery.

### Detection Focus

* User discovery
* Host discovery
* Process discovery
* Network discovery
* Service discovery
* Session correlation
* Temporal command clustering

### Deliverables

* Telemetry report
* Investigation report
* ATT&CK mapping
* Detection logic
* Sigma rule
* Validation report
* Session reconstruction
* Evidence screenshots

---

## 6. Encoded Command Execution

### ATT&CK Mapping

* T1059 – Command and Scripting Interpreter
* T1140 – Deobfuscate/Decode Files or Information
* T1027 – Obfuscated/Compressed Files and Information

### Summary

Multiple encoded payload execution techniques were simulated to study how attackers conceal commands before execution and how those behaviors manifest in Linux telemetry.

The simulation included four independent execution variants.

### Variant 1 – Direct Pipe Execution

```text
bash → base64 → bash → payload
```

A Base64-encoded payload is decoded and immediately piped into a shell interpreter.

### Variant 2 – File Reconstruction

```text
base64 decode
      ↓
/tmp/payload.sh creation
      ↓
chmod +x
      ↓
payload execution
```

The payload is reconstructed as a temporary script before execution.

### Variant 3 – Python Decoder

```text
bash
  ↓
python3 decoder
  ↓
bash payload
```

Python is used as the decoding and execution intermediary.

### Variant 4 – Multi-Stage Decode

```text
bash
  ↓
base64
  ↓
base64
  ↓
bash
```

A double-decoding workflow simulates layered payload obfuscation.

### Common Payload Activity

All variants executed the following commands:

```bash
whoami
id
hostname
uname -a
ps aux
touch /tmp/.enc_exec_marker
curl 127.0.0.1:8080
```

### Detection Focus

* Base64 decoding activity
* Multi-stage decoding
* Python-based decoding
* Temporary payload reconstruction
* Shell interpreter execution
* Process lineage reconstruction
* Discovery activity correlation
* Encoded command execution patterns

### Telemetry Sources

* Auditd EXECVE events
* Sysmon for Linux process creation events
* Temporary file activity
* HTTP listener logs
* TCP network captures
* Process lineage telemetry

### Deliverables

* Telemetry analysis
* Investigation report
* ATT&CK mapping
* Detection logic
* Sigma rule
* Validation report
* Attack timelines
* Session reconstructions
* Process chains
* Sigma match evidence
* Detection validation artifacts
* Supporting screenshots

---

# Detection Artifacts

## Detection Logic

Behavioral analysis and engineering rationale used to create detections.

```text
detections/logic/
```

## Sigma Rules

Platform-agnostic behavioral detections.

```text
detections/sigma/linux/
```

## Validation Reports

Evidence-backed validation and detection verification.

```text
detections/validation/
```

## Threat Mapping

ATT&CK alignment and adversary behavior analysis.

```text
docs/threat-mapping/
```

## Investigations

Telemetry reconstruction and investigative workflows.

```text
investigations/
```

## Telemetry Reports

Observed telemetry analysis and behavioral findings.

```text
telemetry/
```

---

# Telemetry Sources

Current telemetry sources include:

* Auditd EXECVE events
* Sysmon for Linux process events
* SSH authentication logs
* PAM authentication logs
* Auth.log telemetry
* Journalctl logs
* Process creation events
* Parent-child process lineage
* Service management activity
* Cron execution telemetry
* Session correlation data
* Network connection telemetry
* Temporary file activity
* TCP packet captures

---

# Detection Engineering Topics Covered

The repository currently covers:

* Linux detection engineering
* Behavioral analytics
* Process lineage reconstruction
* Session reconstruction
* ATT&CK mapping
* Persistence detection
* Encoded command execution
* Reverse shell detection
* SSH brute force detection
* Post-compromise enumeration
* Telemetry normalization
* Sigma rule engineering
* Detection validation
* Evidence-driven investigations

---

# Evidence-Driven Validation

Every completed scenario contains supporting evidence collected during simulation and validation.

Examples include:

* Process lineage screenshots
* Auditd telemetry
* Sysmon telemetry
* Network captures
* Timeline reconstruction
* Session reconstruction
* Detection trigger validation
* Service execution proof
* Authentication evidence

The objective is to validate detections using observed behavior rather than assumptions.

---

# Technology Stack

## Operating System

* Ubuntu Linux

## Telemetry & Detection

* Auditd
* Sysmon for Linux
* Sigma
* Auth.log
* Journalctl

## Adversary Simulation

* Bash
* Cron
* Systemd
* Python
* SSH
* Base64
* Reverse Shell Techniques

## Analysis & Investigation

* MITRE ATT&CK
* Behavioral Analytics
* Process Lineage Analysis
* Session Correlation
* Threat Mapping
* Detection Validation

---

# Future Roadmap

Planned future work includes:

* Privilege escalation detections
* Defense evasion techniques
* Credential access scenarios
* Linux malware persistence
* Lateral movement simulations
* Container security detections
* SIEM correlation rules
* ATT&CK coverage matrix
* Detection severity models
* Automated validation pipelines
* Elastic detections
* Wazuh detections
* Threat hunting playbooks

---

# Project Philosophy

> Reliable detections are engineered from telemetry, investigation, and validated behavioral evidence—not from signatures alone.

This project focuses on understanding:

* How attacks behave
* How telemetry captures behavior
* How investigations reconstruct activity
* How ATT&CK techniques manifest on Linux
* How detections are engineered and validated

The ultimate objective is to develop operational detection engineering experience through iterative adversary simulation and telemetry-driven analysis.

---

# Status

Current completed scenarios:

* Cron Persistence
* Systemd Service Persistence
* Reverse Shell Execution
* SSH Brute Force
* Suspicious Enumeration
* Encoded Command Execution

The laboratory continues to expand through new ATT&CK-aligned attack simulations, detection content, and validation workflows.

