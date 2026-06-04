# Beaconing / Periodic Callback Telemetry Analysis

## Overview

This document analyzes the telemetry collected during the Beaconing / Periodic Callback simulation. The objective of the analysis was to evaluate telemetry visibility, identify suspicious process activity, assess data quality, and determine how the collected evidence can support behavioral detection engineering.

The simulated activity consisted of a shell-based beacon repeatedly executing HTTP requests against a local server at fixed intervals using `curl`.

---

# Telemetry Sources

The following telemetry sources were enabled during the simulation.

| Source                         | Purpose                                                  |
| ------------------------------ | -------------------------------------------------------- |
| Auditd                         | Process execution visibility and command-line collection |
| Sysmon for Linux               | Process creation telemetry and process metadata          |
| HTTP Server Logs               | Validation of callback activity                          |
| Process Snapshots (ps)         | Manual process observation                               |
| Network Utilities (ss/netstat) | Intended network visibility                              |

---

# Telemetry Collection Assessment

## Auditd

### Visibility Provided

Auditd successfully captured:

* Process execution events
* Command-line arguments
* Parent process identifiers
* User context
* Execution timestamps

Examples observed:

```text
curl http://127.0.0.1:8080/checkin
sleep 60
python3 -m http.server 8080
```

### Contribution to Investigation

Auditd became the primary telemetry source for reconstructing the callback activity.

The telemetry clearly demonstrated:

* Repeated execution of `curl`
* Consistent destination targeting
* Consistent execution interval
* Repeated execution from the same parent process

Because each callback generated a new EXECVE event, Auditd preserved evidence even though the network connections themselves were short-lived.

### Quality Assessment

| Category                  | Assessment |
| ------------------------- | ---------- |
| Coverage                  | High       |
| Reliability               | High       |
| Command Line Visibility   | High       |
| Process Timing Visibility | High       |
| Parent Attribution        | Moderate   |

### Observations

Auditd provided enough information to reconstruct the entire beacon lifecycle without requiring packet capture.

---

## Sysmon for Linux

### Visibility Provided

Sysmon successfully captured:

* Process creation
* Process termination
* Parent process metadata
* Command-line arguments
* Process identifiers

### Contribution to Investigation

Sysmon confirmed:

```text
bash
 └── python3 -m http.server 8080
```

and repeatedly observed:

```text
bash
 ├── curl
 └── sleep
```

The telemetry validated process ancestry and execution timing observed within Auditd.

### Quality Assessment

| Category                  | Assessment |
| ------------------------- | ---------- |
| Coverage                  | High       |
| Reliability               | High       |
| Parent-Child Visibility   | High       |
| Behavioral Reconstruction | High       |

### Observations

Sysmon provided valuable context for understanding process relationships and significantly improved confidence in the reconstructed attack timeline.

---

## HTTP Server Logs

### Visibility Provided

The Python HTTP server logs recorded inbound requests.

Observed entries:

```text
GET /checkin HTTP/1.1
```

at approximately one-minute intervals.

### Contribution to Investigation

The server logs independently verified:

* Callback execution
* Destination reachability
* Timing consistency
* Request frequency

This telemetry served as validation evidence for process execution telemetry.

### Quality Assessment

| Category         | Assessment |
| ---------------- | ---------- |
| Coverage         | Moderate   |
| Reliability      | High       |
| Context          | Low        |
| Validation Value | High       |

### Observations

While server logs cannot identify the originating process, they provide strong corroboration of callback activity.

---

## Process Snapshot Collection

### Visibility Provided

Manual process collection using:

```bash
ps
pstree
```

captured long-running processes.

### Contribution to Investigation

Process snapshots successfully documented:

```text
python3 HTTP server
bash beacon parent process
```

However, short-lived child processes were generally absent.

### Quality Assessment

| Category          | Assessment |
| ----------------- | ---------- |
| Coverage          | Low        |
| Reliability       | Low        |
| Temporal Accuracy | Low        |

### Observations

The callback process executed and terminated too quickly to be reliably captured through manual observation.

Process snapshots should be considered supplementary evidence rather than a primary telemetry source.

---

## Network Telemetry Collection

### Visibility Attempted

The simulation attempted to collect network evidence through:

```bash
ss
netstat
```

### Result

No useful callback evidence was collected.

### Root Cause

The beacon used:

```text
curl
```

which established and terminated connections within fractions of a second.

By the time network inspection utilities executed, the connections had already closed.

### Quality Assessment

| Category            | Assessment |
| ------------------- | ---------- |
| Coverage            | Poor       |
| Reliability         | Poor       |
| Investigative Value | Minimal    |

### Observations

Snapshot-based network collection is ineffective for fast, non-persistent callback activity.

Future simulations should rely on:

* Auditd
* Sysmon
* Network flow telemetry
* eBPF-based collection
* Packet capture

rather than manual network inspection.

---

# Suspicious Activity Identification

## Repeated Network Utility Execution

A single shell process repeatedly executed:

```text
curl http://127.0.0.1:8080/checkin
```

This behavior is uncommon for normal interactive administration.

Key indicators:

* Repeated command execution
* Consistent destination
* Consistent URI
* Consistent timing

---

## Fixed-Interval Activity

The callback interval remained approximately:

```text
60 seconds
```

throughout the observation period.

Examples:

```text
14:38:11
14:39:11
14:40:11
14:41:11
...
```

Regular timing is a strong indicator of automated activity and is frequently associated with beaconing behavior.

---

## Long-Lived Parent Process

The callback activity originated from the same parent shell process for the duration of the simulation.

Behavior pattern:

```text
bash
 ├── curl
 └── sleep
```

repeated continuously.

This pattern strongly suggests automation rather than user-driven interaction.

---

## Persistent Destination Targeting

Every callback targeted:

```text
127.0.0.1:8080/checkin
```

No destination variability was observed.

Repeated communication with the same endpoint is a common characteristic of command-and-control beaconing.

---

# Detection Engineering Takeaways

## Process Telemetry Is More Valuable Than Network Snapshots

The simulation demonstrated that process telemetry remained available even when network visibility was lost.

Auditd and Sysmon fully preserved the behavioral sequence.

Detection logic should prioritize:

* Process creation
* Command-line arguments
* Execution frequency
* Parent-child relationships

over ad hoc network snapshots.

---

## Parent Process Correlation Is Critical

Individual `curl` executions appear benign when viewed independently.

Correlation becomes possible when telemetry reveals:

```text
Same parent
Same command
Same destination
Repeated interval
```

Behavioral context transforms otherwise benign events into a meaningful detection opportunity.

---

## Time-Based Correlation Is Essential

The strongest indicator was not the execution itself but the repetition pattern.

A useful detection strategy should identify:

* Multiple executions
* Same executable
* Same destination
* Consistent interval
* Common parent process

within a defined observation window.

---

## Beaconing Can Be Identified Without Packet Capture

The simulation demonstrated that periodic callback activity can be detected using host telemetry alone.

Required evidence:

* Process execution events
* Command-line visibility
* Timestamp correlation

Packet capture is useful but not mandatory.

---

# Final Assessment

The telemetry collection objectives were successfully achieved.

Although network snapshots failed to capture the short-lived HTTP connections, Auditd and Sysmon provided sufficient visibility to reconstruct the callback behavior, identify suspicious process activity, establish timing regularity, and validate a beaconing-oriented detection strategy.

The collected telemetry supports the development of behavior-based analytics focused on recurring command execution, process lineage correlation, and fixed-interval callback patterns rather than reliance on network-state snapshots.
