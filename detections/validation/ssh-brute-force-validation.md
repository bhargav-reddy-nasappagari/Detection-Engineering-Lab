# SSH Brute Force Detection Validation Report

# ATT&CK Mapping

| Category      | Mapping                       |
| ------------- | ----------------------------- |
| Technique     | T1110 — Brute Force           |
| Sub-Technique | T1110.001 — Password Guessing |
| Tactic        | Credential Access             |

---

# Validation Objective

The purpose of this validation exercise was to verify that the SSH brute force simulation generated realistic and operationally useful telemetry capable of supporting behavior-based detection engineering.

The validation focused on confirming:

* telemetry integrity and visibility
* investigation accuracy
* ATT&CK-aligned threat mapping
* behavioral detection reliability
* Sigma rule effectiveness
* threshold correlation fidelity
* operational detection usefulness
* false positive handling capability

The validation also evaluated whether the engineered analytics could distinguish malicious authentication abuse from normal authentication failures.

---

# Validation Scope

The validation included analysis of:

* SSH daemon authentication logs
* PAM authentication telemetry
* invalid username activity
* repeated authentication failures
* source IP correlation
* authentication retry velocity
* pre-authentication disconnect behavior
* username enumeration activity
* threshold-triggered detection logic
* Sigma rule matching behavior
* post-simulation cleanup verification

---

# Validation Workflow

The validation followed the structured detection engineering workflow used throughout the repository.

```text
Scenario Simulation
    ↓
Raw Telemetry Collection
    ↓
Telemetry Analysis
    ↓
Investigation
    ↓
Threat Mapping
    ↓
Detection Logic Engineering
    ↓
Sigma Rule Development
    ↓
Validation
```

---

# Scenario Summary

## Simulation Overview

The simulation generated repeated SSH authentication failures against a Linux host using scripted `sshpass` authentication attempts targeting invalid and non-existent usernames.

The simulation intentionally produced:

* repeated password failures
* invalid user activity
* PAM authentication failures
* SSH daemon disconnect behavior
* threshold-triggering authentication bursts

---

# Environment Information

| Component             | Value                   |
| --------------------- | ----------------------- |
| Target Host           | bunny-VirtualBox        |
| Operating System      | Ubuntu Linux            |
| Service Targeted      | OpenSSH                 |
| Telemetry Sources     | auth.log, journalctl    |
| Attack Tooling        | sshpass                 |
| Authentication Method | Password Authentication |

---

# Raw Telemetry Validation

# 1. SSH Authentication Failure Validation

## Validated Telemetry

Observed authentication failure indicators:

```text
Failed password for invalid user
Failed password for user
authentication failure
Invalid user
```

---

## Observed Log Evidence

```text
Failed password for invalid user invaliduser from 127.0.0.1 port 49450 ssh2
```

```text
pam_unix(sshd:auth): authentication failure
```

---

## Validation Analysis

The telemetry successfully demonstrated:

* repeated SSH authentication failures
* rejected credential usage
* invalid account targeting
* SSH daemon authentication handling
* authentication denial behavior

The authentication logs aligned directly with expected SSH brute force activity patterns.

The telemetry quality was sufficient for:

* threshold detections
* behavioral analytics
* correlation-based detections
* ATT&CK-aligned investigation

---

## Validation Status

```text
VALIDATED
```

---

# 2. PAM Authentication Telemetry Validation

## Observed Telemetry

```text
pam_unix(sshd:auth): check pass; user unknown
pam_unix(sshd:auth): authentication failure
PAM 2 more authentication failures
```

---

## Validation Analysis

PAM telemetry successfully validated:

* backend authentication rejection
* repeated credential failures
* invalid user authentication attempts
* aggregated authentication failure reporting

PAM logs provided important secondary telemetry capable of strengthening detection confidence when correlated with SSH daemon logs.

This telemetry significantly improved:

* authentication visibility
* behavioral confidence scoring
* brute force correlation fidelity

---

## Validation Status

```text
VALIDATED
```

---

# 3. Source IP Correlation Validation

## Observed Telemetry

Repeated authentication failures originated from:

```text
127.0.0.1
```

within a short timeframe.

---

## Validation Analysis

The repeated reuse of the same source IP validated:

* persistent authentication abuse behavior
* repeated credential retry activity
* brute-force-style source correlation patterns

Source IP reuse became one of the strongest validated indicators for aggregation-based brute force detection.

The validation confirmed that source-based grouping significantly improves detection reliability compared to isolated authentication failures.

---

## Validation Status

```text
VALIDATED
```

---

# 4. Authentication Velocity Validation

## Observed Behavior

Multiple failed authentication attempts occurred within a compressed time interval.

Observed examples included:

```text
multiple failures within seconds
```

---

## Validation Analysis

The authentication retry velocity demonstrated:

* scripted authentication abuse
* non-human retry behavior
* rapid credential guessing activity

The validation confirmed that authentication frequency and retry timing are highly effective for threshold-based SSH brute force detection engineering.

Velocity analysis significantly reduced ambiguity between:

* isolated login mistakes
* malicious authentication abuse

---

## Validation Status

```text
VALIDATED
```

---

# 5. Username Enumeration Validation

## Observed Usernames

Observed targeted usernames included:

```text
invaliduser
root
admin
test
ubuntu
```

---

## Validation Analysis

The targeted username diversity validated:

* username guessing behavior
* account discovery attempts
* credential spraying characteristics
* reconnaissance-oriented authentication abuse

The validation confirmed that username diversity strongly increases malicious confidence scoring when combined with:

* retry velocity
* source correlation
* authentication failures

---

## Validation Status

```text
VALIDATED
```

---

# 6. SSH Disconnect Behavior Validation

## Observed Telemetry

```text
Connection closed by invalid user invaliduser 127.0.0.1 port 49450 [preauth]
```

---

## Validation Analysis

SSH daemon disconnect telemetry successfully validated:

* defensive SSH behavior
* authentication session rejection
* repeated authentication abuse handling
* pre-authentication connection termination

Disconnect behavior provided valuable supporting telemetry capable of strengthening behavioral detections.

The validation confirmed that disconnect telemetry improves:

* brute force confidence scoring
* authentication abuse context
* investigation fidelity

---

## Validation Status

```text
VALIDATED
```

---

# Investigation Validation

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
PAM authentication failures
+
SSH disconnect behavior
=
probable SSH brute force activity
```

---

# Investigation Analysis

The investigation successfully transformed raw telemetry into actionable detection intelligence.

The investigation correctly identified:

* authentication abuse behavior
* repeated credential retry activity
* username guessing behavior
* SSH daemon defensive responses
* threshold-triggering authentication anomalies

The investigation process demonstrated that meaningful behavioral analytics can be derived from standard Linux authentication telemetry.

---

# Investigation Validation Status

```text
VALIDATED
```

---

# Threat Mapping Validation

# ATT&CK Techniques Reviewed

| Technique | Description       |
| --------- | ----------------- |
| T1110     | Brute Force       |
| T1110.001 | Password Guessing |

---

# Threat Mapping Analysis

The observed telemetry aligned directly with ATT&CK-defined brute force behavior, including:

* repeated password guessing
* invalid account targeting
* SSH authentication abuse
* repeated credential retry activity

The validation confirmed that:

* the simulation accurately represented ATT&CK-aligned adversary behavior
* the telemetry reflected realistic authentication abuse patterns
* the engineered detections remained threat-informed

---

# Threat Mapping Validation Status

```text
VALIDATED
```

---

# Detection Logic Validation

# Primary Detection Analytic

```text
multiple SSH authentication failures
+
same source IP
+
high retry velocity
=
probable SSH brute force activity
```

---

# Enhanced Behavioral Analytic

```text
Repeated authentication failures
+
same source IP
+
multiple usernames
+
PAM failures
+
pre-auth disconnect behavior
=
high-confidence SSH brute force detection
```

---

# Detection Logic Analysis

The validation confirmed that:

* behavioral aggregation significantly improves detection quality
* source correlation improves reliability
* temporal analysis reduces ambiguity
* supporting PAM telemetry strengthens confidence scoring
* disconnect telemetry improves contextual fidelity

The detection logic successfully differentiated:

* suspicious authentication abuse
  from
* isolated authentication mistakes

---

# Detection Logic Validation Status

```text
VALIDATED
```

---

# Sigma Rule Validation

# Validated Sigma Detection Areas

## Rule 1 — SSH Authentication Failure Detection

### Validated Indicators

```text
Failed password
authentication failure
Invalid user
```

### Validation Outcome

The rule successfully matched repeated SSH authentication failures and invalid user activity.

---

## Rule 2 — Threshold Correlation Detection

### Validated Logic

```text
same source IP
+
5 or more failed authentication attempts
+
within short timeframe
```

### Validation Outcome

The threshold logic successfully identified suspicious authentication clustering behavior.

---

## Rule 3 — Username Guessing Detection

### Validated Logic

```text
multiple usernames
from same source IP
within short timeframe
```

### Validation Outcome

The rule successfully identified username enumeration behavior and credential spraying characteristics.

---

## Rule 4 — Pre-Authentication Disconnect Detection

### Validated Logic

```text
Connection closed
+
invalid user
+
preauth
```

### Validation Outcome

The rule successfully identified SSH daemon defensive disconnect behavior associated with authentication abuse.

---

# Sigma Rule Validation Status

```text
VALIDATED
```

---

# Detection Fidelity Validation

# Validated Detection Strengths

The validation confirmed the effectiveness of:

* behavioral aggregation
* temporal analytics
* source IP correlation
* username diversity analysis
* PAM authentication telemetry
* SSH disconnect telemetry
* threshold-based analytics

---

# Detection Weaknesses Identified

The validation identified several limitations:

* single failed SSH logins remain weak indicators
* isolated authentication failures should not independently trigger high-confidence alerts
* shared NAT environments may reduce source IP attribution fidelity
* internal SSH automation may generate similar telemetry patterns

---

# False Positive Validation

# Potential False Positives Reviewed

The validation identified legitimate activities capable of generating similar telemetry.

Potential false positives included:

* mistyped passwords
* outdated credentials
* broken SSH automation
* CI/CD authentication failures
* administrative testing
* vulnerability scanning
* SOC validation exercises

---

# False Positive Reduction Methods

The validation confirmed that false positives can be reduced using:

* retry thresholds
* source correlation
* username diversity analysis
* authentication velocity analysis
* behavioral aggregation
* contextual enrichment

---

# Cleanup Verification Validation

# Cleanup Activities Reviewed

The validation confirmed that:

* no active `sshpass` processes remained running
* SSH service remained operational
* no lingering brute-force sessions persisted
* authentication telemetry remained preserved
* the environment returned to stable operational state

---

# Cleanup Validation Evidence

Validated using:

```bash
ps aux | grep sshpass
pgrep sshpass
ss -antp | grep :22
sudo tail -20 /var/log/auth.log
```

---

# Validation Findings

## Finding 1

Behavioral aggregation significantly improves SSH brute force detection reliability.

---

## Finding 2

Source IP repetition is one of the strongest authentication abuse indicators.

---

## Finding 3

Username diversity strongly increases malicious confidence scoring.

---

## Finding 4

PAM telemetry provides valuable supporting evidence for authentication abuse detections.

---

## Finding 5

SSH disconnect telemetry improves brute-force detection confidence and investigation fidelity.

---

## Finding 6

Threshold-based analytics effectively distinguish malicious activity from isolated login mistakes.

---

## Finding 7

Threat-informed detection engineering improves ATT&CK alignment and operational detection quality.

---

# Final Validation Conclusion

The validation exercise confirmed that the SSH brute force simulation successfully generated realistic authentication abuse telemetry aligned with MITRE ATT&CK techniques T1110 and T1110.001.

The validation confirmed the operational accuracy and effectiveness of:

* telemetry analysis
* investigation findings
* threat mappings
* behavioral detection logic
* Sigma rule engineering
* threshold-based correlation analytics

The generated telemetry successfully demonstrated:

* repeated SSH authentication failures
* source-correlated login attempts
* rapid retry behavior
* username enumeration activity
* PAM authentication failures
* SSH daemon disconnect behavior
* threshold-triggering authentication anomalies

The engineered detection logic and Sigma rules were successfully validated against observed simulation telemetry and demonstrated a reliable behavior-based approach for Linux SSH brute force detection engineering.

The simulation environment successfully returned to a stable state after validation completion with no remaining attacker tooling active.
