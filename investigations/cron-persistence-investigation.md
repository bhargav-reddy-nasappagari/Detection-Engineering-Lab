# Cron Persistence Investigation Report

## Incident Summary

A recurring shell script execution was observed on the Linux system through a cron-based scheduled task.

The activity involved:
- automated execution every minute
- repeated file modification
- shell-based script invocation
- observable parent-child process relationships

The investigation focused on:
- identifying the persistence mechanism
- analyzing process ancestry
- understanding recurring execution behavior
- evaluating security implications
- identifying potential detection opportunities

---

# Investigation Scope

The investigation covered:
- cron configuration analysis
- recurring process execution
- artifact generation
- process hierarchy investigation
- persistence telemetry observation
- Linux permission analysis

Commands used during the investigation included:

```bash
crontab -l
ps aux | grep cron
htop
cat heartbeat.log
ls -l heartbeat.sh
```

---

# Persistence Mechanism Overview

## Persistence Type

Observed persistence method:

```text
Cron Scheduled Task
```

The persistence mechanism relied on the Linux cron scheduling daemon to repeatedly execute a shell script.

---

## Scheduled Task Configuration

Observed cron entry:

```bash
* * * * * /home/bunny/Detection-Engineering-Lab/scripts/heartbeat.sh
```

Behavior:
- executes every minute
- launches automatically without user interaction
- persists across terminal sessions

---

# Process Analysis

## Cron Daemon

Observed process:

```text
/usr/sbin/cron -f -P
```

Observed owner:

```text
root
```

The cron daemon continuously monitored scheduled tasks and automatically executed the configured script at one-minute intervals.

---

# Parent-Child Process Investigation

## Observed Execution Chain

```text
cron
 └── sh
      └── heartbeat.sh
           └── sleep
```

---

## Behavioral Interpretation

The process ancestry demonstrated:
- daemon-initiated execution
- shell interpreter invocation
- recurring script execution
- temporary child process creation

This confirmed that:
- execution was automated
- execution originated from cron scheduling
- the script was repeatedly relaunched by the operating system scheduler

---

# Timeline Analysis

## Recurring Execution Behavior

The persistence mechanism generated:
- repeated execution every minute
- continuous file modification activity
- recurring process spawning

Observed artifacts showed:
- consistent timestamp intervals
- predictable execution cadence
- recurring telemetry generation

---

## Artifact Generation

The script repeatedly modified:

```text
~/Detection-Engineering-Lab/logs/heartbeat.log
```

Observed entries included:

```text
[+] Suspicious recurring task executed at <timestamp>
```

The repeated timestamps confirmed successful recurring execution.

---

# Permission Analysis

## Initial Misconfiguration

The script initially contained restrictive permissions:

```text
---x--x--x
```

This prevented proper readability and interfered with reliable script handling.

---

## Corrected Permissions

Permissions were corrected to:

```text
-rwxr-xr-x
```

using:

```bash
chmod 755 heartbeat.sh
```

This restored:
- script readability
- executable functionality
- stable cron execution behavior

---

# Process Visibility Findings

## Ephemeral Process Challenge

The original script executed too rapidly to reliably observe in process monitoring tools.

This revealed an important operational characteristic:

```text
Short-lived processes may evade manual observation.
```

To improve visibility, the script was modified to include:

```bash
sleep 20
```

This allowed:
- successful observation of process ancestry
- easier monitoring in `htop`
- improved runtime visibility

---

# Behavioral Characteristics

## Key Observed Behaviors

The persistence mechanism exhibited:
- recurring automated execution
- non-interactive process spawning
- shell interpreter usage
- recurring artifact generation
- scheduled execution intervals
- daemon-controlled task execution

---

# Security Implications

## Why This Behavior Matters

Cron-based persistence is frequently abused because:
- execution becomes automated
- malware can relaunch repeatedly
- persistence survives terminal closure
- recurring activity becomes difficult to notice manually

---

## Potential Malicious Use Cases

Similar behavior in production systems may indicate:
- malware persistence
- recurring beacon activity
- unauthorized automation
- scheduled payload execution
- hidden maintenance scripts
- attacker foothold maintenance

---

# Detection-Relevant Findings

## Important Detection Indicators

The investigation identified several behavioral indicators relevant to detection engineering:

| Indicator | Relevance |
|---|---|
| Cron-based recurring execution | persistence behavior |
| Shell-spawned scripts | execution ancestry |
| Repeated file modification | recurring artifact generation |
| Automated task execution | non-interactive behavior |
| Consistent timing intervals | beacon-like execution pattern |
| Short-lived process spawning | ephemeral execution behavior |

---

# Analyst Observations

Key analyst observations included:
- the cron daemon successfully automated recurring execution
- process ancestry clearly revealed scheduled execution origin
- recurring file modifications created reliable evidence artifacts
- short-lived processes were difficult to monitor manually
- process visibility improved significantly after extending runtime using `sleep`

The investigation reinforced the importance of:
- ancestry telemetry
- recurring execution analysis
- timeline-based behavioral investigation

---

# Risk Assessment

## Risk Level

```text
Moderate
```

Reasoning:
- persistence behavior was successfully established
- automated execution reduced user visibility
- recurring execution increased stealth potential
- externally destructive behavior was not observed

The simulation remained controlled and non-malicious.

---

# Recommended Detection Opportunities

Potential monitoring opportunities include:
- detecting newly created cron jobs
- monitoring recurring scheduled execution
- identifying shell-spawned scripts
- alerting on suspicious user cron entries
- monitoring recurring file modifications
- correlating cron execution with spawned child processes

---

# Investigation Outcome

The investigation successfully demonstrated:
- cron-based persistence behavior
- recurring scheduled execution
- daemon-driven process spawning
- process ancestry telemetry
- ephemeral execution challenges
- timeline-oriented investigation methodology

The scenario provided practical insight into:
- Linux persistence mechanisms
- cron abuse detection
- recurring process analysis
- persistence-oriented behavioral telemetry

This investigation significantly advanced understanding of:
- scheduled task persistence
- recurring execution telemetry
- behavioral detection engineering workflows
