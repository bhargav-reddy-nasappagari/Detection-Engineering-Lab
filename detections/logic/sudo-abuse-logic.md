# Detection Logic Analysis – Sudo Abuse via GTFOBins Find

## Overview

This phase transforms investigative findings into actionable detection logic.

Previous phases established that:

* The user enumerated available sudo permissions.
* A sudo-authorized binary was abused.
* A root shell was successfully spawned.
* Post-escalation validation activity occurred.
* The behavior aligns with ATT&CK privilege escalation techniques.

The objective of this phase is to identify which observable telemetry conditions provide reliable evidence of sudo abuse and determine how those conditions should be represented within detection logic.

---

# Detection Objective

Detect situations where a user abuses sudo permissions to obtain elevated shell access through a GTFOBins-capable binary.

The detection should focus on identifying actual privilege escalation behavior rather than routine sudo usage.

---

# Telemetry Available for Detection

## Process Creation Events

Observed telemetry includes:

```text id="tl001"
sudo -l
sudo find . -exec /bin/bash \; -quit
find . -exec /bin/bash \; -quit
bash
whoami
id
hostname
```

Visibility:

```text id="tl002"
Process Name
Command Line
PID
PPID
User Context
```

Detection Value:

High

---

## Process Lineage

Observed lineage:

```text id="tl003"
bash
 └── sudo
      └── find
           └── bash
```

Visibility:

```text id="tl004"
Parent Process
Child Process
Process Tree
```

Detection Value:

Very High

---

## Privilege Transition Events

Observed transition:

```text id="tl005"
uid=1000
euid=0
```

Visibility:

```text id="tl006"
Original User
Effective User
Privilege Change
```

Detection Value:

Very High

---

## Discovery Commands

Observed:

```text id="tl007"
whoami
id
hostname
```

Detection Value:

Moderate

These commands strengthen confidence but do not independently indicate privilege escalation.

---

# Candidate Detection Signals

## Signal 1 – Sudo Enumeration

Observed:

```bash id="sig001"
sudo -l
```

### Analysis

This behavior appears during the attack sequence.

However:

* Commonly executed by administrators.
* Does not indicate successful escalation.
* Generates substantial false positives.

### Detection Assessment

```text id="sig002"
Contextual Indicator
Not Primary Detection Logic
```

### Outcome

Useful for investigations and correlation.

Not suitable as a standalone alert.

---

## Signal 2 – Sudo Executing Find

Observed:

```bash id="sig003"
sudo find
```

### Analysis

The command is unusual but not inherently malicious.

Legitimate administrators may execute:

```bash id="sig004"
sudo find /var/log
```

### Detection Assessment

```text id="sig005"
Too Broad
```

### Outcome

Not recommended as a primary detection condition.

Additional behavioral context is required.

---

## Signal 3 – Find Executing Bash

Observed:

```text id="sig006"
find
 └── bash
```

### Analysis

This process relationship is uncommon in normal administration.

The primary purpose of `find` is filesystem traversal.

Spawning a shell is generally unnecessary for legitimate use.

### Detection Assessment

```text id="sig007"
High Fidelity
```

### Outcome

Strong detection candidate.

---

## Signal 4 – GTFOBins Command Pattern

Observed:

```bash id="sig008"
sudo find . -exec /bin/bash \; -quit
```

### Analysis

The command directly matches a known privilege escalation technique.

Key indicators:

```text id="sig009"
sudo
find
-exec
/bin/bash
```

The combination of these elements is highly indicative of abuse.

### Detection Assessment

```text id="sig010"
Very High Fidelity
```

### Outcome

Primary detection candidate.

---

## Signal 5 – User-to-Root Privilege Transition

Observed:

```text id="sig011"
uid=1000
euid=0
```

### Analysis

The privilege change confirms escalation success.

However:

```text id="sig012"
Privilege change alone
≠
Malicious activity
```

Legitimate administrative actions also produce this signal.

### Detection Assessment

```text id="sig013"
Strong Supporting Evidence
```

### Outcome

Best used alongside process telemetry.

---

## Signal 6 – Root Discovery Activity

Observed:

```bash id="sig014"
whoami
id
hostname
```

### Analysis

These commands commonly appear after successful escalation.

However:

* Individually benign.
* Extremely common.

### Detection Assessment

```text id="sig015"
Low Fidelity
```

### Outcome

Useful for correlation and enrichment.

Not suitable for primary detection.

---

# Behavioral Correlation Analysis

The investigation revealed that no single event provides the strongest detection outcome.

The highest-confidence signal emerges from event correlation.

Observed sequence:

```text id="corr001"
sudo
        ↓
find
        ↓
bash
        ↓
root context
```

Behavioral interpretation:

```text id="corr002"
Privileged Binary Abuse
        +
Shell Spawn
        +
Privilege Escalation
```

This sequence significantly reduces false positives.

---

# Detection Logic Derivation

## Logic Option 1 – Command Line Detection

Trigger when:

```text id="logic001"
Process = sudo

AND

CommandLine contains:
    find

AND

CommandLine contains:
    -exec

AND

CommandLine contains:
    /bin/bash
```

Advantages:

* Simple implementation.
* High confidence.
* Direct GTFOBins coverage.

Limitations:

* Specific to the observed technique.

Assessment:

```text id="logic002"
Recommended
```

---

## Logic Option 2 – Parent Child Detection

Trigger when:

```text id="logic003"
Parent Process = find

AND

Child Process = bash
```

Advantages:

* Covers command variations.
* Resistant to argument changes.

Limitations:

* May require lineage visibility.

Assessment:

```text id="logic004"
Recommended
```

---

## Logic Option 3 – Privilege Escalation Chain

Trigger when:

```text id="logic005"
sudo
        →
find
        →
bash
```

within a short time window.

Advantages:

* Strong behavioral fidelity.
* Represents complete escalation workflow.

Limitations:

* Requires correlation engine support.

Assessment:

```text id="logic006"
Preferred Behavioral Logic
```

---

# Recommended Detection Strategy

## Primary Detection

Detect GTFOBins execution patterns.

Behavior:

```text id="rec001"
sudo
        +
find
        +
-exec
        +
/bin/bash
```

Expected Fidelity:

```text id="rec002"
Very High
```

---

## Secondary Detection

Detect:

```text id="rec003"
find
        →
bash
```

Expected Fidelity:

```text id="rec004"
High
```

---

## Behavioral Detection

Detect:

```text id="rec005"
sudo
        ↓
find
        ↓
bash
        ↓
uid=0
```

Expected Fidelity:

```text id="rec006"
Very High
```

---

# Detection Engineering Findings

## Reliable Detection Indicators

* GTFOBins command pattern.
* Find spawning bash.
* Root shell creation.
* User-to-root privilege transition.

## Contextual Indicators

* sudo -l
* whoami
* id
* hostname

## Indicators Excluded from Standalone Detection

The following are not sufficiently suspicious on their own:

```text id="find001"
sudo -l
whoami
id
hostname
uid=0
```

These indicators should enrich detections rather than trigger alerts.

---

# Final Detection Thesis

The strongest evidence of sudo abuse is not the use of sudo itself but the behavioral chain that follows.

The most reliable detection logic is derived from:

```text id="final001"
sudo
        ↓
find
        ↓
bash
        ↓
root execution
```

or from the direct observation of the GTFOBins execution pattern:

```bash id="final002"
sudo find . -exec /bin/bash \; -quit
```

These behaviors provide high-confidence evidence of privilege escalation through sudo abuse and form the foundation for rule engineering in the next phase.
