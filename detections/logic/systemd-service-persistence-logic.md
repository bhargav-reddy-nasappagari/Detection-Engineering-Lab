# systemd Service Persistence

---

# Simulation Overview

## Simulation Name
systemd Service Persistence

## ATT&CK Technique
T1543.002 — Create or Modify System Process: Systemd Service

## ATT&CK Tactic
Persistence

## Objective

The objective of this simulation is to emulate Linux persistence through malicious or suspicious systemd service execution behavior.

The simulation focuses on how attackers abuse systemd services to:

- maintain persistence
- survive reboots
- execute attacker-controlled payloads
- establish resilient daemon execution

This simulation is behavior-focused rather than indicator-focused.

The goal is NOT to detect:

```text
updater.service
```

The goal IS to detect:

```text
systemd persistence through suspicious service execution behavior
```

---

# Simulation Goals

The simulation is considered successful when:

- a malicious or suspicious service persists across reboot/session
- service execution telemetry is captured
- suspicious process lineage is observable
- service creation activity is detectable
- behavioral detection logic identifies suspicious service abuse
- Sigma detection logic is validated
- evidence artifacts are collected

---

# Threat Behavior Analysis

## Why The Behavior Is Suspicious

---

## 1. User-Controlled ExecStart

Legitimate services usually execute binaries from trusted system locations such as:

```text
/usr/bin/
/usr/sbin/
/bin/
```

Suspicious services frequently execute payloads from writable or user-controlled locations such as:

```text
/home/
/tmp/
/var/tmp/
/dev/shm/
```

Example:

```ini
ExecStart=/home/user/persist.sh
```

This behavior is suspicious because:

- attackers commonly store payloads in writable locations
- payload execution occurs outside trusted software paths
- temporary or user-controlled directories are frequently abused for persistence

---

## 2. Interpreter-Based Execution

Legitimate production services usually launch compiled binaries.

Attackers frequently abuse interpreters such as:

```text
bash
sh
python
perl
php
```

Examples:

```ini
ExecStart=/bin/bash /home/user/persist.sh
ExecStart=/usr/bin/python3 /tmp/beacon.py
```

This behavior is suspicious because:

- interpreters allow flexible payload execution
- attackers can rapidly deploy scripts without compilation
- shell-based persistence is operationally simple

---

## 3. Abnormal Parent-Child Relationships

Expected execution chain:

```text
systemd → trusted daemon
```

Suspicious execution chain:

```text
systemd → bash
systemd → sh
systemd → python
```

Example:

```text
systemd → bash → payload.sh
```

This behavior suggests:

- daemon abuse
- persistence orchestration
- script-driven service execution

---

## 4. Persistence Resilience

Attackers often configure services using restart policies such as:

```ini
Restart=always
Restart=on-failure
```

This enables:

- automatic payload recovery
- persistent execution
- long-term foothold maintenance

---

# Telemetry Requirements

Telemetry determines whether the detection is viable.

Most failed detections occur because telemetry dependencies were ignored.

---

## 1. Process Creation Telemetry

Required visibility:

- process creation
- command-line arguments
- parent-child relationships
- interpreter execution

Example lineage:

```text
systemd → bash
systemd → python
```

Recommended telemetry sources:

- auditd
- Sysmon for Linux
- eBPF telemetry
- EDR telemetry

Required fields:

| Field | Purpose |
|---|---|
| Parent Process | Detect systemd lineage |
| Process Name | Detect interpreters |
| Command Line | Detect suspicious ExecStart |
| PID/PPID | Process correlation |

---

## 2. Service Configuration Visibility

Required to inspect:

- ExecStart values
- Restart policies
- service definitions
- timer configurations

Critical paths:

```text
/etc/systemd/system/
/lib/systemd/system/
/usr/lib/systemd/system/
```

Without service configuration visibility:

- malicious services may remain invisible
- detection logic cannot validate service behavior

---

## 3. Filesystem Monitoring

Required visibility:

- service file creation
- service modification
- permission changes
- persistence artifact creation

Critical paths:

```text
/etc/systemd/system/
/etc/systemd/user/
```

Required events:

- file creation
- file modification
- file rename
- permission changes

---

## 4. Journal Logs

systemd activity is heavily logged through journald.

Relevant telemetry:

```bash
journalctl
```

Required visibility:

- service start events
- daemon reloads
- restart loops
- execution failures

Journal logs help validate:

- persistence activation
- execution timeline
- repeated service behavior

---

# Behavioral Signals

---

## Signal 1 — ExecStart References Writable Paths

### Suspicious Paths

```text
/home/
/tmp/
/var/tmp/
/dev/shm/
```

### Example

```ini
ExecStart=/home/user/updater.sh
```

### Why It Matters

Legitimate services rarely execute from writable directories.

This may indicate:

- attacker-controlled payloads
- staged malware
- persistence abuse

---

## Signal 2 — systemd Spawning Interpreters

### Suspicious Interpreters

```text
bash
sh
python
perl
php
```

### Example

```text
systemd → bash → payload.sh
```

### Why It Matters

Interpreters enable:

- rapid payload execution
- flexible scripting
- low attacker operational cost

---

## Signal 3 — Restart Persistence

### Suspicious Configuration

```ini
Restart=always
```

or

```ini
Restart=on-failure
```

### Why It Matters

This behavior enables:

- resilient persistence
- automatic execution recovery
- persistent foothold maintenance

---

## Signal 4 — New Service File Creation

### Sensitive Directories

```text
/etc/systemd/system/
/etc/systemd/user/
```

### Why It Matters

Unexpected service creation strongly indicates persistence activity.

Especially suspicious when combined with:

- interpreter execution
- writable path execution
- suspicious service naming

---

# Signal Correlation

Single indicators are weak.

Correlated behavioral signals produce stronger detections.

---

## Weak Indicator

```text
bash execution
```

This alone may be legitimate.

---

## Stronger Indicator

```text
systemd → bash
```

This indicates service-managed shell execution.

---

## High-Confidence Correlation

```text
systemd → bash
+
ExecStart=/home/
+
Restart=always
```

This strongly suggests:

- malicious persistence
- attacker-controlled execution
- resilient daemon abuse

---

# Detection Logic Engineering

## Detection Philosophy

The objective is behavioral detection engineering rather than static IOC matching.

The detection should identify:

- suspicious execution behavior
- malicious persistence patterns
- abnormal daemon execution

rather than:

```text
specific service names
```

---

# Detection Strategy

| Confidence Level | Detection Logic |
|---|---|
| High | systemd launching bash/sh/python from writable paths |
| High | new service creation combined with interpreter execution |
| Medium | Restart=always usage |
| Medium | service execution from /home or /tmp |
| Contextual | unsigned or unapproved services |
| Contextual | suspicious naming patterns |

---

## High-Confidence Indicators

Examples:

```text
systemd → bash → /tmp/payload.sh
```

```ini
ExecStart=/dev/shm/agent.sh
Restart=always
```

These combinations strongly indicate persistence abuse.

---

## Medium-Confidence Indicators

Examples:

- Restart=always alone
- interpreter execution without writable paths
- service creation without execution

These require contextual enrichment.

---

## Contextual Enrichment

Useful enrichment sources:

- service ownership
- package association
- file hash reputation
- user attribution
- historical baselines
- service age
- administrative approval status

---

# Potential False Positives

---

## 1. Developer Test Services

Developers may create temporary services for:

- debugging
- automation
- testing

Example:

```ini
ExecStart=/home/dev/test.sh
```

---

## 2. Internal Automation Scripts

Organizations sometimes deploy:

- backup scripts
- maintenance automation
- deployment tooling

through systemd services.

---

## 3. Monitoring Agents

Custom monitoring agents may:

- restart automatically
- execute wrappers
- run from non-standard paths

---

# Why Context Matters

Context determines legitimacy.

Important contextual factors include:

- approved service inventory
- administrator ownership
- software deployment records
- known automation tooling
- historical baselines

---

# Why Signal Correlation Reduces Noise

Single indicators generate excessive false positives.

Correlated indicators significantly improve confidence.

Example:

| Signal | Strength |
|---|---|
| bash execution | Weak |
| systemd → bash | Medium |
| systemd → bash + /tmp payload + Restart=always | High |

This is foundational behavioral detection engineering.

---

# ATT&CK Alignment

## Technique

T1543.002 — Create or Modify System Process: Systemd Service

---

## Persistence Objective

Attackers abuse systemd services to:

- survive reboots
- maintain persistence
- execute payloads automatically
- establish long-term access

---

## Service Abuse Mechanism

Persistence is achieved by:

- creating malicious services
- modifying legitimate services
- abusing daemon execution

---

## Daemon Execution

systemd provides:

- automatic startup
- privileged execution
- restart resilience
- centralized process management

This makes it highly attractive for persistence abuse.

---

# Detection Outcome

## What The Detection Is Intended To Reveal

The detection aims to identify:

- malicious persistence mechanisms
- suspicious daemon orchestration
- unauthorized service execution
- attacker-controlled payload execution

---

# Analyst Investigation Workflow

---

## 1. Inspect Service Definition

Review fields such as:

```ini
ExecStart=
Restart=
User=
WorkingDirectory=
```

---

## 2. Validate ExecStart Target

Determine:

- is the binary trusted?
- is the path writable?
- is the payload approved?
- does the execution path align with baseline behavior?

---

## 3. Analyze Parent-Child Lineage

Focus on suspicious chains such as:

```text
systemd → interpreter → payload
```

This often exposes the persistence mechanism.

---

## 4. Review Journal Logs

Example:

```bash
journalctl -u <service>
```

Look for:

- repeated restarts
- execution failures
- unusual launch timing
- daemon reload activity

---

# Investigation Pivot Artifacts

Key investigation artifacts:

- service file path
- payload location
- process lineage
- file hashes
- journal entries
- user ownership
- timestamps
- restart activity

These artifacts support:

- triage
- containment
- forensic analysis
- threat hunting

---

# Expected Telemetry Summary

| Telemetry Type | Detection Purpose |
|---|---|
| Process Creation | Detect systemd lineage |
| Command Line | Detect suspicious ExecStart |
| Filesystem Monitoring | Detect service creation |
| Journal Logs | Validate execution activity |
| Service Configuration | Analyze persistence behavior |

---

# Detection Engineering Outcome

The objective is NOT merely to detect a service.

The objective is to detect:

```text
malicious persistence behavior implemented through systemd service abuse
```

This approach produces:

- resilient detections
- ATT&CK-aligned analytics
- reusable detection logic
- lower false positives
- investigation-ready telemetry correlation

---
