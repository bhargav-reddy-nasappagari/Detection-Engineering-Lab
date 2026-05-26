# Rogue HTTP Service Scenario

## Scenario Overview

This scenario simulates a rogue Python-based HTTP service running on a Linux system.

The objective of this simulation is to understand how defenders can:
- identify unauthorized services
- investigate listening ports
- correlate processes with network activity
- analyze exposure levels
- formulate detection opportunities

The simulation focuses on behavioral analysis and telemetry observation rather than exploitation or malware deployment.

---

# Scenario Objectives

The primary goals of this exercise are to:
- generate observable process telemetry
- create a listening network service
- analyze process-to-port relationships
- investigate externally exposed services
- document suspicious behavioral indicators
- simulate analyst investigation workflow

---

# Simulated Threat Concept

This scenario represents a situation where:
- a user manually launches an HTTP service
- the service exposes a listening TCP port
- the service becomes accessible over the network
- defenders must determine whether the behavior is legitimate or suspicious

This type of activity may resemble:
- unauthorized developer servers
- temporary file-sharing services
- rogue administrative panels
- malware-hosted HTTP listeners
- attacker staging infrastructure

---

# Environment

## Operating System

Ubuntu Linux Virtual Machine

---

## User Context

The service was launched under the user:

```text
bunny
```

---

# Tools Used

| Tool | Purpose |
|---|---|
| `python3` | Create HTTP listener |
| `ps aux` | Process enumeration |
| `ss -tulnp` | Network socket investigation |
| `htop` | Resource and hierarchy monitoring |

---

# Simulation Steps

## Step 1 — Launch Rogue HTTP Service

Command executed:

```bash
python3 -m http.server 8080
```

Purpose:
- Starts a lightweight HTTP server
- Creates a listening TCP service
- Exposes files from the current working directory

---

## Step 2 — Investigate Running Process

Command used:

```bash
ps aux | grep http.server
```

Purpose:
- Identify process ownership
- Retrieve PID information
- Observe command execution context

---

## Step 3 — Investigate Listening Port

Command used:

```bash
ss -tulnp | grep 8080
```

Purpose:
- Identify listening network port
- Determine protocol
- Correlate process with network exposure

---

## Step 4 — Monitor Process Behavior

Command used:

```bash
htop
```

Purpose:
- Observe CPU and memory utilization
- Analyze parent-child process hierarchy
- Monitor runtime behavior

---

# Observed Telemetry

## Process Information

| Attribute | Observation |
|---|---|
| Process Name | python3 |
| PID | 4978 |
| User | bunny |
| Parent Process | bash |
| Parent PID | 4949 |

---

## Process Hierarchy

Observed execution chain:

```text
bash → python3
```

This indicates that the service was manually launched through an interactive shell session.

---

## Network Exposure

Observed listener:

```text
0.0.0.0:8080
```

Protocol:
```text
TCP
```

State:
```text
LISTEN
```

---

# Exposure Analysis

The service was bound to:

```text
0.0.0.0
```

Meaning:
- the service listened on all available network interfaces
- external systems could potentially connect
- attack surface increased significantly compared to localhost-only exposure

---

# Resource Utilization

## CPU Usage

Observed behavior:
- minimal CPU utilization
- occasional minor spikes

---

## Memory Usage

Observed behavior:
- approximately 0.5% - 0.7% memory usage

The process remained lightweight while idle.

---

# Security Relevance

This behavior may be suspicious because:
- Python can rapidly create unauthorized services
- externally exposed listeners increase attack surface
- temporary development servers are often poorly secured
- attackers may host payloads or files using lightweight HTTP servers

---

# Detection Opportunities

Potential monitoring opportunities include:
- Python processes opening listening ports
- listeners bound to `0.0.0.0`
- shell-launched network services
- unexpected high-numbered HTTP listeners
- unauthorized user-space web services

---

# Investigation Focus Areas

Key investigation questions include:
- Who launched the service?
- Why is the listener exposed externally?
- Is the service expected in the environment?
- Is sensitive data accessible through the server?
- Does the process persist after reboot?
- Is external communication occurring?

---

# Key Lessons Learned

This scenario demonstrated:
- process-to-port correlation
- listening port investigation
- exposure analysis
- process hierarchy observation
- basic behavioral detection reasoning

The exercise also reinforced how:
- processes create attack surface
- services expose network interfaces
- defenders investigate suspicious listeners
- telemetry supports detection engineering workflows

---

# Scenario Outcome

The rogue HTTP service simulation successfully generated:
- observable process telemetry
- active network exposure
- investigation artifacts
- behavioral indicators
- foundational detection engineering insights

This scenario serves as the first end-to-end behavioral investigation workflow within the Detection Engineering Lab.
