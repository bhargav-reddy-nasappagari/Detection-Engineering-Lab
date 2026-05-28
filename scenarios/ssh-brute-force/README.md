# SSH Brute Force Detection Scenario

# Scenario Overview

This scenario simulates SSH brute force activity against a Linux host in order to generate authentication abuse telemetry for detection engineering, investigation, threat mapping, and Sigma rule validation.

The simulation focuses on repeated SSH authentication failures, invalid username targeting, PAM authentication telemetry, and SSH daemon disconnect behavior commonly associated with credential guessing attacks.

The generated telemetry is used to:

* engineer behavior-based detections
* validate Sigma rules
* investigate authentication abuse patterns
* map adversary behavior to MITRE ATT&CK
* evaluate detection reliability and false positives

---

# ATT&CK Mapping

| Category      | Mapping                       |
| ------------- | ----------------------------- |
| Tactic        | Credential Access             |
| Technique     | T1110 — Brute Force           |
| Sub-Technique | T1110.001 — Password Guessing |

---

# Scenario Objectives

The objectives of this simulation were to:

* generate realistic SSH brute force telemetry
* observe Linux authentication logging behavior
* analyze PAM authentication failures
* validate threshold-based detections
* validate source IP correlation analytics
* validate username guessing detections
* validate Sigma detection rules
* evaluate brute force detection fidelity

---

# Environment Information

| Component             | Value                   |
| --------------------- | ----------------------- |
| Target Host           | bunny-VirtualBox        |
| Operating System      | Ubuntu Linux            |
| Target Service        | OpenSSH                 |
| Telemetry Sources     | auth.log, journalctl    |
| Attack Tooling        | sshpass                 |
| Authentication Method | Password Authentication |

---

# Prerequisites

The following components were required before simulation execution:

* OpenSSH server installed and running
* Linux authentication logging enabled
* sudo access
* terminal access to attacker and target systems
* `sshpass` installed
* packet capture capability (optional)

---

# Simulation Workflow

```text id="4r9mzc"
Attack Simulation
    ↓
Authentication Failures Generated
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
Sigma Rule Validation
    ↓
Cleanup Verification
```

---

# Attack Simulation

# Objective

Generate repeated SSH authentication failures using invalid credentials and multiple usernames.

---

# Tooling Used

```text id="ulh9gb"
sshpass
ssh
bash loop automation
```

---

# Simulated Attack Commands

## Example Authentication Attempt

```bash id="s8o7lo"
sshpass -p wrongpassword ssh invaliduser@127.0.0.1
```

---

## Example Repeated Authentication Attempts

```bash id="pjce5g"
for user in root admin test ubuntu invaliduser
do
    sshpass -p wrongpassword ssh $user@127.0.0.1
done
```

---

# Expected Behavioral Outcome

The simulation was expected to generate:

* repeated failed SSH authentication attempts
* invalid username activity
* PAM authentication failures
* repeated source IP correlation
* authentication retry bursts
* SSH pre-authentication disconnect behavior

---

# Telemetry Collection

# Primary Telemetry Sources

## Authentication Logs

```text id="t6t90r"
/var/log/auth.log
```

---

## SSH Journal Logs

```bash id="n5f12s"
journalctl -u ssh
```

---

## Packet Capture

```text id="4w4z7q"
evidence/ssh-brute-force/ssh-brute-force.pcap
```

---

# Key Observed Telemetry

## Failed Password Attempts

```text id="h2m6j4"
Failed password for invalid user invaliduser
```

---

## PAM Authentication Failures

```text id="k74r5z"
pam_unix(sshd:auth): authentication failure
```

---

## Invalid Username Activity

```text id="b88q7v"
Invalid user
```

---

## SSH Disconnect Behavior

```text id="5lv8u5"
Connection closed by invalid user [preauth]
```

---

# Investigation Summary

# Observed Behavioral Pattern

```text id="n7udaa"
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
pre-auth disconnect behavior
=
probable SSH brute force activity
```

---

# Investigation Findings

The investigation identified:

* repeated authentication abuse
* username guessing behavior
* authentication retry automation
* source-correlated brute force activity
* SSH daemon defensive behavior
* threshold-triggering authentication anomalies

The telemetry demonstrated realistic SSH credential guessing behavior aligned with brute force attack patterns.

---

# Threat Mapping

# ATT&CK Alignment

The observed telemetry aligned directly with:

| Technique | Description       |
| --------- | ----------------- |
| T1110     | Brute Force       |
| T1110.001 | Password Guessing |

---

# Threat-Informed Observations

The simulation demonstrated:

* repeated credential guessing
* invalid account targeting
* authentication retry automation
* SSH authentication abuse behavior

The telemetry accurately reflected ATT&CK-aligned credential access behavior.

---

# Detection Engineering

# Primary Detection Logic

```text id="sv4lix"
multiple SSH authentication failures
+
same source IP
+
high retry velocity
=
probable SSH brute force activity
```

---

# Enhanced Behavioral Detection Logic

```text id="e5ttci"
Repeated authentication failures
+
same source IP
+
multiple usernames
+
PAM failures
+
SSH disconnect behavior
=
high-confidence SSH brute force detection
```

---

# Detection Indicators

The following indicators proved highly valuable:

* repeated failed password attempts
* repeated source IP reuse
* invalid username targeting
* authentication retry velocity
* PAM authentication failures
* SSH pre-auth disconnect behavior

---

# Sigma Rule Validation

# Validated Detection Areas

The Sigma detections successfully validated:

* SSH authentication failure detection
* threshold-based authentication clustering
* username guessing detection
* source IP correlation
* pre-auth disconnect detection

---

# Detection Reliability Observations

The validation confirmed that:

* behavioral aggregation significantly improves reliability
* single failed logins remain weak indicators
* retry velocity strongly improves confidence
* username diversity increases malicious certainty
* PAM telemetry strengthens contextual awareness

---

# False Positive Considerations

# Potential False Positives

Legitimate activities capable of generating similar telemetry included:

* users mistyping passwords
* outdated credentials
* broken automation
* CI/CD authentication failures
* administrative testing
* internal security validation exercises

---

# False Positive Reduction Methods

False positives can be reduced using:

* authentication thresholds
* source correlation
* temporal analysis
* username diversity analysis
* contextual enrichment
* behavioral aggregation

---

# Evidence Collected

# Screenshots

```text id="l9j9zf"
evidence/ssh-brute-force/attacker-execution.png
evidence/ssh-brute-force/authentication-failure.png
evidence/ssh-brute-force/connection-drop-behaviour.png
evidence/ssh-brute-force/detection-trigger.png
evidence/ssh-brute-force/pam-authentication-failure.png
```

---

# Packet Capture

```text id="s5xb54"
evidence/ssh-brute-force/ssh-brute-force.pcap
```

---

# Logs

```text id="uhz6tk"
logs/ssh-brute-force/raw_auth_logs.txt
logs/ssh-brute-force/failed_password_logs.txt
logs/ssh-brute-force/pam_auth_failures.txt
logs/ssh-brute-force/disconnect_events_logs.txt
logs/ssh-brute-force/journalctl_ssh.txt
logs/ssh-brute-force/cleanup_verification.txt
logs/ssh-brute-force/attacker_processes.txt
```

---

# Cleanup Verification

# Verification Activities

The cleanup process confirmed:

* no active `sshpass` processes remained
* SSH services continued operating normally
* no lingering brute-force sessions persisted
* authentication telemetry remained preserved
* the environment returned to stable operational state

---

# Verification Commands

```bash id="eu6g17"
ps aux | grep sshpass
```

```bash id="ap4r6z"
pgrep sshpass
```

```bash id="j8m8i4"
ss -antp | grep :22
```

```bash id="qz3hmh"
sudo tail -20 /var/log/auth.log
```

---

# Scenario Outcome

The SSH brute force simulation successfully generated realistic Linux authentication abuse telemetry aligned with MITRE ATT&CK brute force techniques.

The simulation successfully demonstrated:

* repeated SSH authentication failures
* source-correlated authentication abuse
* authentication retry automation
* username guessing behavior
* PAM authentication failures
* SSH daemon disconnect behavior
* threshold-triggering authentication anomalies

The collected telemetry successfully supported:

* investigation workflows
* threat mapping
* detection engineering
* Sigma rule validation
* behavior-based brute force analytics

The environment successfully returned to a stable operational state after simulation completion.
