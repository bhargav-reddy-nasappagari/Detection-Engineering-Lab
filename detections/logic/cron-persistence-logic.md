# Cron Persistence Detection Logic

## Detection Objective
Detect suspicious persistence established through Linux cron jobs executing shell scripts periodically.

---

# Attack Behavior

The attacker creates or modifies a cron job that repeatedly executes a script through the cron daemon.

Observed execution chain:

cron → sh/bash → payload script

---

# Primary Detection Opportunities

## 1. Cron Spawning Shells

Detect cron daemon spawning shell interpreters such as:
- sh
- bash
- dash

Reason:
Cron commonly executes shell commands, but suspicious persistence often relies on shell-based payload execution.

---

## 2. Repeated Script Execution

Detect repeated execution of:
- scripts in user-writable directories
- hidden scripts
- unusual filenames
- high-frequency execution intervals

Examples:
- /tmp/
- /home/user/
- hidden dotfiles

---

## 3. Cron Job Creation or Modification

Detect:
- crontab modifications
- writes to:
  - /etc/crontab
  - /etc/cron.*
  - user crontabs

---

## 4. Log File Generation

Detect scripts creating repeated output files such as:
- heartbeat.log
- beacon logs
- persistence indicators

---

# Telemetry Sources

## Process Execution Telemetry
Useful fields:
- parent process
- child process
- command line
- execution path
- user

Examples:
- Sysmon for Linux
- auditd
- Elastic Defend
- CrowdStrike
- Microsoft Defender for Endpoint

---

## File Modification Telemetry

Monitor:
- cron configuration files
- suspicious script locations
- generated log artifacts

---

# High Signal Indicators

- cron spawning shell interpreters
- execution from temporary directories
- repeated periodic execution
- shell scripts launched without user interaction

---

# Potential False Positives

## Legitimate Scheduled Administration Tasks
System administrators may use cron for:
- backups
- monitoring scripts
- maintenance tasks

## Developer Automation
Developers may schedule:
- builds
- sync jobs
- cleanup scripts

---

# Tuning Opportunities

Reduce noise by:
- excluding known admin scripts
- excluding package manager cron jobs
- filtering approved automation paths
- monitoring only user-writable directories

---

# Detection Strategy

Primary strategy:
Detect cron daemon spawning shell interpreters executing scripts from suspicious paths.

Secondary strategy:
Detect cron configuration modifications followed by recurring process execution.

---

# Detection Severity

Medium to High

Severity increases when:
- persistence survives reboot
- execution occurs from temporary directories
- payload establishes outbound connections
- privilege escalation attempts follow
