# Detection Quality Review

## Overview

The Detection Engineering Laboratory was created to evaluate the complete lifecycle of detection development through adversary simulation, telemetry collection, investigation, detection engineering, Sigma rule development, and validation.

A critical objective of the laboratory was not simply to create detections, but to assess the quality, reliability, and operational usefulness of those detections.

This document provides a consolidated review of all detection scenarios developed within the repository and evaluates:

* Detection strength
* Detection methodology
* Behavioral coverage
* False positive considerations
* Detection maturity
* Operational usefulness

The review focuses on the quality of the detection logic rather than the success of the simulation itself.

---

# Detection Quality Evaluation Criteria

Each detection was evaluated using the following dimensions.

| Category              | Description                                                       |
| --------------------- | ----------------------------------------------------------------- |
| Behavioral Coverage   | Ability to identify attacker behavior rather than a specific tool |
| Telemetry Reliability | Quality and consistency of supporting telemetry                   |
| False Positive Risk   | Likelihood of legitimate activity triggering detection            |
| Detection Resilience  | Resistance to simple attacker modifications                       |
| Validation Status     | Whether detection was validated against generated telemetry       |
| Operational Value     | Usefulness to a defender during investigation                     |

---

# Detection Quality Summary

| Detection Scenario                | Detection Type          | Behavioral Coverage | FP Risk | Detection Resilience | Operational Value | Validation Status |
| --------------------------------- | ----------------------- | ------------------- | ------- | -------------------- | ----------------- | ----------------- |
| Cron Persistence                  | Behavioral              | High                | Low     | High                 | High              | Validated         |
| Systemd Service Persistence       | Behavioral              | Low-Medium          | Medium  | Medium               | High              | Validated         |
| Reverse Shell Execution           | Behavioral              | Medium              | Low     | Medium               | High              | Validated         |
| SSH Brute Force                   | Threshold / Correlation | High                | Low     | High                 | High              | Validated         |
| Suspicious Enumeration Activity   | Correlation             | High                | Medium  | High                 | High              | Validated         |
| Encoded Command Execution         | Behavioral              | Medium              | Medium  | Medium               | Medium            | Validated         |
| Rogue HTTP Server                 | Behavioral              | Medium              | Medium  | Medium               | High              | Validated         |
| Sudo Abuse / Privilege Escalation | Behavioral              | Medium              | Medium  | Medium               | High              | Validated         |
| Data Staging and Compression      | Correlation             | High                | Medium  | High                 | High              | Validated         |
| Beaconing / Periodic Callbacks    | Correlation Analytics   | High                | Low     | High                 | High              | Validated         |
| Suspicious File Download Activity | Multi-Stage Correlation | Very High           | Low     | High                 | Very High         | Validated         |
| Log Tampering / Defense Evasion   | Behavioral              | High                | Low     | High                 | Very High         | Validated         |

---

# Individual Detection Analysis

## Cron Persistence

### Strengths

* Detects persistence behavior rather than a specific payload.
* Relies on observable cron configuration activity.
* Low dependency on attacker tooling.

### Weaknesses

* Legitimate administrative tasks can resemble persistence.
* Context is required for accurate triage.

### Assessment

A strong persistence detection due to the stability of the underlying behavior.

---

## Systemd Service Persistence

### Strengths

* Targets a common Linux persistence mechanism.
* Service creation and enablement are highly visible activities.

### Weaknesses

* Legitimate software installation frequently creates services.
* Service creation alone may be insufficient for alerting.

### Assessment

Useful for investigation but benefits significantly from contextual enrichment.

---

## Reverse Shell Execution

### Strengths

* Detects a highly impactful attacker action.
* Process lineage and network activity provide strong evidence.

### Weaknesses

* Many reverse shell implementations exist.
* Network visibility may vary across environments.

### Assessment

High operational value due to the severity of the behavior.

---

## SSH Brute Force

### Strengths

* Well-defined attacker behavior.
* Strong threshold-based detection opportunities.
* Easily validated.

### Weaknesses

* Internet-facing systems naturally generate authentication noise.

### Assessment

Mature and reliable detection category.

---

## Suspicious Enumeration Activity

### Strengths

* Focuses on attacker workflow rather than individual commands.
* Correlates multiple discovery activities.
* Captures reconnaissance behavior effectively.

### Weaknesses

* System administrators may perform similar activities.

### Assessment

Strong behavioral detection with moderate false positive considerations.

---

## Encoded Command Execution

### Strengths

* Identifies obfuscation techniques frequently used by attackers.
* Multiple execution variants validated.

### Weaknesses

* Developers and administrators may legitimately use encoding.
* Single indicators often produce noise.

### Assessment

Most effective when correlated with execution activity.

---

## Rogue HTTP Server

### Strengths

* Detects unauthorized service exposure.
* Useful for identifying staging and payload delivery infrastructure.

### Weaknesses

* Developers frequently use temporary HTTP servers.
* Context is required before escalation.

### Assessment

Moderately reliable detection with good investigative value.

---

## Sudo Abuse / Privilege Escalation

### Strengths

* Targets privilege escalation activity.
* Elevated execution provides strong context.

### Weaknesses

* Legitimate administrative activity frequently uses sudo.

### Assessment

Useful as an investigative signal rather than a standalone alert.

---

## Data Staging and Compression

### Strengths

* Captures collection activity before exfiltration.
* Based on attacker workflow rather than specific tools.

### Weaknesses

* Legitimate backup operations may appear similar.

### Assessment

Strong behavioral detection when combined with contextual analysis.

---

## Beaconing / Periodic Callbacks

### Strengths

* Focuses on recurring communication patterns.
* Independent of payload implementation.
* Difficult for attackers to completely avoid.

### Weaknesses

* Scheduled monitoring applications can generate similar behavior.

### Assessment

One of the strongest detections in the laboratory.

---

## Suspicious File Download Activity

### Strengths

* Multi-stage detection model.
* Tracks attacker workflow from acquisition to execution.
* Incorporates execution and callback validation.

### Weaknesses

* Requires telemetry from multiple sources.
* Correlation complexity increases implementation effort.

### Assessment

Highest quality detection engineered within the repository.

The detection focuses on attacker behavior rather than individual tools and remains effective across multiple delivery methods.

---

## Log Tampering / Defense Evasion

### Strengths

* Detects attacker attempts to reduce visibility.
* High-confidence activity.
* Strong forensic value.

### Weaknesses

* Limited legitimate use cases.
* Requires reliable telemetry preservation.

### Assessment

High-fidelity detection with excellent defensive value.

---

# Detection Engineering Observations

Several important observations emerged throughout the project.

---

## Behavioral Detections Outperformed Atomic Detections

Detections based on attacker workflow consistently performed better than detections focused on individual commands.

Example:

Less Effective:

```text
Detect wget
```

More Effective:

```text
Download
    ↓
Permission Change
    ↓
Execution
    ↓
Callback Activity
```

Behavioral correlation reduced false positives and improved resilience.

---

## Correlation-Based Detections Produced Higher Fidelity

The strongest detections relied on multiple related events.

Examples:

* Suspicious File Download Activity
* Beaconing
* Data Staging and Compression
* Suspicious Enumeration

These detections demonstrated greater resilience against attacker modifications.

---

## Context Was Critical

Many attacker actions were indistinguishable from legitimate administration when viewed in isolation.

Examples:

* sudo
* curl
* tar
* systemctl

Investigation context significantly improved detection quality.

---

## Telemetry Quality Directly Impacted Detection Quality

The strongest detections were supported by:

* Process telemetry
* Parent-child relationships
* Network activity
* File metadata

Poor visibility resulted in weaker detection opportunities.

---

# Highest Quality Detections

The following detections demonstrated the strongest combination of behavioral coverage, resilience, validation quality, and operational usefulness.

| Rank | Detection                         |
| ---- | --------------------------------- |
| 1    | Suspicious File Download Activity |
| 2    | Beaconing / Periodic Callbacks    |
| 3    | Log Tampering / Defense Evasion   |
| 4    | Data Staging and Compression      |
| 5    | Suspicious Enumeration Activity   |

These detections relied on attacker behavior patterns rather than specific tools and remained effective across multiple execution variants.

---

# Areas for Future Improvement

Potential enhancements include:

* Cross-host correlation
* User behavior baselining
* Temporal analytics
* Automated timeline reconstruction
* SIEM-native correlation logic
* Sigma correlation rule conversion
* Detection coverage expansion across additional ATT&CK tactics

---

# Conclusion

The Detection Engineering Laboratory successfully demonstrated the development of high-quality, telemetry-driven detections across twelve Linux adversary simulation scenarios.

The project showed that detections built from observed attacker behavior consistently outperform detections based solely on tools, commands, or static indicators.

The strongest detections emerged from multi-stage behavioral correlation, where individual events were combined into attacker workflows that reflected realistic intrusion activity.

Across all scenarios, the laboratory validated an important detection engineering principle:

Reliable detections are not created by identifying what attackers use; they are created by understanding what attackers do.

The resulting detection content provides a validated and investigation-driven collection of Linux detections that balance behavioral coverage, operational usefulness, and detection resilience.
