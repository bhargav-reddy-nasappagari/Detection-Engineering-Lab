# Beaconing / Periodic Callback Simulation

## Overview

This scenario simulates a lightweight beaconing mechanism commonly observed during post-compromise command-and-control (C2) operations. The objective was to reproduce periodic callback behavior using native Linux utilities, collect host telemetry, investigate the resulting activity, map the behavior to known attacker tradecraft, and engineer a detection capable of identifying beaconing patterns.

Unlike malware-centric simulations, this exercise focuses on behavioral detection engineering. The activity was intentionally implemented using legitimate Linux binaries to demonstrate how command-and-control communications can be established without custom malware.

---

# Simulation Objectives

The simulation was designed to:

* Generate periodic HTTP callback activity.
* Produce process creation telemetry suitable for behavioral analysis.
* Reconstruct beaconing activity from collected logs.
* Compare observed behavior against known attacker tradecraft.
* Develop correlation-based detection logic.
* Engineer Sigma detections for signal generation and behavioral correlation.
* Validate detection effectiveness and false-positive considerations.

---

# Simulated Attack Scenario

A shell-based beacon controller repeatedly executed HTTP requests against a listening HTTP server at fixed intervals.

### Beacon Controller

```bash
while true
do
    curl http://127.0.0.1:8080/checkin
    sleep 60
done
```

### Callback Server

```bash
python3 -m http.server 8080
```

### Observed Behavior

```text
bash
 ├── curl http://127.0.0.1:8080/checkin
 └── sleep 60
```

The callback loop executed approximately every 60 seconds for roughly 20 minutes.

---

# Telemetry Collection

## Telemetry Sources

| Source                  | Purpose                      |
| ----------------------- | ---------------------------- |
| Auditd                  | Process execution visibility |
| Sysmon for Linux        | Process creation and lineage |
| Python HTTP Server Logs | Callback validation          |
| Process Snapshots       | Supplemental observation     |
| ss / netstat            | Attempted network visibility |

---

## Successfully Collected Telemetry

### Auditd

Captured:

* Process execution events
* Command-line arguments
* Execution timestamps
* Parent process identifiers

Example:

```text
curl http://127.0.0.1:8080/checkin
sleep 60
```

---

### Sysmon for Linux

Captured:

* Process creation events
* Parent-child process relationships
* Process metadata
* Execution lineage

Example:

```text
bash
 ├── curl
 └── sleep
```

---

### HTTP Server Logs

Captured:

```text
GET /checkin HTTP/1.1
```

at approximately one-minute intervals.

These logs independently verified callback execution.

---

## Telemetry Limitations

### Network Snapshot Collection

Attempts to collect:

```bash
ss
netstat
```

did not successfully capture callback connections.

The HTTP sessions established by `curl` completed too quickly for snapshot-based collection methods.

This demonstrated an important detection engineering lesson:

> Process telemetry remained available long after network-state visibility disappeared.

---

# Telemetry Used For Detection

The final detection relied primarily on:

### Auditd

Provided:

* Repeated process execution visibility
* Command-line evidence
* Timestamp correlation

### Sysmon

Provided:

* Parent-child process relationships
* Long-lived process lineage
* Behavioral reconstruction context

The combination of Auditd and Sysmon provided sufficient visibility to detect beaconing behavior without packet capture.

---

# Investigation Findings

The investigation focused on determining whether the observed activity resembled known attacker behavior.

### Key Findings

* Repeated HTTP communications observed.
* Fixed execution intervals identified.
* Same destination targeted repeatedly.
* Same parent process generated communications.
* Long-running automated activity observed.

### Behavioral Pattern

```text
curl
sleep
curl
sleep
curl
sleep
```

The activity strongly resembled a polling-based communication mechanism commonly used by command-and-control frameworks.

### Investigation Conclusion

Although the activity alone could not prove malicious intent, the behavior exhibited multiple characteristics associated with beaconing and command-and-control communications.

---

# Threat Mapping

The observed activity was compared against known adversary tradecraft.

## ATT&CK Mapping

### TA0011 – Command and Control

The simulation demonstrated recurring communications between a client and a remote service.

### T1071 – Application Layer Protocol

The callback mechanism utilized HTTP as its communication channel.

---

## Adversary Behavior Comparison

The observed activity shared several characteristics commonly found in:

* Remote Access Trojans
* Command-and-Control Agents
* Lightweight Backdoors
* Shell-Based Implants
* Living-Off-The-Land Post-Exploitation Tooling

Observed characteristics:

* Automated polling
* Fixed callback interval
* Repeated destination targeting
* Long-lived controller process
* Application-layer communications

---

## Threat Assessment

| Category                 | Assessment |
| ------------------------ | ---------- |
| Technical Sophistication | Low        |
| Detection Difficulty     | Medium     |
| Operational Risk         | Medium     |
| Detection Priority       | High       |

While technically simple, the behavior closely resembles a fundamental command-and-control communication pattern.

---

# Detection Engineering

## Detection Strategy

The objective was not to detect:

```text
curl
```

The objective was to detect:

```text
Repeated Communication
+
Common Parent Process
+
Consistent Destination
+
Regular Interval
+
Extended Duration
```

This behavioral approach improves resilience against attacker tooling changes.

---

## Detection Logic

The analytic identifies:

* Repeated network-capable process execution.
* Common process lineage.
* Consistent destination targeting.
* Fixed or near-fixed execution intervals.
* Sustained activity within a defined observation window.

### Correlation Model

```text
Process Creation
        +
Same Parent Process
        +
Same Destination
        +
10+ Executions
        +
20 Minute Window
        +
Consistent Timing
```

### Alert Outcome

```text
Potential Beaconing Activity Detected
```

---

# Sigma Rule Engineering

Two Sigma components were developed.

## Signal Generation Rule

Purpose:

* Detect HTTP-capable communication utilities.
* Generate detection signals for correlation.

Examples:

```text
curl
wget
python requests
urllib
```

---

## Correlation Rule

Purpose:

* Aggregate repeated communication events.
* Identify beaconing behavior.

Correlation conditions:

```text
Same Host
Same Parent Process
Same Destination
10+ Executions
20 Minute Window
```

### ATT&CK Coverage

```text
TA0011 - Command and Control
T1071 - Application Layer Protocol
```

---

# Validation

The completed detection was evaluated against:

* Simulation telemetry
* Investigation findings
* Threat mapping analysis
* Known beaconing behavior

---

## Validation Results

### Simulation Validation

Result:

```text
PASS
```

The simulation successfully generated periodic callback activity.

---

### Telemetry Validation

Result:

```text
PASS
```

Auditd and Sysmon captured sufficient evidence for behavioral reconstruction.

---

### Investigation Validation

Result:

```text
PASS
```

The investigation accurately identified beaconing characteristics without unsupported conclusions.

---

### Threat Mapping Validation

Result:

```text
PASS
```

Observed behavior aligned closely with ATT&CK command-and-control techniques.

---

### Detection Validation

Result:

```text
PASS
```

The detection successfully identified:

* Repeated callbacks
* Common lineage
* Consistent destination targeting
* Fixed execution intervals

---

### Sigma Validation

Result:

```text
PASS
```

The Sigma rules successfully generated signals and supported beaconing correlation.

---

## False Positive Analysis

Potential false positives include:

* Monitoring scripts
* API health checks
* Internal polling services
* Configuration management tooling
* Scheduled automation

Risk Assessment:

| Rule Type        | False Positive Risk |
| ---------------- | ------------------- |
| Signal Rule      | Medium              |
| Correlation Rule | Low-Medium          |

The correlation-based design significantly reduces false positives compared to detecting individual `curl` executions.

---

# Key Detection Engineering Lessons

This simulation demonstrated several important principles:

* Beaconing can be detected through host telemetry alone.
* Process telemetry often provides more value than network snapshots.
* Parent-child relationships significantly improve detection fidelity.
* Behavioral correlation is more resilient than tool-based detection.
* Repeated communications are often more important than individual events.
* Command-and-control activity can be implemented entirely with legitimate Linux utilities.

---

# Outcome

The Beaconing / Periodic Callback simulation successfully reproduced a realistic command-and-control communication pattern and produced sufficient telemetry to support a complete detection engineering workflow.

The exercise resulted in:

* Telemetry collection and validation
* Session reconstruction
* Behavioral investigation
* ATT&CK-aligned threat mapping
* Correlation-based detection logic
* Sigma rule engineering
* Detection validation

The final detection provides behavioral coverage for periodic HTTP-based callback activity and serves as a foundation for future beaconing analytics involving jitter detection, network-flow correlation, and advanced command-and-control behaviors.
