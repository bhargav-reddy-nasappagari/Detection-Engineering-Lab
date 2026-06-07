# Detection Engineering Methodology

## Overview

The Detection Engineering Laboratory was built using a telemetry-driven detection engineering methodology focused on understanding attacker behavior before developing detections.

Rather than creating signatures based on assumptions, each detection was engineered from observable telemetry generated during controlled adversary simulations. Every scenario followed a repeatable workflow designed to transform raw attacker activity into validated detection content.

The objective was to replicate the activities performed by a detection engineer during real-world investigations:

* Simulate adversary behavior
* Collect telemetry
* Investigate artifacts
* Identify behavioral patterns
* Map activity to MITRE ATT&CK
* Engineer detections
* Develop Sigma rules
* Validate detection effectiveness

This methodology was applied consistently across all twelve scenarios within the laboratory.

---

# Detection Engineering Workflow

Every scenario followed the same engineering process.

```text
Scenario Planning
        ↓
Environment Preparation
        ↓
Scenario Execution
        ↓
Telemetry Collection
        ↓
Telemetry Analysis
        ↓
Investigation
        ↓
Threat Mapping
        ↓
Detection Logic Engineering
        ↓
Sigma Rule Development
        ↓
Validation
        ↓
Evidence Collection
        ↓
Documentation
```

This workflow ensured that every detection was supported by observable evidence and validation results.

---

# Phase 1: Scenario Planning

## Objective

Define the adversary behavior to be simulated and identify the expected telemetry sources.

## Activities

* Select attack technique
* Map technique to MITRE ATT&CK
* Define attack objectives
* Identify required telemetry sources
* Define expected artifacts
* Define validation criteria

## Example

For the Suspicious File Download Activity scenario:

Expected attacker behavior:

```text
Payload Download
        ↓
Permission Modification
        ↓
Execution
        ↓
Network Callback
```

Expected telemetry:

* Process execution events
* File metadata changes
* Network activity
* Web server logs

---

# Phase 2: Environment Preparation

## Objective

Ensure required telemetry sources are operational before simulation begins.

## Activities

* Configure Auditd rules
* Enable Sysmon for Linux
* Verify logging services
* Prepare packet capture tools
* Establish baseline system state

## Purpose

A simulation without telemetry is not useful for detection engineering.

Telemetry collection must be prepared before attack execution.

---

# Phase 3: Scenario Execution

## Objective

Generate realistic attacker behavior.

## Activities

* Execute attack simulation
* Preserve execution timeline
* Capture supporting artifacts
* Record attack commands

## Examples

* Reverse shell establishment
* Cron persistence creation
* SSH brute-force activity
* Data staging and compression
* Beaconing behavior
* Log tampering

The goal was not to execute malware but to reproduce the observable behavior associated with adversary techniques.

---

# Phase 4: Telemetry Collection

## Objective

Capture raw evidence generated during the simulation.

## Sources Collected

| Source              | Purpose                                   |
| ------------------- | ----------------------------------------- |
| Auditd              | Process execution telemetry               |
| Sysmon for Linux    | Process lineage and behavioral visibility |
| Journalctl          | Service and daemon activity               |
| Authentication Logs | Login and privilege escalation activity   |
| Network Captures    | Command and control visibility            |
| Web Server Logs     | Payload delivery validation               |
| FTP Logs            | Alternate transfer validation             |
| File Metadata       | Persistence and staging artifacts         |

## Output

Raw telemetry was preserved before any analysis occurred.

---

# Phase 5: Telemetry Analysis

## Objective

Understand what occurred on the host during execution.

## Activities

* Process reconstruction
* Parent-child lineage analysis
* Command-line review
* Network activity analysis
* File activity analysis

## Questions Answered

* What executed?
* What executed it?
* What happened afterward?
* What telemetry was generated?
* What artifacts were left behind?

This phase transformed raw logs into meaningful observations.

---

# Phase 6: Investigation

## Objective

Perform analyst-style investigation using collected telemetry.

## Activities

* Session reconstruction
* Timeline creation
* Process lineage analysis
* Artifact examination
* Behavioral clustering

## Outcome

A complete understanding of attacker behavior from an investigator's perspective.

This phase often revealed behavioral patterns not initially considered during planning.

---

# Phase 7: Threat Mapping

## Objective

Map observed behavior to ATT&CK techniques.

## Activities

* Identify ATT&CK tactics
* Identify ATT&CK techniques
* Document behavioral alignment
* Justify technique selection

## Example

```text
Cron Job Creation
        ↓
Recurring Execution
        ↓
T1053.003
Scheduled Task/Job: Cron
```

Threat mapping provides a common language between detection engineers and defenders.

---

# Phase 8: Detection Logic Engineering

## Objective

Transform behavioral observations into detection opportunities.

## Activities

* Identify suspicious behaviors
* Evaluate detection feasibility
* Analyze false positives
* Define detection conditions

## Example

Rather than detecting:

```text
wget
```

The laboratory focused on:

```text
Download
        ↓
Permission Change
        ↓
Execution
        ↓
Callback Activity
```

This produced more durable detections based on behavior rather than tools.

---

# Phase 9: Sigma Rule Development

## Objective

Convert detection logic into portable detection content.

## Activities

* Create Sigma rules
* Define selections
* Define filters
* Establish conditions
* Align with observed telemetry

## Rule Categories

* Atomic detections
* Behavioral detections
* Correlation detections

The Sigma rules were designed to reflect observed behavior rather than theoretical attack patterns.

---

# Phase 10: Validation

## Objective

Confirm that detections successfully identify the simulated activity.

## Activities

* Replay scenario behavior
* Execute validation tests
* Verify Sigma matches
* Review triggered events
* Assess false positives

## Success Criteria

A detection was considered complete only when:

* The attack executed successfully
* Telemetry was captured
* Detection triggered correctly
* Evidence was preserved

---

# Phase 11: Evidence Collection

## Objective

Preserve proof of simulation and detection effectiveness.

## Evidence Types

* Screenshots
* Process trees
* Telemetry extracts
* Network captures
* Detection triggers
* Validation results

Evidence serves as supporting documentation for engineering decisions.

---

# Phase 12: Documentation

## Objective

Create reusable detection engineering knowledge.

## Artifacts Produced

* Detection logic
* Investigations
* Threat mappings
* Validation reports
* Sigma rules
* Telemetry documentation
* Sample alerts
* Sample events

Documentation ensures that detections can be reproduced, reviewed, and improved over time.

---

# Challenges Encountered

Throughout the laboratory, several practical detection engineering challenges were encountered.

## Telemetry Visibility Challenges

Not all attacker actions generated equally useful telemetry.

Challenges included:

* Missing parent-child relationships
* Limited file creation visibility
* Service execution visibility gaps
* Correlating activity across multiple log sources

These challenges reinforced the importance of collecting telemetry from multiple sources.

---

## Detection Fidelity Challenges

Many techniques produced noisy indicators when considered individually.

Examples:

* curl usage
* wget downloads
* sudo execution
* archive creation

These actions frequently occur in legitimate administrative workflows.

As a result, behavioral correlation became a critical design principle.

---

## False Positive Reduction

The largest challenge was distinguishing malicious behavior from legitimate administration.

Several detections required:

* Contextual filtering
* Process lineage analysis
* Multi-event correlation
* Temporal relationships

This significantly improved detection quality.

---

## Validation Challenges

A detection is not complete until it is validated.

Validation required:

* Repeated execution
* Telemetry verification
* Detection tuning
* Evidence collection

Many detection ideas were refined after observing validation results.

---

# Key Methodology Principles

The laboratory was built around five core principles:

## 1. Telemetry Before Detection

Understand available telemetry before designing detections.

## 2. Investigation Before Rule Writing

Investigate the behavior first.

Do not begin with Sigma development.

## 3. Behavior Over Tooling

Detect attacker behavior rather than specific tools.

## 4. Validation Is Mandatory

Unvalidated detections are assumptions.

Validated detections are engineering outcomes.

## 5. Documentation Completes the Detection Lifecycle

A detection is not complete until its methodology, logic, validation, and evidence are documented.

---

# Conclusion

The Detection Engineering Laboratory demonstrates a complete detection engineering lifecycle across twelve Linux adversary simulation scenarios.

The methodology emphasizes telemetry-driven analysis, investigation-led detection development, ATT&CK alignment, validation, and documentation.

Rather than focusing on isolated signatures, the laboratory prioritizes behavioral understanding and reproducible engineering practices.

The resulting repository provides a structured framework for transforming attacker activity into validated detection content and serves as a practical reference for modern detection engineering workflows.
