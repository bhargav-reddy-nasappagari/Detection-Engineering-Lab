# Suspicious Enumeration Activity Simulation

## Scenario Overview

This simulation recreates a Linux post-compromise enumeration phase commonly performed by attackers immediately after obtaining shell access on a system.

The objective of the activity was to:

* Generate realistic Linux enumeration telemetry
* Observe process execution behavior through `auditd`
* Reconstruct attacker intent from command sequences
* Engineer detection logic for suspicious host reconnaissance
* Validate detection fidelity using Sigma rules and investigation workflows

The simulation was executed from a Linux virtual machine using a scripted sequence of administrative, network, process, service, and filesystem discovery commands.

The generated telemetry was collected using:

* `auditd`
* Linux process inspection
* Terminal session logging
* Network state inspection
* Session reconstruction analysis

The activity was designed to emulate adversary discovery behavior aligned with MITRE ATT&CK Discovery tactics.

---

# Simulation Objectives

The simulation aimed to reproduce behaviors associated with:

* Local system discovery
* User and privilege discovery
* Network discovery
* Service discovery
* Defensive tooling discovery
* Sensitive file discovery
* Privilege escalation reconnaissance

The exercise focused on behavioral detection rather than malware signatures.

---

# Attack Simulation Workflow

The following workflow was followed during the simulation lifecycle:

1. Baseline collection
2. Enumeration execution
3. Telemetry collection
4. Investigation and reconstruction
5. Threat mapping
6. Detection logic engineering
7. Sigma rule validation
8. Sample event generation
9. Evidence collection
10. Documentation and reporting

This workflow mirrors practical detection engineering pipelines used in SOC and threat detection teams.

---

# Enumeration Script Executed

The following commands were executed during the simulation:

```bash
whoami
id
hostname
uname -a
groups
getent passwd
sudo -l
w
who
ip a
ip route
ss -tulnp
ps aux
systemctl list-units --type=service
systemctl list-timers
which auditctl
which tcpdump
find / -perm -4000
find /home -name "*.sh"
find / -name "*.conf"
find / -name "*.key"
journalctl -n 20
ls /var/log
```

Execution pacing was intentionally slowed using `sleep` statements to emulate realistic operator interaction rather than rapid automated execution.

---

# Attack Narrative

The simulation represents a post-access reconnaissance phase where an attacker attempts to answer the following operational questions:

| Objective                                     | Example Commands                         |
| --------------------------------------------- | ---------------------------------------- |
| Determine current identity                    | `whoami`, `id`, `groups`                 |
| Identify host information                     | `hostname`, `uname -a`                   |
| Enumerate local users                         | `getent passwd`                          |
| Check privilege escalation paths              | `sudo -l`                                |
| Identify active users                         | `w`, `who`                               |
| Discover network interfaces and routing       | `ip a`, `ip route`                       |
| Inspect listening services                    | `ss -tulnp`                              |
| Enumerate running processes                   | `ps aux`                                 |
| Discover active services                      | `systemctl list-units`                   |
| Discover scheduled tasks                      | `systemctl list-timers`                  |
| Detect defensive tooling                      | `which auditctl`, `which tcpdump`        |
| Search for privilege escalation opportunities | `find / -perm -4000`                     |
| Search for scripts and configuration files    | `find *.sh`, `find *.conf`, `find *.key` |
| Inspect logs                                  | `journalctl`, `ls /var/log`              |

The command sequence collectively demonstrates systematic environment discovery behavior commonly observed after successful compromise.

---

# Telemetry Collection

## Primary Telemetry Source

The primary telemetry source used during the simulation was:

* Linux `auditd` EXECVE events

Relevant telemetry file:

```text
logs/suspicious-enumeration/raw_auditd_execve.txt
```

The telemetry captured:

* Executed command
* Parent process
* Executable path
* Command-line arguments
* Timestamps
* Session identifiers
* TTY association
* Audit user ID (AUID)

---

# Key Telemetry Observations

## 1. Sequential Reconnaissance Activity

The telemetry showed sequential execution of multiple reconnaissance-oriented commands within a short time window.

This created a strong behavioral pattern rather than isolated benign commands.

---

## 2. Shared Session Correlation

Multiple commands shared:

* Same `auid`
* Same terminal (`tty`)
* Same shell parent process

This allowed reconstruction of a unified attacker session.

Relevant artifact:

```text
logs/suspicious-enumeration/unified_session_reconstruction_table.txt
```

Associated sample:

```text
samples/suspicious-enumeration/session_correlation_sample.json
```

---

## 3. Privilege Escalation Reconnaissance

The command:

```bash
sudo -l
```

indicated explicit privilege capability enumeration.

This behavior is highly relevant during post-compromise investigation.

Associated sample:

```text
samples/suspicious-enumeration/privilege_probe_sample.json
```

---

## 4. Defensive Tool Discovery

The following commands attempted to identify monitoring or packet inspection utilities:

```bash
which auditctl
which tcpdump
```

Attackers commonly check for these tools to assess monitoring visibility.

---

## 5. Sensitive File Discovery

The `find` operations targeted:

* SUID binaries
* Shell scripts
* Configuration files
* Key material

Examples:

```bash
find / -perm -4000
find / -name "*.key"
```

These behaviors are frequently associated with credential access preparation and privilege escalation reconnaissance.

---

# Investigation Findings

## Process Lineage Reconstruction

Although short-lived processes terminated quickly, `auditd` telemetry preserved command execution evidence.

This highlighted an important operational lesson:

> Process trees alone are insufficient for short-lived enumeration activity.

Relevant evidence:

```text
evidence/suspicious-enumeration/process-lineage-proof.png
```

---

## Session Reconstruction

The investigation successfully correlated:

* Commands
* Timestamps
* Session identifiers
* User context
* TTY association

This enabled reconstruction of the full operator activity timeline.

Relevant evidence:

```text
evidence/suspicious-enumeration/session-correlation-proof.png
```

---

## Behavioral Clustering

Individually, many commands were low fidelity.

However, the combined sequence created strong malicious context.

The detection strategy therefore emphasized:

* Command diversity
* Behavioral grouping
* Temporal clustering
* Session correlation

rather than single-command detections.

---

# Detection Engineering

## Detection Objective

Detect suspicious Linux enumeration activity indicative of post-compromise reconnaissance.

---

## Detection Strategy

The detection logic focused on:

* Reconnaissance command execution
* Excessive enumeration diversity
* Privilege probing
* Service and network discovery
* Correlated execution within shared session context

Detection logic reference:

```text
detections/logic/suspicious-enumeration-logic.md
```

Sigma rule reference:

```text
detections/sigma/linux/suspicious_enumeration.yml
```

Validation reference:

```text
detections/validation/suspicious-enumeration-validation.md
```

---

# Detection Trigger Characteristics

The following characteristics contributed to detection triggering:

| Field                  | Significance                         |
| ---------------------- | ------------------------------------ |
| `process.name`         | Enumeration utility identification   |
| `process.command_line` | Command intent visibility            |
| `auid`                 | Session attribution                  |
| `tty`                  | Interactive session tracking         |
| `parent_process`       | Shell lineage reconstruction         |
| `timestamp clustering` | Temporal behavioral grouping         |
| `command diversity`    | Multi-domain reconnaissance behavior |

Relevant sample:

```text
samples/suspicious-enumeration/triggered_detection_fields.json
```

---

# Threat Mapping

## MITRE ATT&CK Mapping

| Technique | Description                            |
| --------- | -------------------------------------- |
| T1082     | System Information Discovery           |
| T1033     | System Owner/User Discovery            |
| T1057     | Process Discovery                      |
| T1049     | System Network Connections Discovery   |
| T1016     | System Network Configuration Discovery |
| T1007     | System Service Discovery               |
| T1083     | File and Directory Discovery           |
| T1069     | Permission Groups Discovery            |

Threat mapping reference:

```text
docs/threat-mapping/suspicious-enumeration.md
```

---

# Generated Artifacts

## Telemetry

```text
telemetry/suspicious-enumeration-telemetry.md
```

## Investigation

```text
investigations/suspicious-enumeration-investigation.md
```

## Validation

```text
detections/validation/suspicious-enumeration-validation.md
```

## Samples

```text
samples/suspicious-enumeration/
```

## Evidence

```text
evidence/suspicious-enumeration/
```

---

# Validation Outcome

The Sigma rule successfully detected the simulated enumeration sequence.

The validation demonstrated:

* Accurate telemetry capture
* Correct behavioral reconstruction
* Successful session correlation
* Reliable command grouping
* Detection trigger consistency

Evidence:

```text
evidence/suspicious-enumeration/sigma-rule-vaidation-proof.jpg
```

---

# Operational Lessons Learned

## 1. Single Commands Are Weak Signals

Commands like `whoami` or `ip a` are not inherently malicious.

Detection quality improves significantly when commands are:

* grouped,
* correlated,
* and analyzed behaviorally.

---

## 2. Session Correlation Is Critical

Shared:

* `auid`
* `tty`
* shell lineage
* execution timing

provide high-value context for investigations.

---

## 3. Auditd Preserves Short-Lived Activity

Traditional process inspection tools may miss rapid execution chains.

`auditd` EXECVE telemetry retained the full execution sequence.

---

## 4. Discovery Behavior Strongly Indicates Post-Compromise Activity

The observed command sequence closely resembles real attacker reconnaissance workflows after gaining shell access.

This makes enumeration detection an important early-stage compromise detection opportunity.

---

# Conclusion

This simulation successfully recreated realistic Linux post-compromise enumeration behavior and demonstrated the complete lifecycle of detection engineering:

* Attack simulation
* Telemetry acquisition
* Behavioral investigation
* Threat mapping
* Detection engineering
* Validation
* Documentation

The resulting artifacts provide a reusable foundation for:

* SOC training
* Detection tuning
* Sigma rule development
* Threat hunting exercises
* Linux telemetry analysis
* Behavioral analytics research
