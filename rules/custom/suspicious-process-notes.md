# Suspicious Process Notes

## Objective

This document contains observations and analysis related to potentially suspicious Linux process behavior observed during process monitoring and system investigation exercises.

The purpose of these notes is to build foundational detection engineering knowledge by understanding:
- abnormal process behavior
- suspicious execution patterns
- unauthorized services
- process-to-network relationships
- indicators of compromise (IOCs)

The focus is on behavioral analysis rather than signature-based detection.

---

# Understanding Process Monitoring

Process monitoring is a critical part of:
- threat hunting
- incident response
- malware analysis
- endpoint detection and response (EDR)
- detection engineering

Every executable program running on a Linux system becomes a process managed by the kernel.

Monitoring processes helps defenders identify:
- malicious execution
- privilege abuse
- persistence mechanisms
- resource abuse
- unauthorized network exposure

---

# Important Commands Used

## Process Enumeration

```bash
ps aux
```

Purpose:
- Displays all active processes on the system
- Provides visibility into process ownership and resource usage

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
- Displays live process activity
- Useful for monitoring CPU and memory spikes

---

## Interactive Process Investigation

```bash
htop
```

Purpose:
- Interactive process viewer
- Easier visualization of process hierarchies

Key capabilities:
- Tree view
- Process filtering
- Interactive termination
- Resource visualization

---

## Port and Service Visibility

```bash
ss -tulnp
```

Purpose:
- Displays listening ports and associated processes

Flags:
- `-t` → TCP
- `-u` → UDP
- `-l` → listening sockets
- `-n` → numeric output
- `-p` → process information

---

# Unexpected Root-Owned Processes

## Observation

Processes running as `root` possess elevated privileges and unrestricted system access.

Root-owned processes are not automatically malicious because many legitimate system services require administrative privileges.

Examples:
- `systemd`
- `sshd`
- `NetworkManager`

---

## Why Unexpected Root Processes Are Suspicious

Unknown or unusual root-owned processes may indicate:
- privilege escalation
- malware execution
- persistence mechanisms
- unauthorized administrative activity

Example concerns:
- random Python scripts running as root
- unknown binaries
- unfamiliar shell processes

---

## Detection Considerations

Potential indicators:
- unusual executable paths
- root-owned interpreters (`python`, `bash`, `perl`)
- unexpected startup behavior
- unauthorized scheduled tasks

Questions defenders ask:
- Why is this process running as root?
- Is the executable legitimate?
- Does the process belong to a known service?
- Was privilege escalation involved?

---

# Unknown Listening Ports

## Observation

A listening port indicates that a process is waiting for incoming network connections.

Every listening port increases the system’s attack surface.

Example:

```bash
python3 -m http.server 8080
```

This creates a process listening on port `8080`.

Verification:

```bash
ss -tulnp | grep 8080
```

---

## Why Unknown Ports Are Dangerous

Unexpected listening ports may indicate:
- unauthorized services
- malware backdoors
- remote access tools (RATs)
- exposed administration panels
- hidden command-and-control channels

Example suspicious ports:
- uncommon high-numbered ports
- externally exposed development servers
- unknown services listening on `0.0.0.0`

---

## Localhost vs External Exposure

### localhost (127.0.0.1)

Accessible only from the local machine.

Safer for:
- testing
- local development
- temporary services

---

### 0.0.0.0

Listens on all interfaces.

This exposes the service to:
- local network systems
- external devices
- potentially the internet

Security risk:
- unintended remote access
- expanded attack surface

---

# Strange Process Names

## Observation

Attackers often disguise malware using misleading process names.

The goal is to blend malicious activity into normal system behavior.

Examples:
- fake system process names
- typographical lookalikes
- misleading updater names

Example:

Legitimate:
```text
sshd
```

Potentially suspicious:
```text
ssdh
```

---

## Common Disguise Techniques

### Typo Imitation

Examples:
- `systemd-service`
- `chromee`
- `ssdh`

---

### Generic Names

Examples:
- `update`
- `service`
- `daemon`

---

### Fake System Processes

Examples:
- fake `kworker`
- fake `systemd`
- fake browser helpers

---

## Detection Considerations

Questions defenders ask:
- Is the process name legitimate?
- Is the executable path expected?
- Does the process parent make sense?
- Is the process signed or verified?

---

# High CPU Spikes

## Observation

High CPU usage may indicate:
- resource-intensive applications
- infinite loops
- crypto miners
- malware activity
- malfunctioning services

Monitoring tools:
- `top`
- `htop`

---

## Security Relevance

Sustained CPU spikes can indicate:
- cryptojacking malware
- unauthorized computation
- hidden malicious workloads

Example:
- a process constantly consuming 100% CPU

---

## Investigation Questions

- Which process owns the CPU spike?
- Which user launched the process?
- Is the behavior expected?
- Is network activity associated with it?

---

# High Memory Usage

## Observation

Processes consuming abnormal memory may indicate:
- memory leaks
- malicious payload loading
- browser overload
- unstable applications

---

## Security Concerns

Potential indicators:
- malware unpacking in memory
- hidden payload staging
- abnormal caching behavior

---

# Suspicious Parent-Child Process Chains

## Observation

Processes often spawn child processes.

This creates process hierarchies.

Example:

```text
systemd
 └── gnome-terminal
      └── bash
           └── python
```

This hierarchy is normal.

---

## Why Parent-Child Relationships Matter

Attackers often abuse legitimate applications to launch malicious payloads.

Example suspicious chain:

```text
chrome
 └── bash
      └── python
```

Question:
Why would a web browser launch a shell?

This may indicate:
- malicious scripts
- exploitation
- payload execution
- command injection

---

## Detection Importance

EDR systems heavily analyze:
- parent-child relationships
- process ancestry
- execution chains

These relationships provide behavioral context.

---

# Process Ownership

## Observation

Every process runs under a specific user account.

Commands used:

```bash
whoami
id
ps aux
```

---

## Security Importance

Process ownership helps determine:
- privilege level
- potential impact
- authorization level

Examples:
- root-owned malware is more dangerous
- unexpected service accounts may indicate abuse

---

# Process and Port Correlation

## Key Understanding

Processes own listening ports.

This relationship is important because defenders must identify:
- which process opened the port
- who owns the process
- why the service exists

Example:

```text
python3 -> port 8080
```

---

## Why Correlation Matters

Instead of asking:
> “Which ports are open?”

Defenders ask:
> “Which process is exposing this port?”

This provides actionable investigation context.

---

# Process Termination

## Controlled Termination

```bash
kill <PID>
```

Purpose:
- sends termination signal to process

---

## Forceful Termination

```bash
kill -9 <PID>
```

Purpose:
- immediately terminates process without graceful shutdown

Security considerations:
- may interrupt critical services
- may corrupt data
- may hide forensic evidence

---

# Behavioral Indicators of Suspicious Activity

Potential suspicious indicators include:
- unknown root-owned processes
- unexpected listening ports
- unusual CPU spikes
- fake process names
- suspicious parent-child chains
- hidden background services
- externally exposed local services
- unexpected interpreters running as root

---

# Key Lessons Learned

- Processes are behavioral evidence
- Every running program becomes a process
- Processes can expose network services
- Process ownership affects security impact
- Listening ports increase attack surface
- Parent-child chains provide execution context
- Behavioral analysis is essential in detection engineering

---

