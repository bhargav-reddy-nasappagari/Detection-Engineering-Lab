# SSH Brute Force Investigation

## ATT&CK Mapping

- Technique: T1110 — Brute Force
- Sub-Technique: T1110.001 — Password Guessing

---

# Investigation Objective

The objective of this investigation was to analyze the telemetry generated during the SSH brute force simulation and determine whether the observed authentication activity represented malicious password guessing behavior.

The investigation focused on:
- repeated SSH authentication failures
- authentication anomaly correlation
- source IP repetition
- username guessing behavior
- PAM authentication failures
- SSH daemon disconnect activity
- threshold-triggering authentication patterns

The investigation also aimed to determine how the observed telemetry contributed to:
- detection engineering
- behavioral analytics
- Sigma rule development
- brute force detection logic

---

# Investigation Scope

The investigation included analysis of:
- Linux authentication logs
- SSH daemon telemetry
- PAM authentication events
- failed authentication sequences
- session disconnect behavior
- source-based authentication activity
- retry velocity patterns

---

# Investigation Methodology

The investigation followed the detection engineering workflow:

```text
Simulation Execution
    ↓
Raw Telemetry Preservation
    ↓
Authentication Log Review
    ↓
Behavior Correlation
    ↓
Threat Analysis
    ↓
Detection Logic Engineering
    ↓
Sigma Rule Development
    ↓
Validation
```

---

# Initial Observation

The investigation began after repeated SSH authentication failures were observed during the simulation.

Initial suspicious indicators included:
- recurring failed SSH logins
- repeated invalid user attempts
- rapid authentication retry behavior
- repeated authentication attempts from the same source

These behaviors immediately suggested possible brute force activity.

---

# Telemetry Sources Investigated

## 1. Linux Authentication Logs

Primary investigation sources included:

```text
/var/log/auth.log
/var/log/secure
journalctl -u ssh
```

These logs provided:
- SSH authentication outcomes
- invalid username attempts
- PAM authentication telemetry
- disconnect behavior
- session rejection events

---

# Authentication Failure Investigation

## Observed Telemetry

The following authentication failure indicators were repeatedly observed:

```text
Failed password for invalid user
Failed password for user
authentication failure
Invalid user
```

---

## Investigation Analysis

These events demonstrated:
- repeated credential rejection
- unsuccessful SSH authentication
- persistent login retry behavior

Individually, these events were weak indicators.

However, repeated occurrence and correlation significantly increased suspicion.

---

# Source IP Correlation Investigation

## Observed Telemetry

The same source IP repeatedly generated authentication failures.

Observed pattern:

```text
same source IP
+
multiple failed authentication attempts
+
short timeframe
```

---

## Investigation Analysis

This behavior indicated:
- repetitive authentication abuse
- persistence from a single origin
- possible automated credential guessing

Source correlation became one of the strongest indicators supporting brute force detection logic.

---

# Authentication Velocity Investigation

## Observed Telemetry

Authentication failures occurred rapidly.

Observed behavior:

```text
5-15 failed authentication attempts
within 1-5 minutes
```

---

## Investigation Analysis

The observed retry velocity suggested:
- automated behavior
- scripted authentication attempts
- abnormal login frequency

This behavior differed significantly from normal user authentication mistakes.

The investigation confirmed that retry velocity was highly valuable for threshold-based detections.

---

# PAM Authentication Failure Investigation

## Observed Telemetry

PAM-related authentication rejection events included:

```text
pam_unix(sshd:auth): authentication failure
error: PAM: Authentication failure
```

---

## Investigation Analysis

PAM telemetry confirmed:
- credential validation failure
- authentication denial
- rejected login attempts

PAM events provided additional evidence supporting brute force detection confidence.

---

# Invalid Username Investigation

## Observed Telemetry

The simulation generated invalid username attempts.

Observed indicators included:

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

## Investigation Analysis

This behavior strongly suggested:
- username enumeration
- password spraying
- brute force reconnaissance

The investigation determined that username diversity significantly strengthened detection fidelity.

---

# SSH Daemon Disconnect Investigation

## Observed Telemetry

The SSH daemon generated disconnect and session termination behavior.

Observed indicators included:

```text
Connection closed by authenticating user
Received disconnect from
Disconnected from invalid user
maximum authentication attempts exceeded
```

---

## Investigation Analysis

These events indicated:
- SSH defensive response behavior
- repeated authentication abuse
- session termination during failed authentication attempts

Disconnect telemetry served as strong supporting evidence during the investigation.

---

# Authentication Sequence Investigation

## Observed Authentication Flow

The following activity sequence was repeatedly observed:

```text
SSH connection initiated
    ↓
authentication attempt
    ↓
credential rejection
    ↓
authentication failure logged
    ↓
retry attempt
    ↓
disconnect/pre-auth termination
```

---

## Investigation Analysis

The repeated authentication cycle demonstrated:
- persistent credential guessing
- repeated retry behavior
- abnormal authentication sequencing

The investigation confirmed that authentication sequence analysis is critical for behavior-based brute force detections.

---

# Behavioral Correlation Investigation

## Correlated Indicators

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

## Investigation Analysis

The investigation confirmed that:
- isolated failed logins are weak indicators
- aggregated authentication telemetry produces reliable detections
- behavioral clustering is more effective than signature-only matching

This became the foundation for the derived detection logic.

---

# Threshold Investigation

## Observed Threshold Behavior

The simulation generated threshold-triggering activity.

Observed condition:

```text
5 or more failed authentication attempts
from same source IP
within 5 minutes
```

---

## Investigation Analysis

The threshold investigation confirmed:
- repetitive authentication behavior was detectable
- temporal analysis improved reliability
- aggregation logic effectively differentiated suspicious activity from isolated login mistakes

This directly influenced Sigma correlation rule engineering.

---

# Detection Engineering Significance

## Detection Logic Impact

The investigation findings directly contributed to the derived detection logic.

The following analytic was engineered from observed telemetry:

```text
Repeated SSH authentication failures
+
same source IP
+
rapid retry behavior
+
multiple usernames
+
disconnect behavior
=
probable SSH brute force attack
```

---

## Sigma Rule Significance

The investigation identified critical indicators for Sigma rule development.

Important detection fields included:

```text
source.ip
user.name
message
event.outcome
timestamp
service.name
```

Important detection strings included:

```text
Failed password
authentication failure
Invalid user
maximum authentication attempts exceeded
```

---

# False Positive Investigation

## Observed Legitimate-Like Behaviors

The investigation identified several possible false positive scenarios.

Potential false positives included:
- users forgetting passwords
- repeated password mistyping
- outdated SSH credentials
- broken automation
- CI/CD failures
- administrative testing
- SOC validation exercises

---

## Investigation Significance

The false positive investigation reinforced the importance of:
- threshold tuning
- behavioral aggregation
- retry velocity analysis
- username diversity analysis
- contextual enrichment

This helped refine the detection strategy and reduce noisy detections.

---

# Key Investigation Findings

## Finding 1

Single failed SSH authentication attempts are insufficient for reliable brute force detection.

Behavioral aggregation is required.

---

## Finding 2

Source IP repetition is a critical brute force indicator.

---

## Finding 3

Username diversity strongly indicates malicious credential guessing behavior.

---

## Finding 4

PAM authentication telemetry improves authentication visibility and detection confidence.

---

## Finding 5

SSH disconnect and pre-authentication termination events provide strong supporting evidence for authentication abuse detection.

---

## Finding 6

Threshold-based analytics effectively differentiate suspicious behavior from normal user mistakes.

---

# Final Investigation Conclusion

The investigation confirmed that the SSH brute force simulation successfully generated realistic authentication abuse telemetry consistent with ATT&CK technique T1110.

The investigation identified:
- repeated authentication failures
- source-correlated login attempts
- rapid retry behavior
- username guessing activity
- PAM authentication failures
- SSH daemon disconnect behavior
- threshold-triggering authentication patterns

The investigation demonstrated that effective SSH brute force detection depends on:
- behavioral aggregation
- temporal analysis
- source correlation
- authentication anomaly clustering
- supporting SSH daemon telemetry

The findings directly contributed to:
- detection logic engineering
- Sigma rule development
- threshold analytics
- false positive reduction strategies
- ATT&CK-aligned SSH brute force detection engineering
