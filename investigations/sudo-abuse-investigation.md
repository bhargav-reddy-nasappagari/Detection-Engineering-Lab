# Investigation Thesis – Sudo Abuse for Privilege Escalation

## Overview

This investigation evaluates telemetry collected during a simulated sudo abuse scenario in which a user leveraged a sudo-permitted binary to obtain elevated privileges through a GTFOBins technique.

The objective of the investigation is to determine whether the observed activity represents legitimate administrative behavior or a privilege escalation workflow and to identify behavioral indicators suitable for detection engineering.

---

# Investigation Objective

Determine whether a user successfully abused sudo permissions to achieve privilege escalation and establish the behavioral artifacts that reliably distinguish the activity from normal administrative operations.

---

# Investigation Hypothesis

A user enumerated available sudo permissions, identified a binary capable of executing arbitrary commands, abused that binary to spawn a root shell, and subsequently performed post-escalation validation activity.

Expected behavioral progression:

```text
Privilege Enumeration
        ↓
Sudo Execution
        ↓
Privileged Binary Abuse
        ↓
Root Shell Creation
        ↓
Privilege Validation
        ↓
Host Discovery
```

The investigation seeks evidence supporting or refuting this hypothesis.

---

# Evidence Evaluation

## Observation 1 – Sudo Permission Enumeration

Observed Activity:

```bash
sudo -l
```

### Assessment

The command is commonly used to enumerate commands available through sudo.

While not inherently malicious, its presence establishes intent to understand privilege boundaries and available escalation paths.

### Investigative Value

Questions answered:

* Did the user inspect sudo permissions?
* Was there reconnaissance prior to escalation?
* Did the escalation attempt follow permission enumeration?

### Conclusion

The activity supports the hypothesis that the user was assessing available privilege escalation opportunities.

---

## Observation 2 – Execution of a GTFOBins-Capable Binary

Observed Activity:

```bash
sudo find . -exec /bin/bash \; -quit
```

### Assessment

The command uses the `find` utility not for file discovery but for command execution.

The presence of:

```text
-exec /bin/bash
```

changes the purpose of the command from administration to shell spawning.

### Investigative Value

Questions answered:

* Was sudo used to execute an unusual command?
* Was a trusted binary leveraged for unintended functionality?
* Is the behavior consistent with GTFOBins abuse?

### Conclusion

The activity strongly supports the privilege escalation hypothesis.

The observed execution pattern aligns with documented GTFOBins techniques used to obtain elevated shell access.

---

## Observation 3 – Root Shell Creation

Observed Process Lineage:

```text
bash
 └── sudo
      └── find
           └── bash
```

### Assessment

The final child process is a shell spawned from a privileged process chain.

This lineage demonstrates successful transition from a standard user context into an elevated interactive shell.

### Investigative Value

Questions answered:

* Was privilege escalation successful?
* Did command execution lead to interactive access?
* What process relationship enabled the escalation?

### Conclusion

The evidence confirms successful root shell creation.

This is the strongest indicator that the sudo abuse achieved its objective.

---

## Observation 4 – Privilege Transition

Observed Characteristics:

```text
uid=1000
euid=0
```

### Assessment

The process transitioned from an unprivileged user context into a privileged execution context.

### Investigative Value

Questions answered:

* Did privileges change?
* Was root access obtained?
* Is there evidence of successful escalation?

### Conclusion

The privilege transition confirms elevation from a normal user account to root-level execution.

---

## Observation 5 – Post-Escalation Validation Activity

Observed Commands:

```bash
whoami
id
hostname
```

### Assessment

These commands are frequently executed immediately after privilege escalation.

They allow an operator to:

* Verify current identity.
* Confirm privilege level.
* Identify the target host.

### Investigative Value

Questions answered:

* What occurred after escalation?
* Did the user validate elevated access?
* Was discovery activity performed?

### Conclusion

The commands indicate successful privilege validation and basic host reconnaissance following escalation.

---

# Behavioral Analysis

The investigation identified a complete privilege escalation workflow rather than isolated suspicious events.

## Behavioral Sequence

```text
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

### Assessment

Each activity individually may be explainable.

However, the sequence as a whole forms a coherent attack narrative.

The value lies not in any single command but in the relationship between commands and process lineage.

---

# Suspicious Activity Evaluation

## Sudo Enumeration

Risk Level:

```text
Low
```

Reason:

Common administrative command but useful as contextual evidence.

---

## Sudo Find Execution

Risk Level:

```text
High
```

Reason:

The command directly attempts shell execution through a sudo-enabled binary.

---

## Find Spawning Bash

Risk Level:

```text
High
```

Reason:

Uncommon parent-child relationship strongly associated with privilege escalation techniques.

---

## User-to-Root Transition

Risk Level:

```text
High
```

Reason:

Represents successful privilege elevation.

---

## Elevated Discovery Commands

Risk Level:

```text
Medium
```

Reason:

Common post-exploitation validation behavior.

Individually weak but highly valuable when correlated with preceding escalation activity.

---

# Investigation Findings

## Finding 1

The user performed sudo reconnaissance prior to escalation.

Evidence:

```bash
sudo -l
```

---

## Finding 2

A GTFOBins technique was used to execute a shell through a sudo-permitted binary.

Evidence:

```bash
sudo find . -exec /bin/bash \; -quit
```

---

## Finding 3

Process lineage confirms successful root shell creation.

Evidence:

```text
sudo
 ↓
find
 ↓
bash
```

---

## Finding 4

Privilege escalation resulted in root-level execution.

Evidence:

```text
uid=1000
euid=0
```

---

## Finding 5

The root shell was actively used after escalation.

Evidence:

```bash
whoami
id
hostname
```

---

# Detection Engineering Takeaways

## High-Fidelity Detection Opportunities

### Detection Opportunity 1

GTFOBins abuse through sudo.

Behavior:

```text
sudo
        +
-exec
        +
/bin/bash
```

Expected Fidelity:

High

---

### Detection Opportunity 2

Find spawning an interactive shell.

Behavior:

```text
find
 └── bash
```

Expected Fidelity:

High

---

### Detection Opportunity 3

Sudo followed by root shell creation.

Behavior:

```text
sudo
 ↓
find
 ↓
bash
```

Expected Fidelity:

High

---

## Correlation Opportunities

A behavioral detection can correlate:

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

This sequence significantly increases confidence and reduces false positives.

---

# Final Assessment

The investigation supports the hypothesis that sudo permissions were intentionally abused to obtain root access through a GTFOBins technique.

The collected evidence demonstrates:

* Privilege enumeration.
* Abuse of a trusted binary.
* Successful root shell creation.
* User-to-root privilege transition.
* Post-escalation validation activity.

The strongest detection signals are the GTFOBins execution pattern, the `find → bash` process relationship, and the privilege transition associated with root shell creation.

These behaviors provide sufficient evidence to proceed into detection logic development and rule engineering.
