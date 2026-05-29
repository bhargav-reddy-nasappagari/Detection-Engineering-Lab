# Suspicious Enumeration Simulation — Telemetry Analysis Report

## 1. Objective of Simulation

The purpose of this simulation was to model a realistic post-compromise enumeration scenario on a Linux Ubuntu virtual machine and capture multi-source telemetry for:

- Process execution visibility (auditd execve/syscall)
- Authentication and privilege transitions (auth.log)
- Session and process hierarchy reconstruction (process tree snapshot)
- Behavioral sequencing of reconnaissance activity

The environment was instrumented prior to execution to ensure complete capture of execution-level and session-level telemetry.

---

## 2. Telemetry Sources Collected

### 2.1 auditd (Primary Execution Telemetry)

The audit subsystem recorded all process execution events under the `enum_exec` key.

Captured data includes:
- EXECVE arguments (`a0`, `a1`)
- Process identifiers (PID, PPID)
- User context (AUID, UID, GID)
- Terminal session (TTY)
- Execution timestamps
- Full command-line reconstruction via `proctitle`

#### Observed execution categories:

**Enumeration Script Execution**
- `/bin/bash scenarios/suspicious-enumeration/enumeration.sh`

**System Discovery Commands**
- `whoami`, `id`, `hostname`, `uname -a`
- `groups`, `who`, `w`

**User / Credential Context Discovery**
- `getent passwd`

**Network Discovery**
- `ip a`, `ip route`
- `ss -tulnp`

**Process Inspection**
- `ps aux`

**Service Enumeration**
- `systemctl list-units --type=service`

**Privilege Probe**
- `sudo -l`

**Execution Pacing**
- repeated `sleep 1/2` calls between command bursts

---

### 2.2 Authentication Logs (Privilege Context)

Captured from `/var/log/auth.log`:

Observed events:
- CRON session initialization and termination
- sudo session transitions:
  - `sudo -l`
  - privileged command execution under root context
- evidence of log access and inspection activity (`ausearch`, `cp`)

#### Key observations:
- Clear user → root transition boundary via sudo
- Authentication helper process execution (`unix_chkpwd`)
- Evidence of investigative activity post-execution

---

### 2.3 Process Tree Snapshot (Session Structure)

Extracted process hierarchy:

```
bash (PID 8907)
└── script wrapper (PID 9403)
└── bash -i (PID 9404)
```


#### Key inference:
- Execution occurred inside nested shell contexts
- Script acted as orchestration layer for command execution
- Some process lineage is transient due to short-lived command execution lifecycle

---

## 3. Reconstructed Session Behavior Model

### Stage 1 — Session Initialization
- Interactive bash session established (TTY-based execution context)

### Stage 2 — Script-Based Execution Layer
- Enumeration script executed via bash
- Introduced controlled execution wrapper

### Stage 3 — Execution Pacing Layer
- `sleep` injected between commands
- Indicates throttled execution pattern (automation or noise reduction behavior)

### Stage 4 — System Enumeration Phase
- Identity: `whoami`, `id`, `groups`
- Host fingerprinting: `hostname`, `uname`
- User enumeration: `who`, `w`, `getent passwd`
- Network discovery: `ip a`, `ip route`, `ss -tulnp`
- Service enumeration: `systemctl list-units`
- Process inspection: `ps aux`

### Stage 5 — Privilege Boundary Probe
- `sudo -l` executed
- Triggered authentication helper (`unix_chkpwd`)
- Indicates evaluation of privilege escalation surface

---

## 4. Process Analysis

### 4.1 Command Execution Characteristics

- Commands executed from a single TTY session (`pts4`)
- Shared AUID (1000) across execution chain
- Consistent PPID lineage under script execution wrapper

### 4.2 Execution Mode

| Layer | Type |
|------|------|
| Interactive shell | User-driven session |
| enumeration.sh | Script orchestration layer |
| commands | Mixed interactive + scripted execution |

### 4.3 Process Lineage Insight

- bash → script → command chain is consistent
- sudo introduces separate privileged execution branch
- authentication subprocess (`unix_chkpwd`) confirms privilege boundary traversal

---

## 5. Temporal Analysis

### 5.1 Execution Speed

- Commands executed in rapid succession
- Inter-command delay extremely low (sub-second to few seconds)
- sleep introduced deterministic pauses between bursts

### 5.2 Burst Behavior

Strong burst pattern observed:
- multiple EXECVE events per short time window
- clustered execution of enumeration commands

### 5.3 Chaining Behavior

Clear structured chaining observed:

> Identity → System → Network → Service → Process → Privilege Probe

This is a deterministic reconnaissance sequence rather than random command execution.

---

## 6. Contextual Analysis

### 6.1 User Context

- Initial UID: 1000 (non-root user)
- Privilege escalation probe observed via sudo
- Transition into privileged helper execution path

### 6.2 Execution Environment

- TTY-based interactive session (`pts4`)
- Script-based orchestration inside shell
- Nested bash instance (`bash -i`) indicates layered execution model

### 6.3 Behavioral Classification

| Dimension | Classification |
|-----------|---------------|
| Activity type | Structured enumeration |
| Execution style | Script-assisted interactive session |
| Privilege behavior | Active probing (sudo) |
| Environment | Single-host VM simulation |

---

## 7. Signal Strength Classification (Critical for Detection)

Detection logic depends on distinguishing signal reliability.

---

### 7.1 Strong Signals (High Confidence)

These are high-fidelity indicators of reconnaissance behavior:

- `sudo -l` followed by `unix_chkpwd`
- `ip route` + `ss -tulnp` in same session
- `getent passwd` enumeration
- structured command progression:
  identity → network → service discovery
- high-frequency EXECVE bursts in short windows
- script-based execution (`enumeration.sh`)

---

### 7.2 Medium Signals (Context Dependent)

Useful only in correlation:

- `ps aux`
- `who`, `w`
- `groups`
- `uname -a`

---

### 7.3 Weak Signals (Low Individual Value)

High noise; not useful alone:

- `hostname`
- `whoami`
- `id`
- `sleep`

---

### 7.4 Detection Principle

> Individual weak signals are meaningless. Detection emerges from correlated clusters of weak + medium + strong signals within a bounded time window and shared session context.

---

## 8. Detection Leads & Hypotheses

### Lead 1 — Enumeration Burst Detection
- High-frequency execve events within single TTY session
- Clustered known reconnaissance commands

### Lead 2 — Structured Reconnaissance Chain
- Ordered execution of identity → network → service discovery

### Lead 3 — Privilege Probe Detection
- `sudo -l` followed by authentication helper execution

### Lead 4 — Script-Based Execution Model
- `enumeration.sh` acting as orchestration layer
- consistent PID lineage under script wrapper

### Lead 5 — Execution Pacing Anomaly
- periodic `sleep` injection
- consistent timing gaps between command bursts

---

## 9. Investigation Next Steps

1. Build session reconstruction graph (PID + TTY + AUID correlation)
2. Convert EXECVE logs into ordered behavioral timeline
3. Implement command clustering model for enumeration detection
4. Correlate sudo activity with execve bursts
5. Detect sleep-based pacing patterns for automation signatures

---

## 10. Conclusion

The telemetry confirms a structured post-compromise enumeration session characterized by:

- deterministic reconnaissance sequencing
- script-assisted execution orchestration
- observable privilege probing behavior
- execution pacing via sleep injection
- clear session lineage across bash → script → commands

The dataset is sufficient to support:

- behavioral detection rule development
- session reconstruction logic
- privilege escalation reconnaissance detection
- structured enumeration attack modeling
