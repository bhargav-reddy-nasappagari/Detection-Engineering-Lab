# SSH Brute Force Threat Mapping

## ATT&CK Mapping

- Technique: T1110 — Brute Force
- Sub-Technique: T1110.001 — Password Guessing

---

# Threat Mapping Objective

The objective of this threat mapping exercise was to correlate the telemetry and investigation findings observed during the SSH brute force simulation with adversary behaviors defined in the MITRE ATT&CK framework.

The mapping process focused on:
- authentication abuse behavior
- repeated SSH login failures
- password guessing activity
- username enumeration behavior
- source-correlated authentication attempts
- threshold-triggering authentication telemetry
- SSH daemon defensive responses

The goal was to determine how the observed telemetry aligned with real-world adversary tradecraft and how it contributed to detection engineering.

---

# Simulation Overview

The simulation emulated repeated SSH authentication attempts against a Linux host using invalid credentials and multiple usernames.

The generated telemetry included:
- repeated SSH authentication failures
- invalid username attempts
- PAM authentication failures
- SSH disconnect behavior
- source IP repetition
- rapid authentication retry behavior

The observed behavior closely resembled real-world SSH brute force activity.

---

# Primary ATT&CK Mapping

## Technique

### T1110 — Brute Force

#### Description

Adversaries may attempt to gain access to accounts by repeatedly trying different passwords or authentication credentials until successful authentication occurs.

---

## Sub-Technique

### T1110.001 — Password Guessing

#### Description

Adversaries may attempt to guess passwords for valid accounts through repeated authentication attempts against exposed services such as SSH.

---

# Telemetry-to-Threat Mapping

# 1. Repeated Authentication Failure Telemetry

## Observed Telemetry

```text
Failed password for invalid user
Failed password for user
authentication failure
Invalid user
```

---

## Threat Mapping Analysis

These events directly aligned with:
- repeated credential guessing
- authentication abuse
- password-based intrusion attempts

This telemetry strongly mapped to:

```text
T1110.001 — Password Guessing
```

---

## Detection Significance

These events became the primary indicators for:
- brute force analytics
- threshold detections
- authentication anomaly monitoring

---

# 2. Source IP Repetition Telemetry

## Observed Telemetry

```text
same source IP
+
multiple failed authentication attempts
+
short timeframe
```

---

## Threat Mapping Analysis

This behavior aligned with:
- persistent password guessing
- repeated authentication abuse
- automated brute force attempts

This telemetry supported:
- attacker infrastructure correlation
- repetitive attack identification
- brute force clustering analytics

Mapped ATT&CK behavior:

```text
T1110 — Brute Force
```

---

## Detection Significance

Source IP repetition became one of the strongest indicators for:
- behavioral correlation
- threshold analytics
- brute force detections

---

# 3. Authentication Velocity Telemetry

## Observed Telemetry

```text
5-15 failed login attempts
within 1-5 minutes
```

---

## Threat Mapping Analysis

Rapid retry behavior aligned with:
- automated credential attacks
- scripted authentication abuse
- brute force tooling behavior

This telemetry strongly indicated:
- abnormal authentication frequency
- persistent attack behavior
- automated password guessing

Mapped ATT&CK behavior:

```text
T1110.001 — Password Guessing
```

---

## Detection Significance

Retry velocity directly influenced:
- threshold engineering
- temporal analytics
- brute force correlation logic

---

# 4. Invalid Username Telemetry

## Observed Telemetry

```text
Invalid user
Failed password for invalid user
```

Observed usernames included:

```text
root
admin
ubuntu
test
```

---

## Threat Mapping Analysis

This behavior aligned with:
- username enumeration
- account discovery attempts
- credential spraying behavior

Attackers frequently attempt:
- default accounts
- administrative usernames
- common Linux usernames

Mapped ATT&CK behavior:

```text
T1110.001 — Password Guessing
```

---

## Detection Significance

Username diversity significantly improved:
- brute force detection confidence
- malicious activity classification
- false positive reduction

---

# 5. PAM Authentication Failure Telemetry

## Observed Telemetry

```text
pam_unix(sshd:auth): authentication failure
error: PAM: Authentication failure
```

---

## Threat Mapping Analysis

These events confirmed:
- failed credential validation
- denied authentication requests
- rejected account access attempts

This telemetry aligned with:
- repeated authentication abuse
- failed login operations
- credential attack activity

Mapped ATT&CK behavior:

```text
T1110 — Brute Force
```

---

## Detection Significance

PAM telemetry strengthened:
- authentication visibility
- detection confidence
- credential abuse analytics

---

# 6. SSH Disconnect and Pre-Authentication Termination Telemetry

## Observed Telemetry

```text
Connection closed by authenticating user
Received disconnect from
Disconnected from invalid user
maximum authentication attempts exceeded
```

---

## Threat Mapping Analysis

These events indicated:
- repeated authentication abuse
- SSH daemon defensive behavior
- connection termination during failed authentication attempts

This behavior aligned with:
- aggressive login retry activity
- persistent credential guessing
- abnormal SSH authentication sessions

Mapped ATT&CK behavior:

```text
T1110.001 — Password Guessing
```

---

## Detection Significance

Disconnect telemetry provided:
- supporting behavioral evidence
- additional brute force confidence
- authentication abuse validation

---

# Investigation-to-Threat Mapping

# Investigation Findings

The investigation identified the following behavioral pattern:

```text
Repeated authentication failures
+
same source IP
+
high retry velocity
+
multiple usernames
+
PAM failures
+
SSH disconnect behavior
=
probable SSH brute force activity
```

---

# Threat Mapping Interpretation

The investigation confirmed that the simulation behavior aligned closely with real-world brute force intrusion activity.

The telemetry demonstrated:
- repeated credential guessing
- authentication abuse persistence
- abnormal login retry patterns
- possible automated attack behavior

This mapped directly to adversary credential access operations under:

```text
Credential Access
    ↓
T1110 — Brute Force
    ↓
T1110.001 — Password Guessing
```

---

# Detection Engineering Relevance

## Threat-Informed Detection Engineering

The threat mapping process directly informed:
- behavioral analytics
- threshold engineering
- Sigma rule development
- authentication anomaly correlation

---

## ATT&CK-Aligned Detection Areas

The mapped telemetry supported detections for:
- repeated SSH login failures
- authentication anomaly clustering
- password guessing activity
- invalid username attempts
- threshold-triggering retry behavior
- SSH disconnect telemetry

---

# Detection Logic Derived from Threat Mapping

The following ATT&CK-aligned behavioral analytic was engineered:

```text
Repeated SSH authentication failures
+
same source IP
+
high retry velocity
+
multiple usernames
+
disconnect behavior
=
probable SSH brute force attack
```

This logic was directly derived from:
- telemetry analysis
- investigation findings
- ATT&CK threat mapping

---

# Sigma Rule Relevance

The threat mapping exercise identified critical indicators used in Sigma detection engineering.

Important detection strings included:

```text
Failed password
authentication failure
Invalid user
maximum authentication attempts exceeded
```

Important correlation fields included:

```text
source.ip
user.name
timestamp
message
event.outcome
```

---

# Adversary Behavior Characteristics Observed

| Observed Behavior | ATT&CK Relevance |
|---|---|
| Repeated failed logins | T1110 |
| Password guessing | T1110.001 |
| Invalid username attempts | Credential guessing behavior |
| High retry velocity | Automated brute force behavior |
| Source IP repetition | Persistent attack activity |
| SSH disconnect behavior | Authentication abuse evidence |

---

# Threat Hunting Opportunities

The mapped telemetry provides hunting opportunities for:
- repeated authentication failures
- SSH login abuse
- invalid username spikes
- external source authentication attempts
- authentication retry anomalies
- successful logins after repeated failures

---

# Detection Engineering Findings

## Finding 1

Single failed SSH logins are weak indicators and insufficient for reliable threat detection.

Behavioral aggregation is required.

---

## Finding 2

Source IP correlation significantly improves ATT&CK-aligned brute force detections.

---

## Finding 3

Username diversity strongly indicates malicious credential guessing behavior.

---

## Finding 4

PAM and SSH disconnect telemetry provide valuable supporting evidence for authentication abuse detection.

---

## Finding 5

Threshold-based analytics effectively identify brute force activity aligned with ATT&CK T1110.

---

# Final Threat Mapping Conclusion

The SSH brute force simulation successfully generated telemetry consistent with adversary credential access behavior defined under MITRE ATT&CK technique T1110.

The threat mapping process confirmed alignment between:
- observed telemetry
- investigation findings
- authentication abuse behavior
- ATT&CK credential access tradecraft

Observed telemetry demonstrated:
- repeated password guessing
- persistent authentication abuse
- source-correlated login attempts
- rapid retry behavior
- invalid username targeting
- SSH daemon disconnect activity

The investigation and telemetry analysis directly contributed to:
- ATT&CK-aligned detection engineering
- threshold-based brute force analytics
- Sigma rule development
- behavioral authentication detections
- threat-informed SSH monitoring strategies
