# Linux Process Observations

## Objective

This document contains observations and findings related to Linux process behavior, process monitoring, service visibility, and process-to-network relationships gathered during lab experimentation.

The goal is to understand how processes behave on a Linux system and how defenders can monitor suspicious activity.

---

# Process Fundamentals

## What Is a Process?

A process is a running instance of a program loaded into memory and managed by the Linux kernel.

Examples:
- Firefox browser
- Python scripts
- SSH server
- Background system services

Each process is assigned a unique Process ID (PID).

---

# Important Commands Used

## Process Listing

```bash
ps aux
```

Purpose:
- Displays all running processes
- Shows process ownership, CPU usage, memory usage, and executed commands

Important fields:
- USER
- PID
- %CPU
- %MEM
- COMMAND

---

## Real-Time Monitoring

```bash
top
```

Purpose:
- Displays real-time process activity
- Shows CPU and memory usage dynamically

Observations:
- Useful for quick monitoring
- Less interactive than htop

---

## Enhanced Monitoring

```bash
htop
```

Purpose:
- Interactive process viewer
- Improved visibility and navigation

Key advantages:
- Tree view for parent-child processes
- Easier process filtering
- Better resource visualization
- Interactive process termination

---

# PID Observations

## Process IDs

PID represents a unique identifier assigned by the Linux kernel to track and manage processes.

Observations:
- Multiple processes can share the same name
- PIDs uniquely identify active processes
- PIDs are required for accurate process termination

Example:

```bash
kill <PID>
```

---

# Process Lifecycle Observation

## Sleep Process Experiment

Command used:

```bash
sleep 500
```

Observations:
- Creates a harmless long-running process
- Occupies the terminal while running
- Useful for practicing process monitoring and termination

Monitoring command:

```bash
ps aux | grep sleep
```

Termination command:

```bash
kill <PID>
```

---

# Process Ownership

Processes run under specific users.

Observed users:
- root
- normal user account

Security relevance:
- Root-owned processes have elevated privileges
- Unknown processes running as root may indicate suspicious activity

Commands used:

```bash
whoami
id
ps aux
```

---

# Process and Port Correlation

## Python HTTP Server Experiment

Command used:

```bash
python3 -m http.server 8080
```

Purpose:
- Created a local HTTP server listening on port 8080

Verification:

```bash
ss -tulnp | grep 8080
```

Observations:
- A listening port is associated with a running process
- Processes expose services through ports
- Ports increase system attack surface

---

# Listening Ports

## Key Understanding

A listening port means a process is waiting for incoming network connections.

Examples:
- SSH
- Web servers
- Databases

Security relevance:
- Unexpected listening ports may indicate unauthorized services or malware

---

# Localhost vs 0.0.0.0

## localhost (127.0.0.1)

- Accessible only from the local machine
- Safer for testing services

## 0.0.0.0

- Listens on all network interfaces
- Exposes services to external systems

Security concern:
- Unnecessary exposure increases attack surface

---

# Security Observations

## Suspicious Indicators

Potentially suspicious behaviors include:
- Unknown processes
- Unexpected root-owned processes
- High CPU or memory usage
- Strange process names
- Unrecognized listening ports
- Abnormal parent-child process relationships

---

# Key Concepts Learned

- Processes are active running programs
- Linux tracks processes using PIDs
- Processes can own listening ports
- Services run continuously in the background
- Process monitoring is critical for threat detection
- Behavioral analysis is important in cybersecurity investigations

---

# Future Learning Areas

Planned areas for deeper investigation:
- systemd services
- process persistence
- cron jobs
- process trees
- network traffic analysis
- log monitoring
- detection rule creation
