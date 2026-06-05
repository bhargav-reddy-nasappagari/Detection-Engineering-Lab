# Suspicious File Download Activity Validation

## Overview

This document validates the Suspicious File Download Activity simulation and the detection engineering artifacts developed from the collected telemetry.

The validation process evaluates:

* telemetry quality and completeness
* investigation findings
* ATT&CK threat mapping
* detection logic effectiveness
* Sigma rule performance
* correlation analytic effectiveness
* false positive impact
* overall detection confidence

The objective is to determine whether the developed detection content can reliably identify malicious download-and-execute workflows while maintaining acceptable false positive rates.

---

# Validation Scope

## Simulated Adversary Workflow

The simulation reproduced a common malware delivery and execution chain:

```text
File Download
        ↓
Local Staging
        ↓
Permission Modification
        ↓
Execution
        ↓
Outbound Callback
        ↓
Beaconing
```

The workflow was intentionally designed to emulate behaviors frequently observed during:

* malware delivery
* downloader activity
* payload staging
* command-and-control initialization

---

# Telemetry Validation

## Telemetry Sources

The simulation generated telemetry from:

* auditd process execution logging
* auditd permission modification logging
* process lineage observations
* network callback activity
* shell execution telemetry

---

## Download Activity Visibility

Observed telemetry successfully captured:

```text
ftp 127.0.0.1
```

Auditd recorded:

* process execution
* executable path
* command-line arguments
* execution context

Validation Result:

PASS

The telemetry provided sufficient visibility to identify remote file retrieval activity.

---

## Permission Modification Visibility

Observed telemetry captured:

```text
chmod +x update.sh
```

Auditd recorded:

* chmod execution
* target file
* executable permission assignment

Validation Result:

PASS

The telemetry clearly identified a file transitioning from non-executable to executable state.

---

## Execution Visibility

Observed telemetry captured:

```text
/ bin / bash ./update.sh
```

Auditd recorded:

* script execution
* interpreter used
* parent-child process relationships

Validation Result:

PASS

Execution telemetry provided sufficient context for process lineage reconstruction.

---

## Beaconing Visibility

Observed telemetry captured:

```text
curl -s http://127.0.0.1:8080/heartbeat
```

Repeated callback activity was observed at approximately thirty-second intervals.

Validation Result:

PASS

The telemetry successfully captured post-execution network communication behavior.

---

# Investigation Validation

## Reconstruction Capability

The collected telemetry enabled reconstruction of the complete activity chain.

The investigation successfully identified:

```text
Download
    ↓
Permission Change
    ↓
Execution
    ↓
Beaconing
```

Each stage was supported by direct telemetry evidence.

Validation Result:

PASS

The activity chain was fully reconstructable from available logs.

---

## Timeline Reconstruction

Investigators were able to establish:

| Event              | Observed |
| ------------------ | -------- |
| Download           | Yes      |
| Permission Change  | Yes      |
| Execution          | Yes      |
| Callback Activity  | Yes      |
| Repeated Beaconing | Yes      |

Validation Result:

PASS

The telemetry provided sufficient temporal context for event sequencing.

---

# Threat Mapping Validation

## ATT&CK Mapping Review

### T1105 – Ingress Tool Transfer

Observed:

```text
ftp download
```

Assessment:

Accurate

---

### T1059 – Command and Scripting Interpreter

Observed:

```text
bash ./update.sh
```

Assessment:

Accurate

---

### T1071 – Application Layer Protocol

Observed:

```text
curl heartbeat callbacks
```

Assessment:

Accurate

---

## ATT&CK Coverage Assessment

The simulation successfully generated observable behaviors across multiple ATT&CK techniques rather than a single isolated technique.

Validation Result:

PASS

Threat mapping accurately reflected observed behavior.

---

# Detection Strategy Validation

## Detection Objective

The strategy was designed to identify:

```text
Downloaded File
        ↓
Permission Change
        ↓
Execution
        ↓
Network Callback
```

rather than individual events.

---

## Detection Logic Evaluation

### Download Detection

Successfully identified:

* ftp
* curl
* wget

Strength:

Good

Weakness:

Legitimate software installation may generate similar activity.

---

### Permission Change Detection

Successfully identified:

```text
chmod +x
```

Strength:

Useful enrichment signal.

Weakness:

High standalone false positive rate.

---

### Execution Detection

Successfully identified execution from user-controlled locations.

Strength:

Strong behavioral indicator.

Weakness:

Developer activity may resemble attacker behavior.

---

### Beaconing Detection

Successfully identified callback activity.

Strength:

Strong post-exploitation signal.

Weakness:

Health checks and monitoring tools may appear similar.

---

## Correlation Logic Evaluation

Correlation required:

```text
Download
    ↓
Permission Change
    ↓
Execution
    ↓
Callback Activity
```

within a limited time window.

Assessment:

Excellent

The correlation model significantly improved fidelity compared to any single detection.

Validation Result:

PASS

---

# Sigma Rule Validation

## Rule A

File Download To Writable Location

Result:

Triggered successfully.

Assessment:

Provides useful initial detection coverage.

Confidence:

Low

---

## Rule B

Executable Permission Added

Result:

Triggered successfully.

Assessment:

Useful supporting signal.

Confidence:

Low

---

## Rule C

Execution From Writable Location

Result:

Triggered successfully.

Assessment:

Strongest individual Sigma rule developed during the simulation.

Confidence:

Medium

---

## Rule D

Suspicious Callback Activity

Result:

Triggered successfully.

Assessment:

Useful post-exploitation indicator.

Confidence:

Medium

---

# Correlation Analytic Validation

## Correlation Sequence

```text
Rule A
    ↓
Rule B
    ↓
Rule C
    ↓
Rule D
```

Observed:

Yes

---

## Detection Outcome

The simulation produced all required stages.

The correlation analytic successfully identified the complete attack chain.

Validation Result:

PASS

Confidence:

High

---

# False Positive Analysis

## Atomic Rule False Positives

### Download Rule

Potential Sources:

* software installation
* package retrieval
* developer downloads

Expected FP Rate:

Medium

---

### Permission Change Rule

Potential Sources:

* shell scripting
* software deployment
* administration

Expected FP Rate:

High

---

### Execution Rule

Potential Sources:

* developer testing
* automation scripts
* internal tooling

Expected FP Rate:

Medium

---

### Callback Rule

Potential Sources:

* monitoring systems
* health checks
* automation platforms

Expected FP Rate:

Medium

---

# Correlation False Positives

The probability of all four behaviors occurring together within a short time window is significantly lower.

Required sequence:

```text
Download
    ↓
chmod +x
    ↓
Execution
    ↓
Repeated Network Communication
```

Expected FP Rate:

Low

This demonstrates the primary advantage of behavioral correlation.

---

# Detection Strengths

* Behavior-based detection
* ATT&CK-aligned coverage
* Independent of file hash
* Independent of file name
* Independent of payload content
* Detects realistic attacker workflows
* Reduces dependence on signatures
* High investigative value

---

# Detection Limitations

* Requires multiple telemetry sources
* Requires process execution visibility
* Requires permission change visibility
* Requires network activity visibility
* May miss fileless execution techniques
* May miss payloads executed without permission modification
* Does not detect memory-only malware

---

# Overall Assessment

## Telemetry Quality

PASS

## Investigation Capability

PASS

## ATT&CK Mapping

PASS

## Detection Logic

PASS

## Sigma Rules

PASS

## Correlation Analytic

PASS

## False Positive Management

PASS

---

# Final Conclusion

The Suspicious File Download Activity simulation successfully generated a realistic malware delivery workflow and produced sufficient telemetry to support investigation, ATT&CK mapping, detection engineering, Sigma rule development, and validation.

While the individual Sigma rules provide useful detection coverage, their standalone false positive rates vary considerably.

The highest-fidelity detection was achieved through behavioral correlation of download activity, executable permission modification, execution from a user-controlled location, and subsequent callback behavior.

The correlation analytic demonstrated strong detection capability against the simulated attack chain while maintaining a substantially lower false positive rate than any individual detection component.

Overall Detection Confidence: HIGH
Overall Detection Fidelity: HIGH
Recommended Deployment Model: Correlation-Based Detection
