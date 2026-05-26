# Cron Persistence Telemetry Observation

## Objective

This document contains telemetry observations collected during the simulation of a recurring cron-based persistence mechanism on a Linux system.

The purpose of this exercise was to:
- simulate automated recurring execution
- observe cron-based process spawning
- investigate parent-child process relationships
- analyze persistence behavior
- generate recurring telemetry artifacts
- identify detection opportunities related to scheduled execution

---

# Scenario Summary

A shell script named `heartbeat.sh` was scheduled using cron to execute automatically every minute.

The script generated recurring log entries and created observable persistence-related telemetry.

The simulation demonstrated:
- scheduled execution
- recurring process spawning
- cron-driven automation
- process ancestry relationships
- persistent behavioral patterns

---

# Simulation Workflow

The persistence simulation followed the workflow below:

```text
cron daemon
    ↓
shell interpreter execution
    ↓
heartbeat.sh execution
    ↓
log artifact creation
    ↓
sleep process spawned
```

---

# Commands Executed

## Create Persistence Script

Script location:

```text
~/Detection-Engineering-Lab/scripts/heartbeat.sh
```

Script contents:

```bash
#!/bin/bash

echo "[+] Suspicious recurring task executed at $(date)" >> /home/bunny/Detection-Engineering-Lab/logs/heartbeat.log

sleep 20
```

Purpose:
- generate recurring execution artifacts
- simulate persistence behavior
- increase process visibility for investigation

---

## Make Script Executable

```bash
chmod +x ~/Detection-Engineering-Lab/scripts/heartbeat.sh
```

Purpose:
- enable script execution through cron
- apply executable permissions

---

## Configure Cron Persistence

```bash
crontab -e
```

Configured cron entry:

```bash
* * * * * /home/bunny/Detection-Engineering-Lab/scripts/heartbeat.sh
```

Meaning:
- execute the script every minute
- create recurring scheduled execution behavior

---

## Verify Cron Configuration

```bash
crontab -l
```

Purpose:
- confirm successful cron registration
- validate persistence configuration

---

## Monitor Cron Processes

```bash
ps aux | grep cron
```

Purpose:
- identify active cron daemon
- observe cron-related process activity

---

## Observe Parent-Child Relationships

```bash
htop
```

Tree mode enabled using:

```text
F5
```

Purpose:
- analyze execution ancestry
- observe cron-spawned child processes

---

## Observe Generated Artifacts

```bash
cat ~/Detection-Engineering-Lab/logs/heartbeat.log
```

Purpose:
- verify recurring execution
- observe generated timestamps
- confirm persistence activity

---

# Process Analysis

## Cron Daemon Observation

Observed process:

```text
/usr/sbin/cron -f -P
```

Observed owner:

```text
root
```

This process represents the Linux cron scheduling daemon responsible for executing scheduled jobs.

---

# Parent-Child Process Relationships

## Observed Process Chain

```text
cron
 └── sh
      └── heartbeat.sh
           └── sleep
```

---

## Behavioral Interpretation

The observed ancestry chain demonstrated:
- cron-driven automated execution
- shell interpreter invocation
- script-based persistence behavior
- child process spawning

The temporary `sleep` process extended runtime visibility, making execution ancestry easier to observe during live monitoring.

---

# Persistence Analysis

## Recurring Execution Pattern

The cron job executed:
- automatically
- repeatedly
- every minute

This behavior simulated:
- scheduled persistence
- recurring beacon-like execution
- automated malicious task relaunching

---

## Artifact Generation

The script continuously appended entries to:

```text
~/Detection-Engineering-Lab/logs/heartbeat.log
```

Observed log format:

```text
[+] Suspicious recurring task executed at <timestamp>
```

---

## Timeline Characteristics

Observed behavior:
- consistent one-minute execution interval
- repeated file modification activity
- recurring process creation events

This created:
- persistent telemetry generation
- timeline-based execution evidence

---

# File and Permission Analysis

## Script Permissions

Observed permissions:

```text
-rwxr-xr-x
```

Permission breakdown:

| Entity | Permissions |
|---|---|
| Owner | Read, Write, Execute |
| Group | Read, Execute |
| Others | Read, Execute |

---

## Earlier Permission Misconfiguration

An earlier configuration mistakenly applied:

```text
---x--x--x
```

This prevented proper script readability and interfered with reliable execution behavior.

The issue was corrected using:

```bash
chmod 755 heartbeat.sh
```

This demonstrated the operational importance of Linux permission management during automation workflows.

---

# Process Visibility Observations

## Ephemeral Execution Challenge

The original script executed too quickly to reliably observe in live process monitoring tools.

This highlighted an important detection engineering concept:

```text
Short-lived processes are difficult to observe manually.
```

To improve observability, the script was modified to include:

```bash
sleep 20
```

This extended process lifetime and allowed successful observation of:
- cron spawning behavior
- execution ancestry
- temporary child processes

---

# Resource Utilization Observations

## CPU Usage

Observed behavior:
- negligible CPU consumption
- temporary short-lived execution spikes

---

## Memory Usage

Observed behavior:
- minimal memory usage
- lightweight recurring execution

The cron persistence simulation consumed very few system resources while still generating meaningful telemetry.

---

# Security-Relevant Observations

## Behavioral Indicators

Observed suspicious characteristics included:
- recurring automated execution
- user-space persistence mechanism
- shell-based script execution
- repeated artifact generation
- scheduled task automation
- process ancestry involving cron

---

## Potential Security Risks

Similar behaviors in production environments may indicate:
- malware persistence
- unauthorized scheduled tasks
- recurring beacon activity
- hidden automation
- attacker-maintained footholds
- scheduled payload execution

---

# Detection-Relevant Telemetry

Relevant telemetry sources observed during this simulation included:

| Telemetry Type | Observation |
|---|---|
| Process telemetry | cron-spawned script execution |
| Process ancestry | cron → sh → heartbeat.sh |
| File modification telemetry | recurring heartbeat.log updates |
| Persistence configuration | crontab scheduled task |
| Timing telemetry | recurring one-minute execution |
| Permission telemetry | executable shell script permissions |

---

# Key Lessons Learned

This simulation demonstrated:
- cron-based persistence behavior
- recurring scheduled execution
- process ancestry analysis
- ephemeral process visibility challenges
- timeline-oriented telemetry generation
- artifact-based investigation methodology

The exercise also reinforced:
- persistence mechanisms create recurring telemetry
- automated execution can be difficult to observe manually
- process ancestry provides critical behavioral context
- Linux permissions directly affect automation reliability
- recurring execution patterns are valuable detection opportunities

---

# Investigation Outcome

The cron persistence simulation successfully generated:
- recurring scheduled execution
- observable persistence behavior
- process ancestry telemetry
- recurring file modification artifacts
- automation-related process chains
- evidence suitable for behavioral detection analysis

This scenario provided foundational understanding of:
- Linux persistence mechanisms
- cron-based automation abuse
- recurring execution telemetry
- scheduled task investigation workflows
