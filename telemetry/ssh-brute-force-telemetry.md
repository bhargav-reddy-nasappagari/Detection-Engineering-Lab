# SSH Brute Force Telemetry Analysis

## ATT&CK Mapping

- Technique: T1110 — Brute Force
- Sub-Technique: T1110.001 — Password Guessing

---

# Analysis Objective

The objective of this telemetry analysis was to examine all observable artifacts generated during the SSH brute force simulation and identify the behavioral indicators associated with repeated SSH authentication abuse.

The analysis focused on:
- SSH authentication failures
- PAM authentication telemetry
- SSH daemon defensive behavior
- source IP correlation
- authentication retry velocity
- username guessing behavior
- session disconnect events
- threshold-triggering authentication activity

---

# Simulation Overview

The simulation emulated repeated SSH login attempts against a Linux host using invalid credentials and multiple usernames.

The generated activity produced:
- failed SSH authentication events
- PAM authentication failures
- SSH daemon disconnect telemetry
- repeated source-based authentication attempts
- authentication retry clustering

The telemetry closely resembled real-world SSH brute force behavior.

---

# Primary Telemetry Sources

## 1. Linux Authentication Logs

Primary telemetry was collected from:

```text
/var/log/auth.log
/var/log/secure
journalctl -u ssh
```

These logs provided:
- authentication outcomes
- SSH daemon activity
- PAM authentication telemetry
- disconnect behavior
- invalid user attempts

---

# Authentication Failure Telemetry

## Observed Indicators

The simulation generated repeated authentication failure events.

Observed log indicators included:

```text
Failed password for invalid user
Failed password for user
authentication failure
Invalid user
```

---

## Telemetry Analysis

These logs confirmed:
- unsuccessful authentication attempts
- invalid credential usage
- repeated SSH login failures

The repeated occurrence of these events represented the primary brute force indicator observed during the simulation.

---

# PAM Authentication Telemetry

## Observed Indicators

PAM-related telemetry included:

```text
pam_unix(sshd:auth): authentication failure
error: PAM: Authentication failure
```

---

## Telemetry Analysis

PAM logs confirmed:
- credential validation failures
- denied authentication requests
- authentication rejection behavior

PAM telemetry strengthened confidence that authentication attempts were unsuccessful and abnormal.

---

# Invalid User Telemetry

## Observed Indicators

The simulation generated invalid username authentication attempts.

Observed indicators included:

```text
Invalid user
Failed password for invalid user
```

---

## Telemetry Analysis

This telemetry indicated:
- username guessing behavior
- account enumeration attempts
- brute force reconnaissance behavior

Invalid user attempts significantly increased confidence that the activity was malicious rather than accidental.

---

# Source IP Correlation Telemetry

## Observed Behavior

Authentication failures repeatedly originated from the same source IP.

Observed pattern:

```text
same source IP
+
multiple failed authentication attempts
+
short timeframe
```

---

## Telemetry Analysis

Source correlation demonstrated:
- repetitive attack behavior
- authentication abuse concentration
- retry persistence from a single origin

This was one of the strongest behavioral indicators observed during the simulation.

---

# Authentication Velocity Telemetry

## Observed Behavior

Authentication failures occurred rapidly.

Observed pattern:

```text
5-15 failed login attempts
within 1-5 minutes
```

---

## Telemetry Analysis

The observed retry velocity indicated:
- automated or semi-automated behavior
- repeated credential guessing
- abnormal authentication frequency

This distinguished the activity from isolated user password mistakes.

---

# Username Guessing Telemetry

## Observed Usernames

The simulation targeted multiple usernames including:

```text
root
admin
ubuntu
test
```

---

## Observed Behavior

Observed pattern:

```text
multiple usernames
from same source IP
within short timeframe
```

---

## Telemetry Analysis

This behavior indicated:
- password spraying attempts
- username enumeration activity
- credential guessing operations

The diversity of targeted usernames significantly increased detection confidence.

---

# SSH Daemon Disconnect Telemetry

## Observed Indicators

The SSH daemon generated connection termination and defensive behavior.

Observed indicators included:

```text
Connection closed by authenticating user
Received disconnect from
Disconnected from invalid user
maximum authentication attempts exceeded
```

---

## Telemetry Analysis

This telemetry demonstrated:
- SSH daemon defensive response behavior
- authentication abuse handling
- session termination during repeated failures

These events served as strong supporting indicators for brute force activity.

---

# Pre-Authentication Termination Telemetry

## Observed Behavior

Repeated failed login attempts triggered pre-authentication disconnect behavior.

Observed characteristics included:
- abrupt session termination
- disconnect events during authentication
- connection closure before successful login

---

## Telemetry Analysis

Pre-authentication disconnect behavior suggested:
- repeated authentication abuse
- session rejection by SSH daemon protections
- abnormal login persistence

This telemetry strengthened brute force detection fidelity.

---

# Threshold Trigger Telemetry

## Observed Pattern

The simulation successfully generated threshold-triggering behavior.

Observed condition:

```text
multiple authentication failures
from same source IP
within constrained timeframe
```

---

## Telemetry Analysis

Threshold analytics successfully identified:
- repetitive authentication failures
- behavioral clustering
- suspicious retry activity

This validated the effectiveness of behavior-based brute force detection logic.

---

# Authentication Sequence Telemetry

## Observed Sequence

Observed activity progression:

```text
SSH connection initiated
    ↓
authentication attempt
    ↓
credential rejection
    ↓
authentication failure log
    ↓
retry attempt
    ↓
disconnect/preauth termination
```

---

## Telemetry Analysis

The repeated authentication sequence demonstrated:
- persistence behavior
- repeated credential guessing
- attack automation characteristics

---

# Behavioral Correlation Telemetry

## Observed Correlation Model

The following telemetry pattern was observed:

```text
Repeated failures
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

## Telemetry Analysis

The simulation validated that:
- isolated failures are weak indicators
- aggregated behavioral telemetry provides reliable detection
- correlation-based analytics are more effective than signature-only detections

---

# Authentication Outcome Telemetry

## Observed Outcomes

Observed authentication outcomes included:
- failed authentication
- invalid user rejection
- session disconnect
- pre-authentication termination

No successful authentication was required to validate brute force behavior.

---

# Telemetry Characteristics Observed

| Telemetry Type | Observation |
|---|---|
| Authentication failures | Repeated and clustered |
| Source IP activity | Repetitive |
| Retry velocity | Rapid |
| Username diversity | Present |
| PAM failures | Observed |
| SSH disconnect behavior | Observed |
| Threshold-triggering activity | Observed |
| Session rejection behavior | Observed |

---

# Detection-Relevant Telemetry Fields

## Important Fields Observed

```text
timestamp
hostname
source.ip
user.name
event.outcome
process.name
service.name
message
```

---

# Detection Engineering Findings

## Finding 1

Authentication failures alone are insufficient for reliable detection.

Behavioral aggregation is required.

---

## Finding 2

Source IP correlation significantly improves brute force detection quality.

---

## Finding 3

Username diversity strongly indicates malicious password guessing behavior.

---

## Finding 4

SSH disconnect telemetry provides valuable supporting evidence for authentication abuse detection.

---

## Finding 5

Threshold-based analytics effectively differentiate suspicious activity from legitimate user mistakes.

---

# False Positive Considerations

Telemetry similar to brute force activity may also originate from:
- users forgetting passwords
- outdated stored credentials
- broken automation
- CI/CD failures
- administrative testing
- SOC validation exercises

This reinforces the need for:
- temporal correlation
- threshold tuning
- username diversity analysis
- contextual enrichment

---

# Final Telemetry Analysis Conclusion

The SSH brute force simulation successfully generated realistic authentication abuse telemetry consistent with ATT&CK technique T1110.

Observed telemetry included:
- repeated SSH authentication failures
- invalid user attempts
- PAM authentication failures
- source-correlated login attempts
- rapid retry behavior
- SSH daemon disconnect telemetry
- threshold-triggering authentication activity

The analysis confirmed that effective SSH brute force detection depends on:
- behavioral aggregation
- temporal correlation
- source-based analysis
- authentication anomaly clustering
- supporting SSH daemon telemetry

The observed telemetry provided sufficient visibility to engineer reliable behavior-based SSH brute force detections and validate Sigma correlation logic.
