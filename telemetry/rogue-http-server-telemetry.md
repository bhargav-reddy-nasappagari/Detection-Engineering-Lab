# Rogue HTTP Service Telemetry Observation

## Objective

This document contains telemetry observations collected during the simulation of a rogue Python HTTP service running on a Linux system.

The purpose of this exercise was to:
- generate observable network activity
- inspect process behavior
- identify listening ports
- correlate process and network telemetry
- understand potential detection opportunities

---

# Scenario Summary

A Python-based HTTP server was intentionally launched on TCP port `8080` using the following command:

```bash
python3 -m http.server 8080
```

This created:
- a running Python process
- an active listening network port
- externally exposed service telemetry
- observable parent-child process relationships

---

# Commands Executed

## Start Rogue HTTP Service

```bash
python3 -m http.server 8080
```

Purpose:
- Starts a lightweight Python HTTP server
- Opens TCP port `8080`
- Serves files from the current directory

---

## Process Investigation

```bash
ps aux | grep http.server
```

Purpose:
- Identifies the running Python HTTP process
- Displays ownership and PID information

---

## Listening Port Investigation

```bash
ss -tulnp | grep 8080
```

Purpose:
- Identifies active listening ports
- Correlates port ownership with running processes

---

## Real-Time Resource Monitoring

```bash
htop
```

Purpose:
- Observes CPU and memory utilization
- Displays process hierarchy and ownership

---

# Process Analysis

## Process Name

```text
python3
```

---

## Process Owner

```text
bunny
```

The process was executed under the currently logged-in user account.

---

## Process ID (PID)

```text
4978
```

The Linux kernel assigned PID `4978` to the Python HTTP server process.

---

## Parent Process

```text
bash
```

Parent PID:

```text
4949
```

Observed hierarchy:

```text
bash → python3
```

This indicates that the Python listener was manually launched from an interactive shell session.

---

# Network Telemetry Analysis

## Protocol

```text
TCP
```

The service was listening over the TCP protocol.

---

## Listening Port

```text
8080
```

Port `8080` is commonly used for:
- development web servers
- testing environments
- temporary HTTP services

---

## Listening State

Observed state:

```text
LISTEN
```

This indicates that the process was actively waiting for incoming network connections.

---

# Exposure Analysis

## Observed Listening Address

```text
0.0.0.0:8080
```

This is a critical telemetry observation.

The service was not restricted to localhost (`127.0.0.1`).

Instead, it was configured to listen on:
- all available network interfaces
- all reachable IP addresses assigned to the machine

---

## Security Implications

Exposure on `0.0.0.0` increases attack surface because:
- external systems may connect to the service
- unauthorized users could potentially access exposed files
- rogue services become network-accessible
- unintended remote exposure may occur

Depending on firewall and routing configuration, the service may be accessible from:
- local network devices
- other virtual machines
- external systems

---

# Resource Utilization Observations

## CPU Usage

Observed CPU activity:

```text
Very low / minimal spikes
```

The service consumed negligible CPU resources while idle.

This is expected behavior for a lightweight HTTP listener waiting for incoming requests.

---

## Memory Usage

Observed memory usage:

```text
Approximately 0.5% - 0.7%
```

The Python process consumed minimal memory resources during operation.

---

# Behavioral Observations

## Key Findings

Observed behaviors included:
- manually launched Python HTTP service
- externally exposed listening port
- active TCP listener
- low resource consumption
- interactive shell-based execution
- process-to-port correlation

---

# Detection-Relevant Observations

Potentially suspicious indicators include:
- unexpected Python listeners
- unauthorized web services
- externally exposed development servers
- unknown services listening on high-numbered ports
- manually launched listeners outside approved workflows

---

# Process-to-Port Correlation

The following relationship was observed:

```text
python3 (PID 4978)
        ↓
Listening on TCP port 8080
        ↓
Bound to 0.0.0.0
```

This demonstrates direct correlation between:
- process telemetry
- network exposure
- listening service behavior

---

# Security Considerations

Potential risks associated with this behavior include:
- unauthorized file exposure
- hidden development services
- malware-controlled HTTP listeners
- data leakage
- unintended remote access

Even lightweight services may create significant attack surface if exposed externally.

---

# Investigation Summary

The simulated rogue HTTP service successfully generated:
- process telemetry
- network listener telemetry
- exposure indicators
- process hierarchy evidence
- observable behavioral patterns

This exercise demonstrated how defenders can:
- identify listening services
- correlate ports to processes
- evaluate exposure levels
- investigate suspicious network behavior

---

# Key Lessons Learned

- Processes can expose network services through listening ports
- Listening on `0.0.0.0` increases exposure risk
- PID correlation is critical for investigations
- Parent-child process relationships provide execution context
- Unauthorized listeners are important detection opportunities
- Network exposure should always be evaluated alongside process behavior
