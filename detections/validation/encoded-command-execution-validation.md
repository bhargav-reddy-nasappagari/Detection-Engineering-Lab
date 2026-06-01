# Validation Report: Encoded Command Execution

## Overview

This phase validates the results of the Encoded Command Execution detection engineering exercise.

The objective of validation is to determine whether:

1. The simulations successfully generated the intended telemetry.
2. The collected telemetry accurately reflects the simulated activity.
3. The investigation findings are supported by evidence.
4. Threat mappings are consistent with known adversary behavior.
5. Detection logic is derived from observable telemetry.
6. The Sigma rule accurately represents the detection hypothesis.

This phase serves as the final quality assurance review before the detection is considered complete.

---

# Validation Scope

The following simulation variants were validated:

| Variant   | Description                          |
| --------- | ------------------------------------ |
| Variant 1 | Base64 Decode and Execute            |
| Variant 2 | Payload Reconstruction and Execution |
| Variant 3 | Python Decoder Execution             |
| Variant 4 | Multi-Stage Base64 Decode Execution  |

---

# Telemetry Validation

## Objective

Validate that telemetry generated during simulation accurately captured the executed activity.

---

## Variant 1 Validation

### Expected Behavior

```text
bash
  ↓
base64 -d
  ↓
bash
  ↓
payload execution
```

### Observed Telemetry

Validated observations:

* Parent shell execution observed.
* Base64 decoding activity recorded.
* Secondary shell execution observed.
* Payload commands recorded.

### Result

PASS

The telemetry accurately captured the complete execution chain.

---

## Variant 2 Validation

### Expected Behavior

```text
base64 decode
      ↓
payload reconstruction
      ↓
chmod +x
      ↓
script execution
```

### Observed Telemetry

Validated observations:

* Decoding activity observed.
* Payload reconstruction observed.
* Permission modification recorded.
* Script execution recorded.
* Payload commands recorded.

### Result

PASS

Telemetry successfully captured reconstruction and execution stages.

---

## Variant 3 Validation

### Expected Behavior

```text
bash
   ↓
python3
   ↓
bash
   ↓
payload execution
```

### Observed Telemetry

Validated observations:

* Python interpreter execution observed.
* Child shell execution observed.
* Payload commands observed.

### Result

PASS

Telemetry captured decoder execution and interpreter handoff.

---

## Variant 4 Validation

### Expected Behavior

```text
bash
   ↓
base64
   ↓
base64
   ↓
bash
   ↓
payload execution
```

### Observed Telemetry

Validated observations:

* First decoding stage recorded.
* Second decoding stage recorded.
* Shell execution observed.
* Payload commands observed.

### Result

PASS

Telemetry successfully captured layered decoding activity.

---

# Payload Validation

## Objective

Validate that the intended payload executed successfully across all variants.

### Expected Commands

```bash
whoami
id
hostname
uname -a
ps aux
touch /tmp/.enc_exec_marker
curl http://127.0.0.1:8080/ping
```

### Validation Results

| Command                     | Observed |
| --------------------------- | -------- |
| whoami                      | PASS     |
| id                          | PASS     |
| hostname                    | PASS     |
| uname -a                    | PASS     |
| ps aux                      | PASS     |
| touch /tmp/.enc_exec_marker | PASS     |
| curl 127.0.0.1:8080         | PASS     |

### Assessment

All expected payload commands were successfully executed and recorded.

---

# Investigation Validation

## Objective

Validate that investigative findings are supported by telemetry evidence.

---

## Finding 1

### Payload Decoding Before Execution

Evidence observed in:

* Variant 1
* Variant 2
* Variant 3
* Variant 4

Validation Result:

PASS

Observed consistently across all simulations.

---

## Finding 2

### Shell-Based Execution

Evidence observed in:

* Variant 1
* Variant 2
* Variant 3
* Variant 4

Validation Result:

PASS

Every payload ultimately executed through a shell interpreter.

---

## Finding 3

### Host and User Discovery

Evidence:

```bash
whoami
id
hostname
uname -a
```

Validation Result:

PASS

Observed in every simulation.

---

## Finding 4

### Process Discovery

Evidence:

```bash
ps aux
```

Validation Result:

PASS

Observed in every simulation.

---

## Finding 5

### File System Modification

Evidence:

```bash
touch /tmp/.enc_exec_marker
```

Validation Result:

PASS

Observed in every simulation.

---

## Finding 6

### Network Activity

Evidence:

```bash
curl http://127.0.0.1:8080/ping
```

Validation Result:

PASS

Observed in every simulation.

---

# Threat Mapping Validation

## Objective

Validate that ATT&CK mappings accurately represent observed activity.

| ATT&CK Technique                                | Validation |
| ----------------------------------------------- | ---------- |
| T1027 – Obfuscated Files and Information        | PASS       |
| T1140 – Decode/Deobfuscate Files or Information | PASS       |
| T1059.004 – Unix Shell                          | PASS       |
| T1033 – System Owner/User Discovery             | PASS       |
| T1082 – System Information Discovery            | PASS       |
| T1057 – Process Discovery                       | PASS       |
| T1071 – Application Layer Protocol              | PASS       |

### Assessment

All ATT&CK mappings are supported by directly observable telemetry.

No unsupported mappings were identified.

---

# Detection Logic Validation

## Objective

Validate that the derived detection logic accurately reflects observed behavior.

---

## Logic 1

### Decoder → Shell Execution

Observed:

```text
base64 → bash
python → bash
base64 → base64 → bash
```

Validation Result:

PASS

Observed across all simulation variants.

---

## Logic 2

### Payload Reconstruction

Observed:

```text
decode
    ↓
script reconstruction
```

Validation Result:

PASS

Observed in Variant 2 and Variant 3.

---

## Logic 3

### Discovery Following Execution

Observed:

```text
execution
    ↓
whoami
id
hostname
uname
ps
```

Validation Result:

PASS

Observed in every simulation.

---

## Logic 4

### Execution Followed By Network Activity

Observed:

```text
execution
    ↓
curl
```

Validation Result:

PASS

Observed in every simulation.

---

# Sigma Rule Validation

## Objective

Validate that the Sigma rule correctly represents the detection hypothesis.

---

## Detection Coverage Assessment

| Simulation Behavior             | Covered |
| ------------------------------- | ------- |
| Base64 decoding                 | PASS    |
| Multi-stage decoding            | PASS    |
| Python decoder execution        | PASS    |
| Temporary script reconstruction | PASS    |
| Permission modification         | PASS    |
| User discovery                  | PASS    |
| Host discovery                  | PASS    |
| Process discovery               | PASS    |
| Network enumeration/activity    | PASS    |

---

## Variant Coverage Assessment

| Variant   | Covered |
| --------- | ------- |
| Variant 1 | PASS    |
| Variant 2 | PASS    |
| Variant 3 | PASS    |
| Variant 4 | PASS    |

---

## False Positive Review

Potential benign sources:

* Administrative scripts
* Software installation processes
* Automation pipelines
* Development environments
* System troubleshooting activities

Assessment:

The requirement for both payload reconstruction activity and subsequent discovery behavior significantly reduces false positives compared to detecting either behavior independently.

---

# Detection Effectiveness Assessment

The rule successfully identifies the common behavioral pattern shared across all simulation variants:

```text
Encoded Content
       ↓
Payload Reconstruction
       ↓
Interpreter Execution
       ↓
Discovery Activity
```

This behavior remained stable despite changes to:

* Encoding technique
* Decoder implementation
* Payload delivery method
* Execution mechanism

As a result, the detection logic demonstrates resilience against simple adversary modifications.

---

# Validation Conclusion

The validation process confirmed that all phases of the detection engineering workflow are supported by observable evidence.

Validation results indicate:

| Component            | Status |
| -------------------- | ------ |
| Simulation           | PASS   |
| Telemetry Collection | PASS   |
| Telemetry Analysis   | PASS   |
| Investigation        | PASS   |
| Threat Mapping       | PASS   |
| Detection Logic      | PASS   |
| Sigma Rule           | PASS   |

The encoded command execution simulations successfully generated the intended telemetry, produced consistent behavioral findings, mapped to documented adversary techniques, and resulted in a Sigma detection capable of identifying all simulated variants.

The detection engineering exercise is therefore considered successfully completed and technically validated.
