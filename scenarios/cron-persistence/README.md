# Cron Persistence Scenario

## Scenario Overview

This scenario simulates a cron-based persistence mechanism on a Linux system.

The objective of this exercise was to:
- understand how cron scheduling works
- simulate recurring automated execution
- observe persistence-related telemetry
- investigate process ancestry relationships
- analyze recurring behavioral patterns
- identify detection engineering opportunities

The simulation focused on behavioral analysis rather than malware deployment or exploitation.

---

# Scenario Objectives

The primary goals of this simulation were to:
- create recurring scheduled execution
- generate persistence-related telemetry
- investigate cron-spawned processes
- analyze parent-child execution chains
- observe recurring file modifications
- document behavioral indicators relevant to persistence detection

---

# Simulated Threat Concept

The simulation represented a scenario where:
- a recurring shell script executes automatically through cron
- the process repeatedly generates artifacts
- scheduled execution persists over time
- defenders investigate the behavior for signs of unauthorized persistence

This behavior may resemble:
- malware persistence mechanisms
- recurring beacon activity
- unauthorized automation
- scheduled payload relaunching
- attacker-maintained footholds

---

# Environment

## Operating System

Ubuntu Linux Virtual Machine

---

## User Context

The cron job was configured under the user:

```text
bunny
```

---

# Persistence Mechanism

## Cron Job Configuration

Configured cron entry:

```bash
* * * * * /home/bunny/Detection-Engineering-Lab/scripts/heartbeat.sh
```

Meaning:
- execute the script every minute
- generate recurring automated activity

---

# Script Used

## Script Location

```text
~/Detection-Engineering-Lab/scripts/heartbeat.sh
```

---

## Script Contents

```bash
#!/bin/bash

echo "[+] Suspicious recurring task executed at $(date)" >> /home/bunny/Detection-Engineering-Lab/logs/heartbeat.log

sleep 20
```

---

## Script Purpose

The script was designed to:
- generate recurring telemetry
- simulate persistence behavior
- create observable process activity
- improve runtime visibility using `sleep 20`

---

# Tools Used

| Tool | Purpose |
|---|---|
| `crontab` | configure scheduled persistence |
| `ps aux` | process enumeration |
| `htop` | process ancestry monitoring |
| `cat` | artifact inspection |
| `chmod` | permission management |
| `ls -l` | permission verification |

---

# Simulation Workflow

The simulation followed the workflow below:

```text
cron daemon
    ↓
shell interpreter execution
    ↓
heartbeat.sh execution
    ↓
log artifact generation
    ↓
sleep process spawned
```

---

# Commands Executed

## Configure Cron Persistence

```bash
crontab -e
```

---

## Verify Cron Configuration

```bash
crontab -l
```

---

## Monitor Cron Processes

```bash
ps aux | grep cron
```

---

## Observe Process Ancestry

```bash
htop
```

Tree mode enabled using:

```text
F5
```

---

## Observe Generated Artifacts

```bash
cat ~/Detection-Engineering-Lab/logs/heartbeat.log
```

---

# Observed Telemetry

## Cron Daemon

Observed process:

```text
/usr/sbin/cron -f -P
```

Observed owner:

```text
root
```

---

# Process Ancestry

## Observed Parent-Child Chain

```text
cron
 └── sh
      └── heartbeat.sh
           └── sleep
```

This demonstrated:
- daemon-driven execution
- shell-based script execution
- recurring scheduled process spawning
- observable execution ancestry

---

# Recurring Artifact Generation

The script repeatedly generated entries inside:

```text
~/Detection-Engineering-Lab/logs/heartbeat.log
```

Observed artifact pattern:

```text
[+] Suspicious recurring task executed at <timestamp>
```

This confirmed:
- recurring execution
- persistence functionality
- timeline-based telemetry generation

---

# Permission Analysis

## Initial Permission Issue

The script initially contained restrictive permissions:

```text
---x--x--x
```

This prevented proper readability and created execution reliability issues.

---

## Corrected Permissions

Permissions were corrected using:

```bash
chmod 755 heartbeat.sh
```

Final permissions:

```text
-rwxr-xr-x
```

This restored:
- readability
- executability
- reliable cron execution

---

# Key Behavioral Observations

## Recurring Execution

The script executed:
- automatically
- every minute
- without direct user interaction

This simulated:
- persistence behavior
- recurring beacon-like execution
- automated task relaunching

---

## Ephemeral Process Visibility

The original script executed too quickly for reliable live observation.

This demonstrated:
- short-lived process behavior
- transient execution visibility challenges

The added `sleep 20` improved observability and allowed successful monitoring of process ancestry.

---

# Security Relevance

## Why Cron Persistence Matters

Cron-based persistence is important because:
- scheduled tasks survive terminal closure
- recurring execution may remain unnoticed
- attackers can repeatedly relaunch payloads
- automated execution reduces user visibility

---

## Potential Malicious Use Cases

Similar behaviors may indicate:
- malware persistence
- unauthorized automation
- recurring beacon activity
- scheduled payload execution
- attacker foothold maintenance

---

# Detection Opportunities

Potential detection opportunities identified during this simulation included:
- newly created cron jobs
- recurring shell script execution
- cron spawning shell interpreters
- repeated file modification activity
- executable scripts in user-controlled directories
- recurring short-lived processes

---

# Files Generated During Investigation

## Evidence Artifacts

Generated evidence included:

```text
logs/cron-persistence/
```

Artifacts stored:
- cron configuration snapshots
- process observations
- heartbeat execution logs
- permission evidence

---

# Skills Practiced

This scenario reinforced:
- Linux cron fundamentals
- persistence analysis
- process ancestry investigation
- recurring telemetry analysis
- artifact-based investigation
- permission troubleshooting
- behavioral detection reasoning

---

# Key Lessons Learned

This simulation demonstrated:
- cron-based persistence behavior
- recurring scheduled execution
- daemon-driven process spawning
- shell-based execution ancestry
- ephemeral process visibility challenges
- recurring artifact generation

The exercise also reinforced:
- persistence mechanisms generate recurring telemetry
- process ancestry reveals execution origin
- Linux permissions directly impact automation reliability
- behavioral analysis is essential in detection engineering

---

# Scenario Outcome

The cron persistence simulation successfully generated:
- recurring automated execution
- observable persistence telemetry
- process ancestry relationships
- recurring timeline artifacts
- evidence suitable for investigation and detection analysis

This scenario significantly advanced understanding of:
- Linux scheduled task persistence
- recurring behavioral telemetry
- process execution ancestry
- persistence-oriented detection engineering workflows
