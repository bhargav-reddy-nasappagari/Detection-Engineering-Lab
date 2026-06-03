# Telemetry Analysis – Sudo Abuse via GTFOBins Find

## Scenario Overview

This analysis examines telemetry collected during a simulated Linux privilege escalation scenario in which a standard user abused sudo permissions to obtain a root shell through the GTFOBins `find` technique.

The objective of this analysis is to determine:

* What telemetry was generated during the attack.
* What security-relevant observations can be extracted.
* How the telemetry can be translated into investigation logic.
* Which behaviors are suitable candidates for detection engineering.

---

# Data Sources

The following telemetry sources were available during the simulation:

| Source                              | Purpose                            |
| ----------------------------------- | ---------------------------------- |
| Auditd EXECVE                       | Process execution visibility       |
| Auditd Privilege Escalation Rule    | User-to-root transitions           |
| Process Lineage Telemetry           | Parent-child process relationships |
| Sysmon for Linux                    | Process creation visibility        |
| Auditd Discovery Command Monitoring | Host discovery activity            |

---

# Attack Timeline

The simulated attack progressed through four distinct stages.

## Stage 1 – Sudo Permission Enumeration

The user executed:

```bash
sudo -l
```

to determine which commands were permitted through sudo.

Observed telemetry:

```text
Process: sudo
Arguments: -l
User: bunny
UID: 1000
```

### Security Insight

This activity represents privilege discovery and is frequently observed before sudo abuse attempts.

The command itself is not malicious but provides an attacker with information about available privilege escalation paths.

---

## Stage 2 – Sudo-Based Privilege Escalation

The user executed:

```bash
sudo find . -exec /bin/bash \; -quit
```

Observed telemetry:

```text
Process: sudo
Arguments:
find
.
-exec
/bin/bash
;
-quit
```

### Security Insight

This is the most significant event observed during the simulation.

The command leverages a GTFOBins technique whereby an attacker abuses a sudo-allowed binary to spawn an interactive shell.

Unlike normal administrative usage of sudo, the purpose of this execution is not file searching but shell creation.

Behavioral interpretation:

```text
User
 ↓
sudo
 ↓
find
 ↓
bash
```

This behavior is highly indicative of privilege escalation activity.

---

## Stage 3 – Root Shell Creation

Process lineage telemetry revealed:

```text
bash
 └── sudo
      └── find
           └── bash
```

The final child process was a root shell.

Observed characteristics:

```text
UID = 0
EUID = 0
Process = bash
Parent = find
```

### Security Insight

The process tree demonstrates a direct privilege transition from an unprivileged user context into an interactive root shell.

This process relationship provides stronger detection value than monitoring standalone sudo executions.

---

## Stage 4 – Post-Escalation Discovery

Following root shell creation, the user executed:

```bash
whoami
id
hostname
```

Observed telemetry:

```text
whoami
id
hostname
```

executing under:

```text
UID=0
```

### Security Insight

Attackers commonly verify successful privilege escalation immediately after obtaining elevated access.

The collected commands indicate:

| Command  | Purpose           |
| -------- | ----------------- |
| whoami   | Confirm identity  |
| id       | Verify privileges |
| hostname | Identify host     |

The sequence demonstrates post-escalation validation and environment discovery.

---

# Telemetry Breakdown for Investigation

The collected telemetry can be organized into investigation-focused categories.

## Investigation Question 1

### Did a user attempt to enumerate sudo permissions?

Evidence:

```bash
sudo -l
```

Investigation Value:

* Indicates privilege reconnaissance.
* Establishes attacker intent.
* Provides pre-escalation context.

Relevant Artifacts:

* EXECVE logs
* Process creation events

---

## Investigation Question 2

### Was sudo used to launch an unexpected binary?

Evidence:

```bash
sudo find . -exec /bin/bash \; -quit
```

Investigation Value:

* Indicates potential GTFOBins abuse.
* Highlights suspicious use of a trusted binary.
* Suggests privilege escalation attempt.

Relevant Artifacts:

* EXECVE telemetry
* Command-line arguments
* Process creation records

---

## Investigation Question 3

### Was a root shell spawned?

Evidence:

```text
sudo
 ↓
find
 ↓
bash
```

Investigation Value:

* Confirms successful escalation.
* Establishes attacker access level.
* Provides strong detection fidelity.

Relevant Artifacts:

* Process lineage
* Parent-child relationships
* Process creation telemetry

---

## Investigation Question 4

### What actions were performed after escalation?

Evidence:

```bash
whoami
id
hostname
```

Investigation Value:

* Determines attacker objectives.
* Reveals post-exploitation activity.
* Helps reconstruct session chronology.

Relevant Artifacts:

* EXECVE events
* Root process activity

---

# Suspicious Behaviors Identified

## Sudo Permission Enumeration

```bash
sudo -l
```

Reason:

Frequently observed prior to sudo abuse.

---

## GTFOBins Find Abuse

```bash
sudo find . -exec /bin/bash \; -quit
```

Reason:

Legitimate utility used for privilege escalation.

---

## Shell Spawn from Find

```text
find
 └── bash
```

Reason:

Uncommon and highly suspicious process relationship.

---

## User-to-Root Privilege Transition

Observed:

```text
UID = 1000
EUID = 0
```

Reason:

Direct evidence of successful privilege escalation.

---

## Elevated Discovery Activity

Observed:

```bash
whoami
id
hostname
```

executed as root.

Reason:

Common attacker validation sequence following escalation.

---

# Detection Engineering Takeaways

## High-Fidelity Behaviors

The following behaviors provide strong detection opportunities:

### GTFOBins Find Abuse

```bash
sudo find . -exec /bin/bash \; -quit
```

Detection Confidence:

High

Reason:

Specific command pattern with low false-positive potential.

---

### Find Spawning Bash

```text
find
 └── bash
```

Detection Confidence:

High

Reason:

Rare in legitimate administrative workflows.

---

### Sudo Followed by Interactive Root Shell

```text
sudo
 ↓
find
 ↓
bash
```

Detection Confidence:

High

Reason:

Directly represents successful privilege escalation.

---

## Behavioral Correlation Opportunities

Multiple events can be chained together:

```text
sudo -l
      ↓
sudo find
      ↓
root bash
      ↓
whoami
id
hostname
```

This sequence creates a high-confidence behavioral detection model.

---

# Key Findings

1. The telemetry successfully captured privilege enumeration activity.
2. The GTFOBins privilege escalation technique was fully observable.
3. Process lineage clearly demonstrated root shell creation.
4. User-to-root privilege transition was recorded.
5. Post-escalation discovery commands were visible.
6. The collected telemetry is sufficient to support investigation, detection development, alert enrichment, and session reconstruction.

---

# Conclusion

The simulation generated a complete privilege escalation narrative consisting of reconnaissance, escalation, root shell creation, and post-exploitation discovery activity.

The most valuable telemetry artifacts were process creation events, command-line arguments, privilege transition records, and process lineage data. Together, these sources provide sufficient visibility to construct reliable detections for sudo abuse and GTFOBins-based privilege escalation techniques.

