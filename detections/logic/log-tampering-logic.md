# Detection Logic – Log Tampering and Forensic Visibility Reduction

## Purpose

The purpose of this document is to define a behavioral detection strategy for identifying log tampering activity on Linux systems.

This document does not contain detection rules or platform-specific implementations.

Instead, it describes the underlying behavioral pattern observed during investigation and establishes a reusable detection hypothesis that can later be implemented through Sigma, SIEM analytics, EDR detections, or custom correlation logic.

---

# Detection Objective

Identify activity where a user or process attempts to reduce forensic visibility by:

1. Removing historical evidence of activity.
2. Modifying or destroying log records.
3. Disabling mechanisms responsible for future logging.

The objective is to detect the behavior rather than the specific commands used to perform it.

---

# Observed Behavioral Pattern

Investigation identified the following sequence:

```text
Payload Execution
       ↓
Post-Execution Activity
       ↓
History Removal
       ↓
Log Modification
       ↓
Logging Service Shutdown
```

The observed actions were:

```text
rm ~/.bash_history
truncate -s 0 /var/log/auth.log
systemctl stop rsyslog
```

However, these commands are only one implementation of a broader behavior.

The detection strategy focuses on the underlying intent.

---

# Detection Hypothesis

A process that has recently executed on a host attempts to reduce investigative visibility by removing evidence of prior activity or preventing future logging.

When these activities occur within a common operational context, the probability of malicious intent increases significantly.

---

# Behavioral Components

The strategy consists of three primary behavioral categories.

---

## Component 1 – Historical Evidence Destruction

### Objective

Detect attempts to remove records of past activity.

### Examples

```bash
rm ~/.bash_history
history -c
unset HISTFILE
```

### Behavioral Meaning

The actor is attempting to eliminate artifacts that investigators frequently review during incident response.

### Detection Value

High

History destruction is uncommon during routine system operation and often appears during post-compromise activity.

---

## Component 2 – Log Tampering

### Objective

Detect modification, truncation, deletion, or corruption of log data.

### Examples

```bash
truncate -s 0 auth.log
rm auth.log
echo "" > auth.log
```

### Behavioral Meaning

The actor is attempting to remove historical evidence contained within system logs.

### Detection Value

Very High

System logs are a primary source of investigative evidence and are frequent targets during intrusion activity.

---

## Component 3 – Logging Suppression

### Objective

Detect attempts to disable future logging.

### Examples

```bash
systemctl stop rsyslog
service rsyslog stop
systemctl stop auditd
```

### Behavioral Meaning

The actor is attempting to prevent generation of future evidence.

### Detection Value

Very High

Disabling logging directly impacts host visibility and forensic capability.

---

# Correlation Logic

The strongest indicator is not an individual event.

The strongest indicator is the relationship between multiple evidence reduction activities.

Observed pattern:

```text
Evidence Destruction
        +
Log Modification
        +
Logging Suppression
```

or

```text
History Removal
       ↓
Log Tampering
       ↓
Logging Disablement
```

When multiple visibility reduction behaviors occur within a limited time window, confidence increases substantially.

---

# Why This Pattern Matters

Most administrative activities involve:

```text
Create Logs
Review Logs
Archive Logs
Rotate Logs
```

Most attacker activities involve:

```text
Remove Evidence
Reduce Visibility
Prevent Future Collection
```

The distinction is critical.

Legitimate administration generally seeks to preserve operational visibility.

Attackers frequently seek to reduce it.

---

# Relationship to Observed Simulation

The simulation demonstrated all three components.

### Historical Evidence Destruction

```bash
rm ~/.bash_history
```

---

### Log Tampering

```bash
truncate -s 0 /var/log/auth.log
```

---

### Logging Suppression

```bash
systemctl stop rsyslog
```

These actions occurred after payload execution and therefore formed part of a larger operational sequence.

The behavior strongly supports the hypothesis of intentional forensic visibility reduction.

---

# Detection Confidence Model

## Low Confidence

Single visibility-reduction event.

Examples:

```text
History file removed
```

or

```text
Single log file modified
```

Possible benign explanation exists.

---

## Medium Confidence

Multiple visibility-reduction events.

Examples:

```text
History removal
        +
Log modification
```

Benign explanations become less likely.

---

## High Confidence

Visibility reduction combined with process execution activity.

Examples:

```text
Payload Execution
       ↓
History Removal
       ↓
Log Tampering
       ↓
Logging Service Disablement
```

This combination strongly suggests malicious intent.

---

# False Positive Analysis

## Possible Legitimate Sources

### System Maintenance

Administrators may:

* Rotate logs
* Remove temporary logs
* Restart logging services

However, maintenance activities rarely include destruction of shell history.

---

### Troubleshooting

Administrators may:

* Restart rsyslog
* Clear test logs

However, troubleshooting does not typically involve coordinated removal of historical evidence.

---

### Automated Cleanup Scripts

Scripts may remove old files or rotate logs.

These activities generally occur according to predictable schedules and do not coincide with interactive execution activity.

---

# Detection Takeaways

The most reliable indicator of log tampering is not a specific command.

The most reliable indicator is a behavioral sequence where an actor:

1. Executes activity on a host.
2. Removes historical evidence.
3. Modifies or destroys logs.
4. Disables future logging.

The observed simulation demonstrated all four stages and provides a strong behavioral foundation for future detection engineering efforts.

---

# Final Detection Statement

A user or process that performs evidence destruction, log modification, and logging suppression within a shared operational context should be considered highly suspicious because the combined behavior indicates an attempt to reduce forensic visibility and conceal prior activity.
