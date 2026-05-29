# Suspicious Enumeration Simulation — Detection Logic Engineering

## 1. Objective of Detection Engineering Phase

This phase translates:

- Telemetry patterns (auditd, auth.log, process tree)
- Investigation findings (session reconstruction, behavior classification)
- Threat mapping (ATT&CK-aligned reconnaissance chain)

into **actionable detection logic** capable of producing high-confidence alerts.

The goal is not “detect commands”, but to detect:

> **behavioral intent of structured post-compromise enumeration inside a Linux session**

---

## 2. Detection Design Philosophy

Traditional detection fails here because it focuses on:

- single command matches ❌
- static threshold alerts ❌
- isolated privilege events ❌

This use case requires:

> **session-aware, sequence-driven behavioral detection**

Core principle:

### Detection = (Sequence + Density + Context + Privilege Signal + Session Boundary)

---

## 3. Detection Layers

We design detection in 4 layered signals:

### Layer 1 — Command Telemetry Normalization

All EXECVE events must be normalized into:

- session_id = (AUID + TTY + PID root)
- timestamp ordering
- command canonicalization (strip args where needed)
- grouping by time window (sliding window 60–180 seconds)

This produces a **session execution stream**, not raw logs.

---

### Layer 2 — Enumeration Command Taxonomy Mapping

Each command is classified into behavioral buckets:

| Category | Examples |
|----------|----------|
| Identity | whoami, id, groups |
| System | uname, hostname |
| Users | getent passwd, who, w |
| Network | ip a, ss -tulnp, ip route |
| Services | systemctl list-units |
| Processes | ps aux |
| Privilege Probe | sudo -l |

Each execution event is tagged:

```
command → category → risk_weight
```

---

## 4. Core Detection Logic Rules

### 4.1 Enumeration Burst Detection (Primary Signal)

**Rule Definition**

Trigger when:

- ≥ N enumeration commands
- within T seconds window
- same session_id

**Formal Logic**

```
IF count(enum_commands) ≥ 6
AND time_window ≤ 120s
AND same_session == TRUE
THEN ALERT: ENUMERATION_BURST
```

**Why this works**

- rapid command execution clusters
- low inter-command latency
- structured discovery chain

---

### 4.2 Behavioral Sequence Detection (High Confidence Signal)

**Rule Definition**

Detect ordered progression:

identity → system → users → network → services → process

**Formal Logic**

```
IF sequence_match(enum_chain_pattern) ≥ 4 stages
AND executed_in_order == TRUE
THEN ALERT: STRUCTURED_RECONNAISSANCE
```

**Why this matters**

Filters out:
- admin troubleshooting
- isolated diagnostics

Normal users do not execute full recon pipelines sequentially.

---

### 4.3 Privilege Probe Correlation Detection

**Rule Definition**

```
IF "sudo -l" detected
AND prior_commands IN enum_category_stream
WITHIN 300s
THEN ALERT: PRIVILEGE_ENUM_PROBE
```

**Interpretation**

This indicates pre-escalation intelligence gathering.

---

### 4.4 Session Wrapping / Execution Orchestration Detection

**Rule Definition**

```
IF process_tree_depth ≥ 3
AND bash_interactive_spawn == TRUE
AND script_execution_detected == TRUE
THEN ALERT: SESSION_WRAPPING_BEHAVIOR
```


**Meaning**

- automation layer present
- post-exploitation chaining
- execution abstraction

---

### 4.5 Pacing / Anti-Detection Behavior Detection

**Rule Definition**

```
IF avg(inter_command_delay) BETWEEN 1s AND 5s
AND variance LOW
AND sleep_calls_detected == TRUE
THEN ALERT: CONTROLLED_EXECUTION_PACING
```

**Meaning**

This detects synthetic human-like pacing used to evade rate-based detection.

---

## 5. Composite Detection Model (Final Alert Engine)

### Risk Scoring

| Signal | Weight |
|--------|--------|
| Enumeration burst | +3 |
| Structured sequence | +4 |
| Privilege probe | +3 |
| Session wrapping | +4 |
| Pacing behavior | +2 |

---

### Alert Threshold

```
IF total_score ≥ 7
THEN ALERT HIGH CONFIDENCE: POST-COMPROMISE ENUMERATION
```

---

## 6. False Positive Control Strategy

Suppress benign activity:

- single admin commands
- isolated sudo usage
- monitoring tools (top, htop)
- CI/CD automation (if baseline known)

**Suppression Logic**

```
IF command_frequency_low
OR sequence_missing
OR known_admin_tooling
THEN suppress_alert
```

---

## 7. Detection Output Schema

```json
{
  "session_id": "...",
  "alert_type": "structured_reconnaissance",
  "confidence": "high",
  "signals_triggered": [
    "enum_burst",
    "sequence_match",
    "privilege_probe"
  ],
  "attck_mapping": [
    "T1082",
    "T1087",
    "T1049",
    "T1068"
  ],
  "time_window": "120s",
  "severity": "high"
}
```

---

##8. Key Engineering Insight

This model shifts detection from:

detecting suspicious commands

to:

detecting adversary behavior chains inside sessions

Core improvements:

-session awareness
-sequence modeling
-privilege correlation
-behavioral scoring

---

##9. Conclusion

This detection logic converts:

-raw telemetry
-behavioral investigation
-ATT&CK mapping

into a multi-layer behavioral detection engine capable of identifying:

-structured enumeration
-privilege probing
-execution orchestration
-anti-detection pacing
