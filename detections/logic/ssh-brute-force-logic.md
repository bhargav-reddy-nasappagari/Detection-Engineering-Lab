# SSH Brute Force Detection Logic

## ATT&CK Mapping

- Technique: T1110 — Brute Force
- Sub-Technique: T1110.001 — Password Guessing

---

# Objective

Detect repeated SSH authentication failures originating from the same source attempting to gain unauthorized access through password guessing or credential spraying behavior.

The goal of the detection is not merely to identify failed SSH logins individually, but to correlate authentication failure patterns that indicate systematic password guessing activity.

---

# Detection Hypothesis

If a single source repeatedly generates SSH authentication failures against the same host within a short time window, and the activity produces SSH daemon pre-authentication termination behavior or rate-limiting indicators, the activity is likely indicative of SSH brute force attempts.

---

# Detection Strategy

The detection logic is correlation-based rather than single-event based.

A single failed SSH login is normal operational behavior.

The detection becomes meaningful when:

- failures occur repeatedly
- failures originate from the same source
- failures occur in a short interval
- SSH daemon defensive behavior appears
- authentication anomalies cluster together

---

# Core Detection Logic

## Primary Analytic

```text
IF:

multiple failed SSH authentication attempts
occur from the same source IP
within a short time window

AND

authentication failure count exceeds threshold

THEN:

flag potential SSH brute force activity
```

---

# Correlation Components

## 1. Failed Authentication Events

Primary indicators:

```text
Failed password for invalid user
Failed password for user
authentication failure
Invalid user
pam_unix(sshd:auth): authentication failure
```

These events indicate unsuccessful SSH authentication attempts.

---

## 2. Source IP Repetition

The most important correlation field is:

```text
source.ip
```

Brute force attacks typically generate:

- repeated attempts from the same IP
- rapid retry behavior
- multiple username guesses

---

## 3. Time Window Correlation

Failures must occur within a constrained interval.

Example:

```text
5-15 failed attempts
within 1-5 minutes
```

This helps distinguish:

- normal user mistakes

from

- automated guessing behavior

---

## 4. SSH Daemon Defensive Indicators

Additional supporting telemetry strengthens detection confidence.

Observed indicators may include:

```text
Connection closed by authenticating user
Received disconnect from
maximum authentication attempts exceeded
PAM authentication failure
Disconnected from invalid user
error: PAM: Authentication failure
```

These events frequently appear during brute force simulations because SSH terminates abusive or failed authentication sessions.

---

# Derived Detection Logic

## High-Level Logic

```sql
SELECT source.ip
FROM ssh_authentication_logs

WHERE
    event.category = "authentication"
    AND event.outcome = "failure"

GROUP BY source.ip

HAVING
    COUNT(failed_attempts) > threshold
    WITHIN short_time_window
```

---

# Enhanced Analytic Logic

Additional confidence may be added if:

```text
same source IP
+
multiple usernames attempted
+
repeated failures
+
pre-auth termination behavior
```

This reduces false positives from users repeatedly mistyping a single password.

---

# Example Behavioral Pattern

## Suspicious Pattern

```text
192.168.1.50
    ├── failed login for root
    ├── failed login for admin
    ├── failed login for ubuntu
    ├── failed login for test
    ├── repeated within 60 seconds
    └── SSH disconnect/preauth termination observed
```

This strongly suggests password guessing activity.

---

# Potential False Positives

## 1. Legitimate User Password Mistyping

A legitimate user may:

- forget credentials
- repeatedly mistype passwords
- use outdated passwords

This can trigger threshold-based detections.

---

## 2. Administrative Testing

SOC analysts or administrators may intentionally:

- test SSH authentication
- validate detections
- simulate failures

This can resemble brute force behavior.

---

## 3. Automation or Configuration Errors

Broken scripts or outdated automation may repeatedly attempt SSH logins using invalid credentials.

Examples:

- CI/CD jobs
- backup scripts
- automation agents
- monitoring integrations

---

# False Positive Reduction Opportunities

## Improve Detection Fidelity Using:

### Username Diversity

Flag if:

- many usernames are attempted
- enumeration-like behavior exists

---

### Failure Velocity

Higher confidence if:

- failures occur rapidly
- retries happen within seconds

---

### Geographic or Network Context

Higher severity if:

- source IP is external
- source is previously unseen
- source reputation is suspicious

---

### Authentication Success After Failures

Possible brute force success indicator:

```text
multiple failures
followed by
successful login
```

This should significantly increase severity.

---

# Recommended Telemetry Sources

## Linux Authentication Logs

Primary sources:

```text
/var/log/auth.log
/var/log/secure
journalctl -u ssh
```

---

## SSH Daemon Logs

Telemetry from:

- sshd
- PAM
- system journal

---

## Auditd (Optional)

Useful for:

- session correlation
- process visibility
- authentication tracing

---

# Important Detection Engineering Insight

A brute force detection should never rely solely on:

- one failed login
- isolated authentication errors

Effective SSH brute force detection requires:

- aggregation
- temporal analysis
- source correlation
- behavioral clustering

This is fundamentally a behavioral detection problem, not a signature problem.

---

# Recommended Detection Severity

| Condition | Severity |
|---|---|
| Few repeated failures | Low |
| High-volume repeated failures | Medium |
| Multiple usernames targeted | High |
| Failures followed by successful login | Critical |

---

# Final Detection Conclusion

The derived SSH brute force detection logic is based on identifying repeated SSH authentication failures from the same source within a constrained timeframe and correlating them with SSH daemon authentication anomalies and connection termination behavior.

The detection becomes significantly stronger when enriched with:

- username diversity
- authentication velocity
- session termination indicators
- post-failure successful authentication events

This produces a practical behavior-based analytic aligned to real-world SSH brute force activity under ATT&CK technique T1110.
# SSH Brute Force Detection Logic

## ATT&CK Mapping

- Technique: T1110 — Brute Force
- Sub-Technique: T1110.001 — Password Guessing

---

# Detection Objective

The objective of this detection logic is to identify SSH brute force activity by correlating repeated authentication failures, abnormal retry behavior, username guessing activity, and SSH daemon defensive responses observed during the simulation.

The detection logic was engineered from:
- telemetry analysis
- investigation findings
- threat mapping analysis
- behavioral correlation
- validation observations

The analytic focuses on behavior-based detection rather than isolated event matching.

---

# Detection Hypothesis

If a source repeatedly attempts SSH authentication using invalid credentials and multiple usernames within a short timeframe, and the activity generates SSH daemon authentication failures or disconnect behavior, the activity is likely indicative of SSH brute force attempts.

---

# Detection Engineering Approach

The detection logic was engineered using:
- authentication telemetry analysis
- source correlation
- retry velocity analysis
- username diversity analysis
- SSH daemon disconnect telemetry
- PAM authentication failure visibility

The detection does not rely on:
- single failed login events
- isolated authentication failures
- signature-only matching

Instead, the detection relies on:
- behavioral aggregation
- temporal correlation
- authentication anomaly clustering

---

# Core Detection Logic

## Primary Analytic

```text
IF:

multiple SSH authentication failures
originate from the same source IP
within a constrained timeframe

AND

authentication retry velocity exceeds normal behavior

THEN:

flag probable SSH brute force activity
```

---

# Enhanced Behavioral Logic

## High-Confidence Analytic

```text
Repeated authentication failures
+
same source IP
+
high retry velocity
+
multiple usernames
+
PAM authentication failures
+
SSH disconnect/pre-auth termination behavior
=
probable SSH brute force attack
```

This analytic represents the final behavioral correlation model derived during the investigation and telemetry analysis phases.

---

# Detection Components

# 1. Failed Authentication Detection

## Observed Indicators

```text
Failed password for invalid user
Failed password for user
authentication failure
Invalid user
```

---

## Detection Significance

These events represent:
- unsuccessful authentication attempts
- credential rejection behavior
- SSH authentication abuse

These are the foundational brute force indicators used in the analytic.

---

# 2. PAM Authentication Failure Detection

## Observed Indicators

```text
pam_unix(sshd:auth): authentication failure
error: PAM: Authentication failure
```

---

## Detection Significance

PAM telemetry confirms:
- authentication rejection
- credential validation failure
- denied account access

PAM visibility strengthens detection fidelity and authentication context.

---

# 3. Source IP Correlation Logic

## Observed Behavior

```text
same source IP
+
multiple failed authentication attempts
+
short timeframe
```

---

## Detection Significance

Source IP repetition strongly indicates:
- persistent authentication abuse
- repeated credential guessing
- brute force retry behavior

This became one of the strongest behavioral indicators observed during the simulation.

---

# 4. Authentication Velocity Logic

## Observed Pattern

```text
5-15 failed authentication attempts
within 1-5 minutes
```

---

## Detection Significance

High retry velocity indicates:
- automated or scripted behavior
- abnormal authentication frequency
- rapid credential guessing activity

Velocity analysis is critical for distinguishing:
- malicious brute force behavior
from
- normal user login mistakes

---

# 5. Username Diversity Logic

## Observed Usernames

```text
root
admin
ubuntu
test
```

---

## Detection Significance

Multiple targeted usernames indicate:
- password spraying behavior
- username enumeration
- credential guessing activity

Username diversity significantly improves:
- detection confidence
- malicious activity classification
- false positive reduction

---

# 6. SSH Disconnect and Pre-Authentication Termination Logic

## Observed Indicators

```text
Connection closed by authenticating user
Received disconnect from
Disconnected from invalid user
maximum authentication attempts exceeded
```

---

## Detection Significance

These events indicate:
- SSH daemon defensive behavior
- repeated authentication abuse
- abnormal session handling

Disconnect telemetry serves as strong supporting evidence during correlation analysis.

---

# Temporal Correlation Logic

## Time-Based Analytic

```text
same source IP
+
5 or more failed authentication attempts
+
within 5 minutes
=
suspicious authentication activity
```

---

## Detection Significance

Temporal analysis enables:
- threshold engineering
- retry behavior analysis
- authentication anomaly clustering

This is essential for behavior-based brute force detection.

---

# Detection Workflow Logic

## Behavioral Flow

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
    ↓
repeated authentication cycle
```

---

## Detection Interpretation

The repeated authentication cycle indicates:
- persistent credential guessing
- repeated retry behavior
- abnormal authentication sequencing

This workflow became central to the final analytic design.

---

# Threshold Logic

## Recommended Threshold

```text
5 or more failed SSH authentication attempts
from same source IP
within 5 minutes
```

---

## Threshold Purpose

The threshold helps:
- reduce false positives
- distinguish malicious activity
- identify abnormal retry behavior

Threshold tuning should be adjusted depending on:
- environment size
- authentication patterns
- SSH exposure level
- user behavior baselines

---

# Detection Severity Logic

| Condition | Severity |
|---|---|
| Single failed login | Low |
| Repeated failures from same IP | Medium |
| High retry velocity | Medium |
| Multiple usernames targeted | High |
| SSH disconnect/preauth behavior | High |
| Failures followed by successful login | Critical |

---

# Successful Authentication Correlation Logic

## Escalation Analytic

```text
multiple failed authentication attempts
+
same source IP
+
successful SSH authentication
=
possible brute force compromise
```

---

## Detection Significance

This pattern may indicate:
- successful credential guessing
- account compromise
- successful brute force intrusion

This should immediately elevate detection severity.

---

# Detection-Relevant Telemetry Fields

## Important Correlation Fields

```text
timestamp
hostname
source.ip
user.name
event.outcome
message
process.name
service.name
```

---

# Detection-Relevant Log Sources

## Primary Sources

```text
/var/log/auth.log
/var/log/secure
journalctl -u ssh
```

---

## Secondary Sources

```text
PAM authentication logs
SSH daemon logs
system journal
```

---

# False Positive Considerations

Potential false positives include:
- users repeatedly mistyping passwords
- outdated credentials
- broken automation
- CI/CD authentication failures
- administrative testing
- SOC validation exercises

---

# False Positive Reduction Strategies

## Improve Detection Fidelity Using:

### Username Diversity

```text
multiple usernames attempted
from same source
```

---

### Retry Velocity

```text
rapid authentication retries
within constrained timeframe
```

---

### External Source Analysis

```text
external or previously unseen source IPs
```

---

### Authentication Success Correlation

```text
multiple failures
followed by successful authentication
```

---

# Detection Engineering Findings

## Finding 1

Single failed SSH logins are weak indicators and should not independently trigger high-confidence alerts.

---

## Finding 2

Behavioral aggregation significantly improves brute force detection quality.

---

## Finding 3

Source IP repetition is one of the strongest brute force indicators.

---

## Finding 4

Username diversity strongly indicates malicious credential guessing behavior.

---

## Finding 5

PAM and SSH disconnect telemetry provide valuable supporting evidence for authentication abuse detections.

---

## Finding 6

Threshold-based analytics effectively differentiate malicious activity from legitimate authentication mistakes.

---

# Final Detection Logic Conclusion

The SSH brute force detection logic was engineered from:
- observed telemetry
- investigation findings
- behavioral analysis
- threat mapping
- validation results

The final analytic identifies:
- repeated authentication failures
- source-correlated retry behavior
- abnormal authentication velocity
- username guessing activity
- PAM authentication failures
- SSH daemon disconnect behavior

The logic provides a behavior-based approach for detecting SSH brute force activity aligned with MITRE ATT&CK technique T1110.

The engineered detection model supports:
- threshold-based analytics
- Sigma rule development
- ATT&CK-aligned detections
- authentication anomaly monitoring
- behavioral SSH brute force detection engineering
