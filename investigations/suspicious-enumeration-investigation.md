# Suspicious Enumeration Simulation — Investigation & Detection Correlation Report

## 1. Investigation Objective

This phase translates raw telemetry (auditd EXECVE logs, auth.log events, and process tree reconstruction) into a structured investigation model capable of answering:

- What triggered the alert?
- Was execution interactive or automated?
- Was the user legitimate in context?
- Was sensitive or privileged surface accessed?
- Was privilege escalation attempted or initiated?

The goal is not log inspection, but **behavioral reconstruction of a session attack chain**.

---

## 2. Investigation Methodology (How telemetry is interpreted)

Investigation is performed through four correlated axes:

### 2.1 Session Binding
All events are grouped using:
- AUID (real user identity)
- TTY session (execution boundary)
- PID → PPID lineage (process ancestry)
- Time-window clustering (± minutes around alert trigger)

This ensures we reconstruct a **single coherent actor session**, not isolated log entries.

---

### 2.2 Temporal Reconstruction
EXECVE events from auditd are ordered strictly by timestamp to reconstruct:
- command execution sequence
- execution density (burst vs spaced execution)
- presence of sleep-based pacing

This distinguishes:
- human interaction patterns
- scripted automation behavior
- hybrid execution chains

---

### 2.3 Behavioral Classification
Each command cluster is mapped into functional intent:

- Identity Discovery → `whoami`, `id`, `groups`
- System Discovery → `uname`, `hostname`
- User Enumeration → `getent passwd`, `who`, `w`
- Network Discovery → `ip a`, `ip route`, `ss -tulnp`
- Service Enumeration → `systemctl list-units`
- Process Inspection → `ps aux`
- Privilege Probe → `sudo -l`

This classification is essential for detection logic abstraction.

---

### 2.4 Privilege & Sensitivity Correlation
Cross-referenced sources:
- `auth.log` (sudo transitions, unix_chkpwd invocation)
- auditd EXECVE traces
- process tree anomalies (bash nesting, script wrappers)

Used to determine:
- privilege escalation attempts
- credential probing behavior
- sensitive system interaction

---

## 3. Investigation Findings (Derived from Telemetry)

### 3.1 Alert Trigger Attribution

The alert is triggered primarily by:

- High-density execution of reconnaissance commands
- Known enumeration command set execution in sequence
- Low inter-command timing (burst behavior)

**Key insight:**
The trigger is not a single command, but a **behavioral cluster**.

---

### 3.2 Execution Mode Analysis

From process tree:

```
bash (PID 8907)
└── script wrapper (PID 9403)
└── bash -i (PID 9404)
```


### Interpretation:
- Script-driven execution layer exists
- Followed by interactive shell spawn
- Indicates **hybrid execution model**

### Conclusion:
Execution is NOT purely interactive.
Execution is NOT purely scripted.

It is an **orchestrated hybrid session**, typical of post-compromise tooling.

---

### 3.3 User Expectation Validation

User: `bunny`

Validation criteria:
- No baseline behavioral profile provided
- Observed execution includes:
  - structured enumeration chain
  - privilege probing (`sudo -l`)
  - system-wide reconnaissance

### Result:
- User behavior deviates from normal administrative patterns (high confidence)
- Even if user is legitimate, behavior is **contextually anomalous**

---

### 3.4 Sensitive Surface Access Analysis

Observed access patterns:

- `/etc/passwd` access via `getent passwd`
- system-wide service enumeration
- authentication policy probing via `sudo -l`

### Interpretation:
No direct file modification observed, but:
> sensitive system state exposure occurred via enumeration interfaces

This is critical:
**read-based reconnaissance is sufficient for detection logic triggering**

---

### 3.5 Privilege Escalation Correlation

Evidence chain:
- `sudo -l` executed
- `unix_chkpwd` observed in auth subsystem
- no full root shell confirmed in process tree snapshot

### Interpretation:
- No completed escalation detected
- Strong **pre-escalation reconnaissance behavior present**

### Classification:
> Privilege escalation attempt: PROBING PHASE ONLY

---

## 4. Detection Logic Relevance (How investigation maps to rules)

This investigation directly validates and refines detection logic design.

---

### 4.1 Enumeration Burst Detection Rule

### Derived from:
- high-frequency EXECVE events
- low time delta between commands
- repeated reconnaissance command types

### Detection Logic Outcome:
Trigger when:
- ≥ N enumeration commands within short window
- from same AUID + TTY
- excluding benign single-command execution

---

### 4.2 Sequence-Based Reconnaissance Detection

### Derived from:
Observed ordered pattern:

```
identity → system → users → network → services → processes
```


### Detection Logic Outcome:
Trigger when:
- known reconnaissance sequence signature appears
- even if individual commands are low-risk

---

### 4.3 Privilege Probe Detection

### Derived from:
- sudo -l execution
- auth helper activity (unix_chkpwd)

### Detection Logic Outcome:
Trigger when:
- sudo policy query occurs without administrative context
- followed by enumeration activity

---

### 4.4 Session Wrapping / Execution Orchestration Detection

### Derived from:
- bash → script → bash -i nesting

### Detection Logic Outcome:
Trigger when:
- nested shell processes exceed baseline depth
- script execution followed by interactive shell spawn

---

### 4.5 Anti-Forensics / Pacing Behavior Detection

### Derived from:
- repeated sleep calls between commands

### Detection Logic Outcome:
Trigger when:
- consistent inter-command delay patterns appear
- indicating automation pacing or evasion strategy

---

## 5. Investigation Output Model (Standard SOC Output)

Each alert investigation should resolve into:

- **Session Identity**
  - AUID
  - TTY
  - PID root

- **Execution Mode**
  - interactive / scripted / hybrid

- **Behavior Classification**
  - enumeration / privilege probing / escalation attempt

- **Sensitivity Exposure**
  - system state accessed (yes/no + type)

- **Escalation Status**
  - none / probing / attempted / completed

- **Confidence Score**
  - based on telemetry correlation strength

---

## 6. Key Insight for Detection Engineering

This investigation demonstrates a critical principle:

> Detection is not command matching. Detection is behavioral reconstruction.

If detection logic only triggers on:
- individual commands → it will miss orchestration attacks
- frequency alone → it will over-trigger benign admin activity

Correct model requires:
- sequence awareness
- session reconstruction
- privilege context correlation
- process lineage validation

---

## 7. Conclusion

The telemetry confirms a structured post-compromise enumeration session with:

- deterministic reconnaissance sequencing
- hybrid execution model (script + interactive shell)
- privilege probing behavior (`sudo -l`)
- no confirmed escalation, but strong pre-escalation signals
- clear session wrapping artifact in process tree

### Detection relevance:
This dataset directly validates:
- enumeration burst detection rules
- sequence-based behavioral detection
- privilege probing heuristics
- session reconstruction requirements

It is sufficient to build production-grade detection logic models without additional telemetry sources.
