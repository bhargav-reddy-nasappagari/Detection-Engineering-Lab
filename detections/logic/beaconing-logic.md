# Beaconing / Periodic Callback Detection Logic

## Detection Objective

The objective of this analytic is to identify processes that repeatedly establish application-layer communications with the same destination at predictable intervals over an extended period of time.

The detection is intended to identify beaconing activity commonly associated with:

* Command and Control (C2)
* Remote Access Trojans
* Backdoors
* Lightweight Implants
* Malicious Automation Scripts
* Living-Off-The-Land Communication Loops

The analytic is designed around behavioral patterns rather than specific malware families or tooling.

---

# Detection Development Background

## Telemetry Findings

Telemetry analysis identified:

```text
bash
 ├── curl
 └── sleep
```

executing repeatedly.

Observed characteristics:

* Same parent process
* Same destination
* Same URI
* Fixed interval
* Long-running execution pattern
* Repeated process creation

The activity persisted for approximately twenty minutes.

---

## Investigation Findings

Investigation determined:

* The activity was automated.
* The communication pattern resembled command-and-control polling.
* The parent shell continuously generated outbound communication events.
* Communication occurred through HTTP requests.

No evidence of:

* Data exfiltration
* Credential theft
* Privilege escalation

was observed.

However, the communication behavior strongly resembled beaconing activity.

---

## Threat Mapping Findings

Threat mapping identified strong similarities with:

```text
ATT&CK T1071
Application Layer Protocol
```

and

```text
TA0011
Command and Control
```

The most significant indicator was not the communication tool itself but the recurring communication pattern.

---

# Detection Strategy

## What We Want To Detect

The analytic seeks to identify:

```text
Repeated outbound communication
from the same process lineage
to the same destination
at relatively consistent intervals
over an extended period
```

The objective is to detect behavior rather than individual process executions.

---

## What We Do Not Want To Detect

The analytic should avoid alerting on:

* Single curl executions
* Interactive troubleshooting activity
* One-time software downloads
* Package manager activity
* Administrative network testing

These activities are common and generally low risk.

---

# Behavioral Indicators

## Indicator 1

Repeated network-capable process execution.

Examples:

```text
curl
wget
python
perl
ruby
bash
sh
```

executing communication functions.

---

## Indicator 2

Consistent destination targeting.

Examples:

```text
same IP
same hostname
same URI
```

across multiple executions.

---

## Indicator 3

Common parent process.

Examples:

```text
bash
python
systemd service
shell script
```

continuously spawning communication activity.

---

## Indicator 4

Fixed or near-fixed execution interval.

Examples:

```text
30 seconds
60 seconds
120 seconds
300 seconds
```

between executions.

---

## Indicator 5

Long-duration activity.

Examples:

```text
10+ minutes
20+ minutes
30+ minutes
```

of recurring communications.

---

# Correlation Model

## Stage 1

Identify process creation events involving communication utilities.

Examples:

```text
curl
wget
python requests
python urllib
```

---

## Stage 2

Group events by:

```text
Host
Parent Process
Destination
```

---

## Stage 3

Count executions within a rolling observation window.

Example:

```text
20 minute window
```

---

## Stage 4

Calculate interval consistency.

Example:

```text
Execution 1 → 14:38:11
Execution 2 → 14:39:11
Execution 3 → 14:40:11
Execution 4 → 14:41:11
```

---

## Stage 5

Alert when all conditions are met.

---

# Detection Logic

## Required Conditions

Condition A:

```text
Repeated communication process execution
```

AND

Condition B:

```text
Same destination observed
```

AND

Condition C:

```text
Same parent process observed
```

AND

Condition D:

```text
Minimum execution threshold exceeded
```

Example:

```text
10 executions
within 20 minutes
```

AND

Condition E:

```text
Consistent timing pattern observed
```

Example:

```text
interval variance below acceptable threshold
```

---

# Analytic Pseudocode

```text
GROUP BY:

host,
parent_process,
destination

OBSERVE:

20 minute window

IF:

communication_process_count >= 10

AND

unique_destination_count = 1

AND

same_parent_process = true

AND

average_interval <= 120 seconds

THEN

Alert:
Potential Beaconing Activity
```

---

# Sigma Translation Strategy

## Sigma Purpose

Sigma cannot reliably perform beacon interval calculations by itself.

Therefore Sigma should be used as:

```text
Signal Generation Layer
```

rather than the complete analytic.

The Sigma rule should identify repeated executions of communication utilities.

The SIEM correlation engine should perform:

* aggregation
* counting
* interval analysis
* destination correlation

---

# Sigma Detection Candidate

## Process Creation Signal

Selection:

```text
Process Create
```

Process:

```text
curl
wget
```

Command line contains:

```text
http://
https://
```

---

## Correlation Requirements

The SIEM should correlate:

```text
Same Host
Same Parent Process
Same Destination
```

with:

```text
10+ executions
within 20 minutes
```

---

# Expected Alert Context

An alert should include:

```text
Hostname
User
Parent Process
Communication Utility
Destination
Execution Count
Observation Window
Average Interval
```

Example:

```text
Host: lab-linux
Parent: bash
Process: curl
Destination: 127.0.0.1:8080
Executions: 20
Window: 20 Minutes
Average Interval: 60 Seconds
```

---

# Detection Strengths

This analytic detects:

* Simple shell beacons
* Scripted polling loops
* Living-off-the-land callbacks
* Lightweight implants
* HTTP-based beaconing

The logic remains effective even when attackers:

```text
change IPs
change domains
change callback URIs
```

because the focus remains on behavioral repetition.

---

# Detection Limitations

The analytic may not detect:

* Very low-frequency beacons
* Randomized jitter
* Single callback events
* Long sleep intervals
* Encrypted network telemetry without process visibility

The analytic also depends on reliable process creation telemetry.

Loss of process visibility significantly reduces effectiveness.

---

# Detection Conclusion

The recommended detection strategy is a correlation-based analytic focused on recurring outbound communications generated by the same process lineage over a sustained period of time.

The alert should not be triggered because a process executed `curl`.

The alert should be triggered because telemetry demonstrates:

```text
Repeated communication
+
Common parent process
+
Consistent destination
+
Regular interval
+
Extended duration
```

These combined characteristics form a high-confidence beaconing profile consistent with command-and-control style callback behavior.
