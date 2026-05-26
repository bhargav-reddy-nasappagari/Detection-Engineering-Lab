# Systemd Service Persistence Telemetry Analysis

## Simulation Overview

This simulation demonstrates Linux persistence through abuse of a systemd service.  
A custom service was created to execute a shell-based payload continuously in the background using the system service manager.

The payload repeatedly wrote heartbeat entries into a log file, allowing recurring execution activity to be observed over time.

The objective of this simulation was to:
- understand how attackers abuse systemd persistence
- observe service lifecycle telemetry
- analyze process lineage relationships
- identify behavioral anomalies
- derive detection opportunities from observed telemetry

---

# ATT&CK Mapping

| Technique | ID |
|---|---|
| Create or Modify System Process: systemd Service | T1543.002 |

---

# Persistence Mechanism Overview

A malicious systemd service was configured to execute a shell script located in a user-controlled directory.

## Service Characteristics

| Attribute | Value |
|---|---|
| Service Type | systemd persistence |
| Service File Location | `/etc/systemd/system/updater.service` |
| Payload Location | `/home/bunny/Detection-Engineering-Lab/scenarios/systemd-service-persistence/updater.sh` |
| Execution Method | `ExecStart` directive |
| Persistence Mechanism | `Restart=always` |
| Execution Pattern | Continuous recurring execution |

---

# Service Configuration Telemetry

The service configuration revealed that the persistence mechanism executed a shell-based payload from a user-controlled directory.

## Observed ExecStart Configuration

```ini
[Service]
ExecStart=/home/bunny/Detection-Engineering-Lab/scenarios/systemd-service-persistence/updater.sh
Restart=always
```
#Telemetry Observations

## 1. Suspicious Execution Path

The service executed a payload from the following location:

/home/bunny/Detection-Engineering-Lab/scenarios/systemd-service-persistence/

This path is operationally unusual for legitimate system services because:

it resides inside a user-controlled directory
the payload is writable by a non-system user
legitimate services commonly execute binaries from:
/usr/bin/
/usr/sbin/
/lib/systemd/

This creates a behavioral anomaly where a privileged persistence mechanism executes unprivileged user-controlled content.

## 2. Service Registration Activity

The following systemd lifecycle operations were observed:

systemctl daemon-reload
systemctl enable updater.service
systemctl start updater.service

These actions introduced new persistence artifacts into the system and activated the service for recurring execution.

Observed effects included:

service registration
daemon configuration reload
service enablement
autonomous execution

# Process Lineage Telemetry

Observed Process Hierarchy

Live process monitoring through htop revealed the following execution chain:

```
systemd
 └── updater.sh
      └── sleep
```

Additional lineage visibility was observed using:

ps -ef --forest

# Behavioral Analysis of Process Lineage

The observed hierarchy is operationally significant because:

systemd directly spawned a shell-based persistence script
the shell script continuously generated child processes
execution occurred outside standard daemon behavior

Legitimate Linux services commonly appear as:
```
systemd -> nginx
systemd -> sshd
systemd -> docker
```

In contrast, the simulation revealed:
```
systemd -> updater.sh
```

This introduces a suspicious behavioral relationship involving:

interpreter-based execution
user-controlled payloads
persistence-oriented process spawning

# Persistence Behavior Analysis

The service utilized the following persistence configuration:

```
Restart=always
```

This caused the payload to:

automatically restart after termination
survive shell closure
maintain recurring execution activity

This behavior increases persistence resilience by ensuring continued payload execution even if the process exits unexpectedly.

# Recurring Execution Telemetry

The payload continuously generated heartbeat entries inside:

```
/tmp/systemd-heartbeat.log
```

Observed telemetry characteristics included:

recurring execution intervals
repeated file modification activity
continuous autonomous background execution

This recurring behavior demonstrated active persistence independent of interactive user sessions.

# Telemetry Collection Sources

|Tool|	Observed Visibility|
|htop|	Live parent-child process hierarchy|
|ps --forest|	Process ancestry relationships|
|systemctl status|	Service operational state|
|systemctl cat|	Service configuration analysis|
|journalctl|	Service lifecycle telemetry|
|filesystem inspection|	Service artifact discovery|

# Telemetry Visibility Observations

htop vs pstree Visibility

The process hierarchy was more clearly observable in htop than in pstree.

This occurred because:

htop continuously refreshes live processes
child processes such as sleep were transient
pstree captured only a static process snapshot

This demonstrated an important telemetry engineering concept:

```
Different telemetry tools provide different levels of process visibility.
```

# Detection Opportunities

## 1. Services Executing From User-Controlled Paths

Potential detection logic:

identify services whose ExecStart references:
/home/
/tmp/
/dev/shm/

Rationale:

legitimate services rarely execute payloads from user-writable locations

## 2. Shell Interpreters Spawned By systemd

Potential detection logic:

identify shell interpreters launched as child processes of systemd

Examples:

bash
sh
python
perl

Rationale:

interpreters are frequently abused for arbitrary payload execution and persistence

## 3. Suspicious Restart Policies

Potential detection logic:

identify unusual services configured with:
Restart=always

Rationale:

attackers commonly use aggressive restart behavior to maintain persistence resilience

## 4. Unauthorized Service Creation

Potential detection logic:

monitor creation or modification of files inside:
/etc/systemd/system/

Rationale:

persistence through systemd requires service registration artifacts

# Key Behavioral Findings
|Observation|	Detection Relevance|
|systemd launched a shell-based payload|	Suspicious daemon execution|
|ExecStart referenced user-controlled path|	Persistence anomaly|
|Restart=always enabled recurring execution|	Persistence resilience|
|Continuous heartbeat generation observed|	Autonomous execution behavior|
|Service survived terminal closure|	Successful persistence|

# Conclusion

This simulation successfully demonstrated Linux persistence through abuse of systemd services.

The attack generated multiple observable telemetry artifacts including:

service registration activity
suspicious process lineage
recurring execution patterns
shell-based daemon behavior
persistence configuration artifacts

The collected telemetry provides strong behavioral indicators for developing ATT&CK-aligned detections focused on:

suspicious service execution paths
interpreter-based persistence
abnormal parent-child relationships
unauthorized service creation
recurring daemonized execution
