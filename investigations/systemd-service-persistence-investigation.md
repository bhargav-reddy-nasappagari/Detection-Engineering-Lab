# Systemd Service Persistence Investigation Report

## Executive Summary

This investigation analyzed a suspicious Linux persistence mechanism implemented through abuse of a systemd service.

The investigation identified a custom service named `updater.service` configured to execute a shell-based payload from a user-controlled directory. The payload continuously executed in the background and generated recurring heartbeat activity, demonstrating successful persistence.

Behavioral analysis revealed:
- unauthorized service creation
- suspicious execution paths
- shell-based daemon execution
- recurring autonomous execution
- persistence resilience through automatic restart behavior

The investigation confirmed successful Linux persistence aligned with ATT&CK technique T1543.002 — Create or Modify System Process: systemd Service.

---

# ATT&CK Mapping

| Technique | ID |
|---|---|
| Create or Modify System Process: systemd Service | T1543.002 |

---

# Investigation Objective

The objective of this investigation was to:
- identify the persistence mechanism used
- analyze service execution behavior
- inspect process lineage relationships
- determine persistence characteristics
- identify suspicious operational anomalies
- derive detection opportunities from observed artifacts and telemetry

---

# Initial Indicators of Suspicious Activity

The investigation began after identifying abnormal systemd-related behavior during process monitoring and service inspection.

## Initial Suspicious Indicators

| Indicator | Observation |
|---|---|
| Unusual systemd service | Non-standard service discovered |
| User-controlled execution path | Service executed payload from `/home/bunny/` |
| Shell-based daemon execution | systemd spawned shell-based payload |
| Autonomous recurring execution | Continuous heartbeat activity observed |
| Persistence-oriented restart behavior | Service configured with `Restart=always` |

These indicators collectively suggested abuse of systemd for persistence purposes.

---

# Service Artifact Analysis

## Service File Discovery

The following service artifact was identified:

```text id="k9cmce"
/etc/systemd/system/updater.service
```

The presence of a newly created service inside the systemd service directory indicated potential persistence registration activity.

# Service Configuration Analysis

Inspection of the service definition revealed the following configuration:

```
[Unit]
Description=Updater Service

[Service]
ExecStart=/home/bunny/Detection-Engineering-Lab/scenarios/systemd-service-persistence/updater.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

# Investigative Findings

## 1. Suspicious ExecStart Path

The ExecStart directive referenced the following path:

```
/home/bunny/Detection-Engineering-Lab/scenarios/systemd-service-persistence/updater.sh
```

This path was considered suspicious because:

it resided inside a user-controlled directory
the payload was writable by a non-system user
legitimate system services rarely execute content from user home directories

Legitimate Linux services commonly execute binaries from:

/usr/bin/
/usr/sbin/
/lib/systemd/

The observed execution path introduced a behavioral inconsistency between:

a privileged persistence mechanism
and unprivileged user-controlled content

This significantly increased the likelihood of malicious persistence activity.

## 2. Persistence Registration Activity

The following systemd lifecycle operations were identified during the investigation:

```
systemctl daemon-reload
systemctl enable updater.service
systemctl start updater.service
```

These operations confirmed:

service registration
daemon configuration modification
persistence enablement
service activation

This sequence demonstrated intentional persistence establishment through the Linux service manager.

# Process Lineage Analysis

Observed Process Hierarchy

Live process monitoring revealed the following execution chain:

```
systemd
 └── updater.sh
      └── sleep
```
Additional lineage visibility was confirmed using:

```
ps -ef --forest
```

and live monitoring through htop.

# Behavioral Interpretation of Process Lineage

The observed parent-child relationship was operationally significant because:

systemd directly launched a shell-based persistence payload
the payload continuously generated child processes
execution occurred independently of interactive user sessions

Legitimate Linux services commonly appear as:

```
systemd -> nginx
systemd -> sshd
systemd -> docker
```

In contrast, the observed execution chain involved:

interpreter-based execution
shell-script persistence
recurring process spawning behavior

This deviation from standard daemon behavior strongly suggested persistence abuse.

# Persistence Behavior Analysis

## Restart Policy Analysis

The service was configured with:

```
Restart=always
```

This configuration caused:

automatic payload restart after termination
recurring execution continuity
persistence resilience

The restart policy ensured that payload execution continued even if the process exited unexpectedly.

This behavior is commonly associated with persistence-oriented attack techniques designed to maintain long-term execution reliability.

## Autonomous Execution Analysis

The payload continuously generated heartbeat entries inside:

```
/tmp/systemd-heartbeat.log
```

Observed characteristics included:

recurring file modifications
continuous background execution
autonomous execution without user interaction

This confirmed that the persistence mechanism remained active independently of terminal sessions.

## Telemetry Source Analysis

Investigative Telemetry Sources

|Tool|	Investigative Value|
|---|---|
|htop|	Live parent-child process monitoring|
|ps --forest|	Process ancestry analysis|
|systemctl status|	Service operational visibility|
|systemctl cat|	Service configuration analysis|
|journalctl|	Service lifecycle telemetry|
|Filesystem inspection|	Persistence artifact discovery|


## Telemetry Visibility Findings

The investigation determined that htop provided greater visibility into transient process relationships than pstree.

This occurred because:

htop continuously refreshed live process activity
transient child processes such as sleep appeared dynamically
pstree captured only static execution snapshots

This highlighted an important investigative principle:

```
Different telemetry sources expose different levels of behavioral visibility.
```

# Security Impact Assessment

The identified persistence mechanism introduced multiple security risks including:

long-term attacker foothold establishment
autonomous background execution
recurring payload execution
resilient persistence through automatic restart behavior
potential post-compromise operational persistence

If used maliciously in a real environment, this technique could enable:

sustained unauthorized access
remote payload execution
privilege persistence
long-term attacker presence

# Detection Opportunities

## 1. Suspicious ExecStart Paths

Potential detection opportunity:

identify services executing payloads from:
/home/
/tmp/
/dev/shm/

Rationale:

legitimate services rarely execute user-controlled content

## 2. systemd Launching Shell Interpreters

Potential detection opportunity:

detect shell interpreters spawned by systemd

Examples:

bash
sh
python
perl

Rationale:

interpreters are frequently abused for arbitrary payload execution and persistence

## 3. Unauthorized Service Creation

Potential detection opportunity:

monitor creation or modification of files inside:
/etc/systemd/system/

Rationale:

persistence through systemd requires service registration artifacts

## 4. Persistence-Oriented Restart Policies

Potential detection opportunity:

identify services configured with:
Restart=always

combined with:

suspicious execution paths
interpreter-based payloads

Rationale:

attackers commonly harden persistence through aggressive restart behavior


# Investigation Conclusion

The investigation confirmed successful Linux persistence through abuse of a systemd service.

Multiple suspicious behavioral indicators were identified including:

unauthorized service creation
execution from a user-controlled directory
shell-based daemon execution
recurring autonomous activity
persistence resilience through automatic restart policies

Process lineage analysis confirmed that systemd directly launched the persistence payload, while service configuration analysis exposed the underlying persistence mechanism.

The investigation validated several strong detection opportunities focused on:

suspicious service execution paths
interpreter-based persistence
abnormal process lineage
unauthorized systemd service registration
recurring daemonized execution behavior
