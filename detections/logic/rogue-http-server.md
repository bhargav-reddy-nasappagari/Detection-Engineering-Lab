# Detection Logic Development: Rogue HTTP Server (T1105 – Ingress Tool Transfer)

## Overview

This document translates the behavioral findings identified during the Telemetry Analysis, Investigation, and Threat Mapping phases into detection logic suitable for engineering robust detections.

The objective of this phase is not to create a Sigma rule immediately, but rather to identify the behavioral conditions that distinguish potentially malicious activity from normal system activity and derive detection opportunities from those behaviors.

The simulation emulated a post-compromise ingress tool transfer workflow in which an attacker staged a payload through a temporary HTTP server, transferred the payload to a local system, modified its permissions, executed the payload, and performed host discovery.

The detection logic developed in this document serves as the foundation for subsequent Sigma rule development and validation.

---

# Detection Engineering Objective

Detect adversary behavior associated with:

```text
Ingress Tool Transfer (T1105)
        ↓
Payload Staging
        ↓
Permission Modification
        ↓
Payload Execution
        ↓
Discovery Activity
```

while minimizing reliance on individual commands and maximizing focus on behavioral patterns.

---

# Behavioral Findings Summary

The investigation phase identified the following behavioral findings:

| ID    | Behavioral Finding                          |
| ----- | ------------------------------------------- |
| BF-01 | Temporary HTTP server creation              |
| BF-02 | Payload retrieval through HTTP              |
| BF-03 | Payload staged in temporary storage         |
| BF-04 | Permission modification before execution    |
| BF-05 | Execution of newly transferred tooling      |
| BF-06 | Immediate post-execution discovery activity |

Not all findings provide equal detection value.

The objective of detection engineering is to identify which findings are stable attacker behaviors and which are merely supporting context.

---

# Detection Candidate Analysis

---

## Detection Candidate 1

### Temporary HTTP Server Creation

### Observed Behavior

```bash
python3 -m http.server 8000
```

### Detection Opportunity

Detect Python spawning an embedded HTTP service.

### Why It Matters

Attackers frequently use built-in tooling to create lightweight staging infrastructure.

The behavior requires no additional software and is commonly observed during:

* Tool transfer
* Payload staging
* Ad-hoc malware hosting
* Red team operations

### Strengths

Provides early visibility.

Can identify staging activity before payload execution occurs.

### Weaknesses

High potential for false positives in:

* Development environments
* Testing systems
* Training laboratories

### Detection Value

```text
Medium
```

### Recommended Usage

Use as a contextual signal rather than a standalone alert.

---

## Detection Candidate 2

### Download Utility Retrieves Tooling

### Observed Behavior

```bash
curl http://127.0.0.1:8000/updater.sh \
-o /tmp/updater.sh
```

### Detection Opportunity

Detect download utilities writing files into temporary directories.

### Why It Matters

Ingress tool transfer commonly involves:

```text
curl
wget
fetch
aria2
```

writing executable content to staging locations.

### Strengths

Frequently observed during post-compromise activity.

### Weaknesses

Software installers and administrative workflows can generate similar behavior.

### Detection Value

```text
Medium
```

### Recommended Usage

Use as part of a correlated behavioral sequence.

---

## Detection Candidate 3

### File Written To Temporary Storage

### Observed Behavior

```text
/tmp/updater.sh
```

### Detection Opportunity

Monitor newly created executable content within:

```text
/tmp
/var/tmp
/dev/shm
```

### Why It Matters

Temporary storage is routinely abused by adversaries because it:

* Is writable
* Requires minimal privileges
* Often escapes routine scrutiny

### Strengths

Strong staging indicator.

### Weaknesses

Insufficient as a standalone detection.

### Detection Value

```text
Medium
```

---

## Detection Candidate 4

### Permission Modification Prior To Execution

### Observed Behavior

```bash
chmod +x /tmp/updater.sh
```

### Detection Opportunity

Identify executable permission changes applied to recently created files.

### Why It Matters

Permission modification frequently serves as a preparation step before execution.

The activity demonstrates intent.

The actor is preparing the file for use rather than simply storing it.

### Strengths

Common across many Linux intrusion scenarios.

### Weaknesses

Legitimate administrators perform the same action.

### Detection Value

```text
High
```

### Recommended Usage

Correlate with file creation and execution activity.

---

## Detection Candidate 5

### Execution From Temporary Directories

### Observed Behavior

```bash
/bin/bash /tmp/updater.sh
```

### Detection Opportunity

Detect processes executed from:

```text
/tmp
/var/tmp
/dev/shm
```

### Why It Matters

Execution from temporary locations is one of the strongest Linux behavioral indicators.

Most legitimate applications do not execute operational tooling directly from temporary storage.

### Strengths

Strong attacker association.

Relatively low false positive rate.

### Weaknesses

Some installers and deployment frameworks may generate noise.

### Detection Value

```text
Very High
```

### Recommended Usage

Primary detection condition.

---

## Detection Candidate 6

### Discovery Activity Following Execution

### Observed Behavior

```bash
whoami
id
hostname
```

### Detection Opportunity

Detect discovery commands launched immediately after execution of newly staged tooling.

### Why It Matters

Discovery often follows successful payload execution.

Attackers seek to understand:

```text
Current User
Privilege Level
Host Identity
```

### Strengths

Provides additional confidence.

### Weaknesses

Discovery commands alone are weak indicators.

### Detection Value

```text
Medium
```

### Recommended Usage

Use as enrichment rather than a primary trigger.

---

# Behavioral Correlation Analysis

Individual detections provide limited confidence.

The strongest signal emerges from correlation.

---

## Correlation Pattern A

### Download → Execute

```text
curl/wget
        ↓
File Created
        ↓
Execution
```

### Assessment

Strong indication of transferred tooling.

### Detection Confidence

```text
High
```

---

## Correlation Pattern B

### Download → Chmod → Execute

```text
curl/wget
        ↓
File Created
        ↓
chmod +x
        ↓
Execution
```

### Assessment

Classic Linux attacker workflow.

### Detection Confidence

```text
Very High
```

This is the strongest behavioral pattern identified during the simulation.

---

## Correlation Pattern C

### HTTP Server → Download → Execute

```text
python3 http.server
        ↓
curl/wget
        ↓
Execution
```

### Assessment

Represents complete ingress tool transfer behavior.

### Detection Confidence

```text
Very High
```

---

## Correlation Pattern D

### Execute → Discovery

```text
Script Execution
        ↓
whoami
id
hostname
```

### Assessment

Suggests post-compromise reconnaissance.

### Detection Confidence

```text
High
```

---

# Detection Logic Derivation

## Logic 1

### Suspicious Temporary HTTP Server

Trigger When:

```text
python3
```

executes with:

```text
http.server
```

in command line arguments.

### Purpose

Identify potential attacker staging infrastructure.

---

## Logic 2

### Tool Download To Temporary Storage

Trigger When:

```text
curl
wget
```

writes content into:

```text
/tmp
/var/tmp
/dev/shm
```

### Purpose

Identify ingress tool transfer activity.

---

## Logic 3

### Permission Modification Of Newly Staged File

Trigger When:

```text
chmod +x
```

targets files within:

```text
/tmp
/var/tmp
/dev/shm
```

### Purpose

Identify preparation of transferred tooling.

---

## Logic 4

### Execution From Temporary Directories

Trigger When:

```text
bash
sh
dash
```

executes content residing in:

```text
/tmp
/var/tmp
/dev/shm
```

### Purpose

Identify staged tool execution.

### Priority

```text
Highest
```

---

## Logic 5

### Download → Chmod → Execute Chain

Trigger When:

```text
Download Utility
        ↓
Temporary File Creation
        ↓
chmod +x
        ↓
Execution
```

occurs within a defined time window.

### Purpose

Detect attacker workflow rather than isolated commands.

### Priority

```text
Highest
```

---

## Logic 6

### Execution Followed By Discovery

Trigger When:

```text
Newly Executed Tool
        ↓
whoami
id
hostname
```

occur shortly afterward.

### Purpose

Increase confidence of malicious activity.

---

# Recommended Detection Strategy

The investigation and threat mapping phases demonstrate that no single event reliably identifies malicious activity.

The recommended strategy is layered detection.

### Layer 1

Detect:

```text
python3 http.server
```

---

### Layer 2

Detect:

```text
curl/wget
```

writing files to temporary locations.

---

### Layer 3

Detect:

```text
chmod +x
```

against temporary files.

---

### Layer 4

Detect:

```text
execution from temporary directories
```

---

### Layer 5

Correlate:

```text
Download
        ↓
Permission Change
        ↓
Execution
```

This layer should be treated as the primary behavioral detection.

---

# Detection Logic Conclusion

Analysis of the simulation identified several observable behaviors associated with ingress tool transfer activity. While individual commands such as `curl`, `chmod`, or `python3` may occur legitimately, the correlated sequence of tool transfer, staging, permission modification, execution, and discovery closely aligns with known attacker tradecraft.

The highest-value detection opportunity derived from the simulation is the behavioral chain:

```text
HTTP Tool Transfer
        ↓
Temporary File Creation
        ↓
Permission Modification
        ↓
Execution From Temporary Storage
```

This sequence forms the primary detection hypothesis and should serve as the foundation for Sigma rule development and validation in subsequent phases.
