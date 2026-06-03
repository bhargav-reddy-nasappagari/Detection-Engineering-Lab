# Sudo Abuse for Privilege Escalation

## Scenario Overview

This scenario simulates a Linux privilege escalation technique in which a user abuses sudo permissions to obtain root access through a GTFOBins-capable binary.

In many environments, administrators grant sudo access to specific binaries rather than unrestricted root access. While intended to limit privilege exposure, certain binaries can be abused to execute arbitrary commands or spawn interactive shells. Adversaries frequently leverage these binaries to escalate privileges after gaining initial access to a system.

This simulation focuses on the abuse of the `find` utility through sudo permissions to spawn a root shell and perform basic post-escalation discovery activities. The scenario was designed to generate realistic telemetry, investigate the resulting attack sequence, and develop behavioral detections for sudo-based privilege escalation.

---

## Simulation Objective

The primary objective of this simulation was to reproduce a realistic sudo abuse workflow and evaluate the visibility provided by Linux telemetry sources during privilege escalation activity.

Specific goals included:

* Simulate sudo permission enumeration.
* Abuse a sudo-authorized binary to obtain elevated privileges.
* Generate telemetry associated with privilege escalation.
* Capture process creation and process lineage artifacts.
* Observe privilege transitions from user to root.
* Record post-escalation discovery activity.
* Reconstruct the attack sequence from collected telemetry.
* Develop behavioral detection logic and Sigma rules.

---

## Attack Scenario

The simulated attack followed a typical privilege escalation workflow.

### Phase 1 – Sudo Enumeration

The user enumerated available sudo permissions:

```bash
sudo -l
```

The objective was to identify binaries that could potentially be abused for privilege escalation.

---

### Phase 2 – GTFOBins Abuse

The identified sudo-permitted binary was abused to execute a root shell:

```bash
sudo find . -exec /bin/bash \; -quit
```

This command leverages the command execution capabilities of `find` to spawn a shell running with elevated privileges.

---

### Phase 3 – Root Shell Creation

The privileged process chain resulted in the creation of an interactive root shell:

```text
bash
 └── sudo
      └── find
           └── bash
```

The spawned shell inherited root privileges through the sudo execution chain.

---

### Phase 4 – Post-Escalation Discovery

Following successful escalation, the operator validated access and gathered basic host information:

```bash
whoami
id
hostname
```

These commands confirmed successful privilege escalation and provided environmental context.

---

## Simulation Outcomes

The simulation successfully reproduced a complete sudo abuse privilege escalation workflow.

### Successful Privilege Escalation

The GTFOBins technique successfully spawned a root shell from a standard user context.

Observed privilege transition:

```text
uid=1000
euid=0
```

This confirmed successful escalation from an unprivileged user account to root-level execution.

---

### Telemetry Generation

The simulation generated telemetry across multiple stages of the attack lifecycle, including:

* Sudo permission enumeration.
* Privileged command execution.
* Process creation events.
* Process lineage artifacts.
* Privilege transition events.
* Post-escalation discovery commands.

The collected telemetry provided sufficient visibility to reconstruct the complete attack sequence.

---

### Process Lineage Visibility

Process ancestry clearly demonstrated the escalation chain:

```text
bash
 └── sudo
      └── find
           └── bash
```

The process relationships provided strong evidence of binary abuse and root shell creation.

---

### Behavioral Findings

The simulation revealed several behaviors commonly associated with privilege escalation activity:

* Enumeration of sudo permissions.
* Abuse of a trusted binary for unintended execution.
* Creation of a root shell through a privileged process chain.
* User-to-root privilege transition.
* Post-escalation validation and discovery activity.

These behaviors closely align with known adversary tradecraft involving sudo abuse.

---

## Detection Engineering Outcomes

The generated telemetry enabled the development of behavioral detection strategies focused on:

* GTFOBins command execution patterns.
* Suspicious sudo command usage.
* Shell creation through trusted utilities.
* Parent-child process relationships.
* User-to-root privilege escalation workflows.

The resulting detection logic was successfully translated into Sigma rules and validated against the collected telemetry.

---

## ATT&CK Mapping

| Tactic               | Technique | Description                  |
| -------------------- | --------- | ---------------------------- |
| Privilege Escalation | T1548.003 | Sudo and Sudo Caching        |
| Execution            | T1059.004 | Unix Shell                   |
| Discovery            | T1033     | System Owner/User Discovery  |
| Discovery            | T1082     | System Information Discovery |

---

## Key Takeaways

* Sudo-authorized binaries can provide unintended privilege escalation paths.
* Process lineage is highly valuable for identifying GTFOBins abuse.
* User-to-root privilege transitions provide strong investigative evidence.
* Post-escalation validation commands help reconstruct attacker intent.
* Behavioral detection strategies are more resilient than simple command matching.
* Combining process creation, lineage, and privilege transition telemetry provides strong visibility into Linux privilege escalation activity.

---

## Scenario Status

```text
Scenario: Sudo Abuse via GTFOBins Find
Attack Objective: Privilege Escalation
Result: Successful
Telemetry Collection: Successful
Detection Development: Successful
Validation Outcome: Validated
```

