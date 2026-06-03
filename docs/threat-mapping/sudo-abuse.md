# Threat Mapping Analysis – Sudo Abuse via GTFOBins Find

## Overview

This document maps the suspicious behaviors observed during the sudo abuse simulation to known adversary techniques and tradecraft documented in MITRE ATT&CK.

The objective of this phase is to determine:

* Which observed activities align with known attacker behaviors.
* Which ATT&CK tactics and techniques are represented.
* The severity of each behavior.
* The operational risk associated with successful execution.
* The behaviors most suitable for detection engineering.

---

# Attack Summary

The investigation identified a privilege escalation workflow in which a standard user enumerated sudo permissions, abused a sudo-permitted binary (`find`) to execute a shell, obtained root privileges, and performed post-escalation validation activity.

Observed attack sequence:

```text id="tm001"
sudo -l
        ↓
sudo find . -exec /bin/bash \; -quit
        ↓
find spawns bash
        ↓
root shell established
        ↓
whoami
id
hostname
```

The sequence is consistent with privilege escalation tradecraft commonly used by adversaries after initial access has been established.

---

# ATT&CK Mapping

## Technique 1 – Sudo Permission Enumeration

### Observed Activity

```bash id="att001"
sudo -l
```

### ATT&CK Mapping

| Category       | Value             |
| -------------- | ----------------- |
| Tactic         | Discovery         |
| Technique      | T1087             |
| Technique Name | Account Discovery |

### Behavioral Analysis

The command allows a user to inspect available sudo permissions and determine which binaries may be executed with elevated privileges.

From an attacker perspective this activity serves as privilege reconnaissance.

### Severity Assessment

```text id="sev001"
Low
```

### Risk Assessment

Low as an isolated event.

However, risk increases significantly when followed by privileged command execution.

---

## Technique 2 – Abuse of Elevation Control Mechanism

### Observed Activity

```bash id="att002"
sudo find . -exec /bin/bash \; -quit
```

### ATT&CK Mapping

| Category       | Value                 |
| -------------- | --------------------- |
| Tactic         | Privilege Escalation  |
| Technique      | T1548                 |
| Sub-Technique  | T1548.003             |
| Technique Name | Sudo and Sudo Caching |

### Behavioral Analysis

The user leveraged sudo authorization to execute a binary capable of launching arbitrary commands.

The command is not performing its intended administrative function.

Instead, the binary is being abused to gain elevated shell access.

This behavior directly matches known sudo abuse techniques documented within ATT&CK.

### Severity Assessment

```text id="sev002"
High
```

### Risk Assessment

High.

Successful execution grants elevated privileges and may enable complete host compromise.

---

## Technique 3 – Command and Script Interpreter

### Observed Activity

```text id="att003"
find
 └── bash
```

### ATT&CK Mapping

| Category       | Value      |
| -------------- | ---------- |
| Tactic         | Execution  |
| Technique      | T1059      |
| Sub-Technique  | T1059.004  |
| Technique Name | Unix Shell |

### Behavioral Analysis

The attacker obtains interactive command execution through a spawned shell.

The shell serves as the primary interface for executing subsequent actions.

### Severity Assessment

```text id="sev003"
High
```

### Risk Assessment

High.

Interactive shell access provides flexibility for persistence, credential access, lateral movement, and defense evasion.

---

## Technique 4 – System Information Discovery

### Observed Activity

```bash id="att004"
whoami
id
hostname
```

### ATT&CK Mapping

| Command  | ATT&CK Technique |
| -------- | ---------------- |
| whoami   | T1033            |
| id       | T1033            |
| hostname | T1082            |

### Behavioral Analysis

These commands are frequently executed immediately after privilege escalation.

The objective is to validate elevated access and gather basic host context.

### Severity Assessment

```text id="sev004"
Medium
```

### Risk Assessment

Moderate.

The commands themselves are benign but become meaningful when observed after successful privilege escalation.

---

# Adversary Tradecraft Comparison

## Observed Behavior vs Known Adversary Methodology

### Stage 1 – Reconnaissance of Privileges

Observed:

```bash id="cmp001"
sudo -l
```

Common Adversary Objective:

```text id="cmp002"
Determine available escalation paths
```

Assessment:

Strong alignment.

This behavior is frequently observed before sudo-based privilege escalation attempts.

---

### Stage 2 – Abuse of Trusted Binary

Observed:

```bash id="cmp003"
sudo find . -exec /bin/bash \; -quit
```

Common Adversary Objective:

```text id="cmp004"
Bypass restrictions using trusted utilities
```

Assessment:

Strong alignment.

GTFOBins techniques exist specifically because legitimate binaries can be abused for privilege escalation.

---

### Stage 3 – Root Shell Acquisition

Observed:

```text id="cmp005"
find
 └── bash
```

Common Adversary Objective:

```text id="cmp006"
Obtain unrestricted elevated execution
```

Assessment:

Strong alignment.

The shell represents the attacker's operational objective during the escalation phase.

---

### Stage 4 – Validation and Discovery

Observed:

```bash id="cmp007"
whoami
id
hostname
```

Common Adversary Objective:

```text id="cmp008"
Verify access and collect host context
```

Assessment:

Strong alignment.

This behavior is consistent with post-escalation validation procedures.

---

# Risk Analysis

## Potential Impact if Observed in Production

### Confidentiality Impact

Risk:

```text id="risk001"
High
```

Reason:

Root access permits unrestricted access to system data, user files, credentials, and application secrets.

---

### Integrity Impact

Risk:

```text id="risk002"
High
```

Reason:

An attacker may modify system binaries, security controls, services, or application data.

---

### Availability Impact

Risk:

```text id="risk003"
High
```

Reason:

Root privileges enable service disruption, destructive actions, or system shutdown.

---

# Behavioral Risk Matrix

| Behavior                | ATT&CK Mapping | Severity | Risk   |
| ----------------------- | -------------- | -------- | ------ |
| sudo -l                 | T1087          | Low      | Low    |
| sudo find abuse         | T1548.003      | High     | High   |
| find spawning bash      | T1059.004      | High     | High   |
| user-to-root transition | T1548.003      | High     | High   |
| whoami                  | T1033          | Medium   | Medium |
| id                      | T1033          | Medium   | Medium |
| hostname                | T1082          | Medium   | Medium |

---

# Detection Engineering Relevance

The investigation identified several ATT&CK-aligned behaviors with strong detection value.

## Highest Fidelity Behaviors

### GTFOBins Sudo Abuse

```bash id="det001"
sudo find . -exec /bin/bash \; -quit
```

Detection Value:

Very High

Reason:

Specific and uncommon command pattern.

---

### Find Spawning Bash

```text id="det002"
find
 └── bash
```

Detection Value:

Very High

Reason:

Rare parent-child relationship strongly associated with abuse.

---

### Root Shell Following Sudo

```text id="det003"
sudo
 ↓
find
 ↓
bash
```

Detection Value:

Very High

Reason:

Represents successful privilege escalation rather than an attempted action.

---

# Threat Assessment

The observed activity demonstrates a complete privilege escalation workflow that aligns closely with ATT&CK techniques associated with sudo abuse and shell execution.

The behavior is not indicative of routine administrative usage because:

* Sudo permissions were actively enumerated.
* A trusted binary was repurposed to execute a shell.
* A root shell was successfully created.
* Elevated discovery commands immediately followed escalation.

Taken together, the activity represents a high-confidence privilege escalation event with high operational risk and strong suitability for behavioral detection engineering.

---

# Conclusion

Threat mapping confirms that the simulated activity aligns with established adversary tradecraft documented in MITRE ATT&CK.

The most significant techniques observed were:

* T1548.003 – Sudo and Sudo Caching
* T1059.004 – Unix Shell
* T1033 – System Owner/User Discovery
* T1082 – System Information Discovery

The overall threat severity is assessed as **High** because the activity results in successful root-level execution. The strongest detection opportunities are the GTFOBins execution pattern, the `find → bash` process relationship, and the verified privilege transition from user to root.
