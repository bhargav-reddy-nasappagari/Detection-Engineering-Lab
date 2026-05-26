# Systemd Service Persistence Threat Mapping

---

# Overview

This document maps the simulated systemd service persistence activity to MITRE ATT&CK techniques, adversary behavior patterns, telemetry sources, and detection opportunities.

The simulation emulated a persistence mechanism where a malicious or unauthorized systemd service was created and executed to maintain execution capability on a Linux host.

The objective of this threat mapping is to:

- align observed behavior with ATT&CK techniques
- identify adversary objectives
- map telemetry opportunities
- define detection surfaces
- document behavioral indicators
- support detection engineering workflows

---

# Threat Scenario Summary

The simulation reproduced attacker persistence behavior using a custom systemd service.

The simulated service executed a payload script through systemd service management mechanisms.

Observed activity included:

- service file creation
- daemon reload operations
- service enablement
- systemctl execution
- shell execution through ExecStart
- persistence establishment
- recurring service execution

---

# ATT&CK Technique Mapping

| ATT&CK Tactic | Technique | ID |
|---|---|---|
| Persistence | Create or Modify System Process: Systemd Service | T1543.002 |
| Execution | Command and Scripting Interpreter: Unix Shell | T1059.004 |
| Defense Evasion | Masquerading (possible overlap) | T1036 |
| Privilege Escalation | Abuse Elevation Control Mechanism (possible overlap) | T1548 |

---

# Primary Technique

# T1543.002 — Systemd Service

## Description

Adversaries may create or modify systemd services to establish persistence or execute malicious payloads on Linux systems.

Attackers abuse:

- `.service` files
- `ExecStart`
- service enablement
- daemon reload mechanisms
- automatic service startup

---

# Simulated Adversary Objective

The simulated attacker objective was:

```text
Establish Persistent Execution
        ↓
Deploy Malicious Service
        ↓
Enable Automatic Execution
        ↓
Maintain Long-Term Access
```

---

# Simulated Attack Flow

```text
Payload Script Creation
        ↓
Service File Creation
        ↓
systemctl daemon-reload
        ↓
systemctl enable
        ↓
systemctl start
        ↓
Payload Execution
        ↓
Persistence Established
```

---

# Simulated Components

## Payload Script

The simulation used a shell-based payload script executed through the systemd service.

Observed behaviors included:

- shell execution
- recurring execution
- background process behavior
- systemd-managed process execution

---

## Service Definition

The simulation created a custom `.service` file containing:

- service metadata
- ExecStart directive
- execution path
- startup configuration

---

# Adversary Tradecraft Mapping

# Persistence

The attack established persistence through:

- automatic service startup
- system-managed execution
- service enablement across reboots

---

# Execution

Execution occurred through:

```text
systemd
    ↓
bash/sh
    ↓
payload script
```

This provided attacker-controlled command execution.

---

# Privilege Context

The simulation demonstrated that systemd services may execute:

- as root
- under privileged service accounts
- with elevated execution contexts

This increases attacker operational capability.

---

# Behavioral Indicators

## High-Value Indicators

| Indicator | Detection Value |
|---|---|
| new `.service` file creation | High |
| `systemctl daemon-reload` | High |
| `systemctl enable` | High |
| `ExecStart=` modification | High |
| shell execution from systemd | High |
| suspicious service names | Medium |
| recurring background execution | Medium |

---

# Process Lineage Mapping

## Observed Execution Flow

```text
systemd
 └── bash
      └── updater.sh
```

This lineage strongly indicated service-driven shell execution.

---

# Detection Surface Mapping

# Service File Creation

## Observable Locations

```text
/etc/systemd/system/
/usr/lib/systemd/system/
~/.config/systemd/user/
```

---

## Detection Opportunities

Monitor for:

- new service creation
- service file modifications
- unauthorized service deployment
- suspicious file metadata changes

---

# daemon-reload Activity

## Observed Commands

```bash
systemctl daemon-reload
```

---

## Detection Opportunities

Detect:

- unexpected daemon reloads
- reloads following service creation
- reloads executed by unusual users

---

# Service Enablement Activity

## Observed Commands

```bash
systemctl enable updater.service
```

---

## Detection Opportunities

Detect:

- new enabled services
- unusual service names
- unauthorized startup persistence

---

# ExecStart Abuse

## Example Behavior

```ini
ExecStart=/bin/bash /home/user/updater.sh
```

---

## Detection Opportunities

Monitor for:

- shell interpreters in ExecStart
- script-based execution
- unusual binary execution
- payload execution from user directories

---

# Shell Execution Mapping

## Observed Shell Activity

```text
/bin/bash
/bin/sh
```

---

## Detection Opportunities

Detect:

- shell execution from systemd
- service-spawned interpreters
- suspicious child processes
- shell-based payload execution

---

# Telemetry Mapping

# Process Execution Telemetry

## High-Value Fields

| Field | Purpose |
|---|---|
| Image | executed process |
| ParentImage | lineage reconstruction |
| CommandLine | payload visibility |
| PID | process tracking |
| PPID | ancestry correlation |
| User | execution context |
| Timestamp | sequencing |

---

# Service Telemetry

## Valuable Artifacts

| Artifact | Detection Value |
|---|---|
| service definitions | persistence visibility |
| daemon reload logs | service activation |
| service status output | execution confirmation |
| journalctl logs | execution telemetry |
| service metadata | forensic context |

---

# Auditd Telemetry Mapping

## Relevant Syscalls

```text
execve
open
openat
chmod
rename
unlink
```

---

# Syscall Relevance

| Syscall | Purpose |
|---|---|
| execve | process execution |
| open/openat | service file access |
| chmod | permission changes |
| rename | file replacement |
| unlink | cleanup/removal activity |

---

# Required Auditd Rules

## Process Execution Monitoring

```bash
-a always,exit -F arch=b64 -S execve -k exec_monitor
```

---

## File Modification Monitoring

```bash
-w /etc/systemd/system/ -p wa -k systemd_modification
```

---

# Threat Detection Opportunities

# High-Fidelity Detection Opportunities

| Detection Opportunity | Fidelity |
|---|---|
| shell launched by systemd | High |
| new service creation + daemon reload | High |
| ExecStart containing shell interpreter | High |
| service creation in unusual path | High |
| service enablement after creation | High |

---

# Medium-Fidelity Detection Opportunities

| Detection Opportunity | Fidelity |
|---|---|
| suspicious service naming | Medium |
| recurring background execution | Medium |
| unusual user-created services | Medium |

---

# Low-Fidelity Detection Opportunities

| Detection Opportunity | Fidelity |
|---|---|
| isolated daemon-reload | Low |
| standalone systemctl execution | Low |

---

# Threat Hunting Opportunities

## Recommended Hunt Queries

### Shell Execution from systemd

```text
ParentImage = systemd
AND
Image = bash/sh
```

---

### Suspicious ExecStart Entries

```text
ExecStart contains:
/bin/bash
/bin/sh
python
perl
curl
wget
```

---

### Recently Created Services

```text
Service Creation
    +
daemon-reload
    +
enable/start
```

---

# Telemetry Challenges Observed

# Challenge 1 — Limited Process Visibility

Some shell executions were difficult to observe without proper execve auditing.

---

# Challenge 2 — Inconsistent Process Trees

Different tooling displayed different ancestry representations.

Observed differences occurred between:

- htop
- pstree
- auditd telemetry

---

# Challenge 3 — Service Legitimacy Ambiguity

Many legitimate services perform:

- shell execution
- background tasks
- recurring activity

This increased false-positive potential.

---

# False Positive Considerations

## Potential Legitimate Sources

Possible benign activity included:

- administrator-created services
- software installers
- monitoring agents
- backup services
- automation frameworks

---

# False Positive Reduction

Recommended exclusions:

- trusted service paths
- known vendor services
- approved automation services
- enterprise monitoring agents

---

# Severity Assessment

| Severity | Condition |
|---|---|
| Critical | malicious shell execution via systemd |
| High | suspicious service persistence |
| Medium | unusual daemon reload activity |
| Low | isolated systemctl usage |

---

# Detection Engineering Insights

# Insight 1 — Parent-Child Context Is Critical

The strongest detection signal was:

```text
systemd
    ↓
bash/sh
    ↓
payload
```

---

# Insight 2 — Service Creation Alone Is Insufficient

Many legitimate services are created regularly.

Behavioral correlation improved detection fidelity significantly.

---

# Insight 3 — ExecStart Analytics Are High Value

The most valuable indicators originated from:

- shell interpreters
- scripts
- suspicious binaries
- user-directory execution

---

# Insight 4 — Telemetry Correlation Is Mandatory

Reliable detection required correlation between:

```text
Service Creation
    +
daemon-reload
    +
Enablement
    +
Shell Execution
```

---

# Threat Mapping Validation

The simulation successfully demonstrated:

- realistic persistence behavior
- ATT&CK-aligned adversary tradecraft
- observable telemetry generation
- detection engineering opportunities
- service-based persistence analytics

---

# Recommended Evidence Collection

| Evidence | Purpose |
|---|---|
| service-definition-proof.png | malicious service visibility |
| service-enablement-proof.png | persistence confirmation |
| process-lineage-proof.png | ancestry visibility |
| journal-execution-proof.png | execution telemetry |
| detection-trigger-proof.png | Sigma validation |
| cleanup-verification-proof.png | removal confirmation |

---

# Final Threat Assessment

The simulated systemd persistence activity demonstrated realistic Linux persistence tradecraft aligned with MITRE ATT&CK T1543.002.

The simulation validated that:

- systemd services provide effective persistence mechanisms
- shell-based ExecStart directives are high-value indicators
- process lineage analytics significantly improve detection quality
- service creation alone is insufficient for reliable detection
- behavioral correlation provides stronger detection fidelity

The threat mapping confirms that the simulation successfully reproduced operationally relevant Linux persistence behavior suitable for detection engineering, investigation workflows, and ATT&CK-aligned analytics development.
