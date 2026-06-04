# Beaconing / Periodic Callback Detection Validation

## Validation Overview

This document validates the Beaconing / Periodic Callback simulation, collected telemetry, investigative findings, threat mapping analysis, detection strategy, and Sigma rule implementation.

The objective of this phase is to determine whether the developed detection accurately identifies the intended behavior, aligns with real-world attacker tradecraft, and maintains acceptable false-positive characteristics.

The validation also evaluates limitations, detection gaps, and opportunities for future improvement.

---

# Simulation Validation

## Simulation Objective

The simulation was designed to emulate a lightweight beaconing mechanism using native Linux utilities.

Observed execution model:

```text
bash
 ├── curl http://127.0.0.1:8080/checkin
 └── sleep 60
```

repeating continuously.

The simulation generated:

* Repeated HTTP callbacks
* Consistent destination targeting
* Fixed execution intervals
* Long-lived process activity

These behaviors are commonly associated with command-and-control polling.

---

## Reality Alignment Assessment

### Realistic Characteristics

The simulation successfully reproduced:

* Application-layer communication
* Polling-based callback behavior
* Living-off-the-land execution
* Long-lived beacon operation
* Periodic tasking patterns

These characteristics are frequently observed in:

* Lightweight backdoors
* Shell-based implants
* Post-exploitation scripts
* Command-and-control agents

### Simplifications

The simulation did not include:

* Encrypted communications
* Jitter/randomized intervals
* Persistence mechanisms
* Payload retrieval
* Command execution
* Evasion techniques

### Assessment

```text
Reality Alignment: High
```

Although simplified, the core behavioral pattern accurately represents a fundamental beaconing mechanism used in real intrusions.

---

# Telemetry Validation

## Auditd Validation

### Expected Visibility

Auditd was expected to capture:

* Process executions
* Command-line arguments
* Parent process identifiers
* Execution timestamps

### Result

All expected artifacts were successfully collected.

Examples included:

```text
curl http://127.0.0.1:8080/checkin
sleep 60
python3 -m http.server 8080
```

### Assessment

```text
Coverage: High
Reliability: High
Detection Value: High
```

Auditd provided sufficient telemetry to reconstruct the entire beacon lifecycle.

---

## Sysmon Validation

### Expected Visibility

Sysmon was expected to provide:

* Process creation events
* Parent-child relationships
* Process lineage visibility

### Result

Expected telemetry was successfully captured.

Process ancestry was preserved throughout the simulation.

### Assessment

```text
Coverage: High
Reliability: High
Detection Value: High
```

Sysmon significantly improved behavioral reconstruction accuracy.

---

## Network Telemetry Validation

### Expected Visibility

Network inspection tools were expected to observe:

```text
ss
netstat
```

connections associated with the callback activity.

### Result

No meaningful telemetry was collected.

### Root Cause

The callback mechanism used:

```text
curl
```

which established and terminated connections too quickly for snapshot-based collection.

### Assessment

```text
Coverage: Low
Reliability: Low
Detection Value: Low
```

This outcome reinforces the importance of process telemetry over network snapshots for short-lived beaconing activity.

---

# Investigation Validation

## Investigative Objective

The investigation sought to determine whether the observed activity resembled known attacker behaviors.

---

## Findings Validation

The investigation correctly identified:

* Automated execution
* Repeated communications
* Consistent destination targeting
* Fixed timing intervals
* Long-lived orchestration process

The investigation avoided unsupported conclusions such as:

```text
Malware execution
Credential theft
Data exfiltration
Persistence
```

which were not present in the telemetry.

### Assessment

```text
Analytical Accuracy: High
Evidence Support: High
Overreach Risk: Low
```

The investigation remained evidence-driven and avoided speculative conclusions.

---

# Threat Mapping Validation

## ATT&CK Alignment Validation

### T1071 Application Layer Protocol

Observed:

```text
HTTP communications
```

Validation:

```text
Accurate Mapping
```

---

### TA0011 Command and Control

Observed:

```text
Periodic callbacks
```

Validation:

```text
Accurate Mapping
```

---

### Living-Off-The-Land Characteristics

Observed:

```text
bash
curl
sleep
```

Validation:

```text
Accurate Behavioral Assessment
```

The simulation successfully demonstrated how native utilities can implement command-and-control behavior without custom malware.

---

# Detection Logic Validation

## Detection Objective Review

The analytic was designed to detect:

```text
Repeated communications
+
Same destination
+
Common parent process
+
Fixed interval
+
Extended duration
```

rather than:

```text
curl execution
```

alone.

---

## Validation Against Simulation

Observed simulation:

```text
20+ callback executions
20 minute duration
Same destination
Same parent process
```

Detection logic requirements:

```text
10+ executions
20 minute observation window
Common parent process
Common destination
```

### Result

```text
Detection Triggered: Yes
```

The analytic successfully identifies the intended behavior.

---

## Behavioral Robustness Assessment

The logic remains effective if the attacker replaces:

```text
curl
```

with:

```text
wget
python requests
urllib
busybox wget
```

provided recurring communication behavior remains observable.

### Assessment

```text
Behavioral Resilience: Moderate to High
```

---

# Sigma Rule Validation

## Signal Rule Evaluation

### Purpose

The signal rule identifies communication-oriented process executions.

### Result

The rule successfully detects:

```text
curl http://
curl https://
wget http://
wget https://
```

activity.

### Assessment

```text
Signal Quality: High
Coverage: Moderate
```

---

## Correlation Rule Evaluation

### Purpose

The correlation rule identifies beacon-like execution patterns.

### Required Conditions

```text
10+ executions
20 minute window
Same parent process
Same destination
```

### Result

The simulated beacon exceeded all thresholds.

### Assessment

```text
Detection Accuracy: High
```

---

# False Positive Analysis

## Potential False Positives

### Monitoring Scripts

Example:

```bash
while true
do
  curl http://monitoring-server/health
  sleep 60
done
```

Assessment:

```text
Possible
```

---

### Internal Health Checks

Example:

```text
Service polling
API monitoring
Load balancer checks
```

Assessment:

```text
Possible
```

---

### Configuration Management Systems

Examples:

```text
Ansible
Puppet
Salt
Custom automation
```

Assessment:

```text
Possible
```

---

## False Positive Risk

### Signal Rule

```text
Risk: Medium
```

Reason:

Many legitimate tools execute HTTP requests.

---

### Correlation Rule

```text
Risk: Low to Medium
```

Reason:

Few legitimate processes repeatedly communicate with identical timing and identical destinations for extended periods without being known infrastructure components.

---

# Detection Gaps

## Low-Frequency Beacons

The current logic may miss:

```text
15 minute intervals
30 minute intervals
1 hour intervals
```

because event frequency thresholds may not be reached.

---

## Jittered Beaconing

The current logic assumes relatively consistent timing.

Advanced malware often introduces:

```text
Random delay
Interval variation
Adaptive scheduling
```

which may evade interval-based detection.

---

## Alternate Communication Mechanisms

Current coverage primarily targets:

```text
curl
wget
HTTP communications
```

Future coverage should include:

```text
python requests
urllib
nc
openssl
custom binaries
```

---

# Overall Detection Assessment

| Component                 | Result     |
| ------------------------- | ---------- |
| Simulation Design         | Successful |
| Telemetry Collection      | Successful |
| Investigation Methodology | Successful |
| Threat Mapping            | Accurate   |
| Detection Logic           | Effective  |
| Sigma Signal Rule         | Effective  |
| Sigma Correlation Rule    | Effective  |
| False Positive Resistance | Moderate   |
| Real-World Relevance      | High       |

---

# Final Validation Verdict

The Beaconing / Periodic Callback scenario successfully reproduced a realistic command-and-control communication pattern and generated sufficient telemetry to support behavioral detection engineering.

The collected evidence demonstrated:

```text
Repeated callbacks
Consistent destination targeting
Fixed execution intervals
Long-lived parent process activity
```

The investigation and threat mapping accurately associated the activity with beaconing-style command-and-control behavior while avoiding unsupported conclusions.

The developed detection strategy correctly focuses on behavioral correlation rather than individual utility execution, improving resilience against tooling changes.

The Sigma implementation successfully generates signal-level detections and, when combined with correlation logic, reliably identifies the simulated beaconing activity with a manageable false-positive profile.

Overall Assessment:

Detection Engineering Objective Achieved

The analytic provides meaningful coverage for lightweight HTTP-based beaconing activity and establishes a strong foundation for future enhancements involving jitter detection, network telemetry correlation, and broader communication utility coverage.
