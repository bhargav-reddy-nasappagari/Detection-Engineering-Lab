# Rogue HTTP Service Investigation Report

## Incident Summary

A Python-based HTTP server was observed running on the Linux system and exposing TCP port `8080`.

The service was launched manually through an interactive shell session using Python’s built-in HTTP server module.

The investigation focused on:
- identifying the responsible process
- analyzing network exposure
- evaluating process behavior
- assessing potential security risks
- identifying possible detection opportunities

---

# Investigation Scope

The investigation involved:
- process enumeration
- process-to-port correlation
- resource monitoring
- parent-child process analysis
- exposure evaluation

Commands used during investigation:

```bash
ps aux | grep http.server
ss -tulnp | grep 8080
htop
```

---

# Observed Activity

## Service Creation

The following command was executed:

```bash
python3 -m http.server 8080
```

This created:
- a Python process
- a TCP listener
- an active HTTP service

The service exposed files from the current working directory over HTTP.

---

# Process Analysis

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

Observed hierarchy:

```text
bash → python3
```

This indicates:
- manual interactive execution
- shell-based process launch
- non-system-managed service creation

The process was not observed as part of a standard system daemon or service framework.

---

## Behavioral Characteristics

Observed process behavior:
- lightweight execution
- minimal CPU usage
- low memory consumption
- persistent listening state
- active network exposure

The process remained idle while waiting for incoming HTTP connections.

---

# Network Analysis

## Listening Port

Observed listener:

```text
TCP 0.0.0.0:8080
```

---

## Exposure Level

The service was bound to:

```text
0.0.0.0
```

Meaning:
- the service listened on all network interfaces
- connections were not restricted to localhost
- external systems may potentially connect

This significantly increases exposure compared to:

```text
127.0.0.1
```

which limits access to the local machine.

---

## Security Implications

Potential risks associated with external exposure include:
- unauthorized file access
- unintended remote access
- information disclosure
- rogue internal services
- exploitation opportunities

If firewall restrictions are absent, systems on the same network may access the service.

---

# Resource Analysis

## CPU Usage

Observed CPU consumption:
- minimal
- occasional small spikes

No significant resource abuse was observed.

---

## Memory Usage

Observed memory usage:
- approximately 0.5% - 0.7%

This behavior is consistent with lightweight Python HTTP services.

---

# Detection-Relevant Indicators

The following behaviors may be relevant from a detection engineering perspective:

| Indicator | Relevance |
|---|---|
| Python process exposing network service | uncommon in hardened systems |
| High-numbered listening port | possible unauthorized service |
| External exposure on 0.0.0.0 | increased attack surface |
| Interactive shell execution | manually launched process |
| User-space listener | potential rogue service |

---

# Threat Assessment

## Potential Risks

Although intentionally simulated in this lab environment, similar behavior in production environments could indicate:
- unauthorized developer services
- accidental exposure
- malware-controlled listeners
- remote access tools
- hidden administrative interfaces

The behavior becomes more suspicious if:
- the service is unexpected
- the user context is abnormal
- the process persists after reboot
- external communication occurs

---

# Analyst Observations

Key observations from the investigation:
- the process was launched interactively through bash
- the listener exposed all interfaces instead of localhost-only access
- the service consumed low system resources
- the process maintained a stable listening state
- process-to-port correlation successfully identified ownership

The combination of:
- Python execution
- externally exposed listener
- user-launched service

represents behavior that defenders may want to monitor in enterprise environments.

---

# Recommended Detection Opportunities

Potential detection logic ideas include:
- detection of Python processes opening listening ports
- monitoring non-standard HTTP listeners
- detection of listeners bound to 0.0.0.0
- alerting on user-space web servers
- monitoring shell-launched network services
- correlation between process creation and new listening ports

---

# Investigation Outcome

The investigation successfully demonstrated:
- process enumeration techniques
- listener identification
- process-to-port correlation
- exposure assessment
- behavioral analysis methodology

This scenario provided practical understanding of how:
- network services are exposed
- processes create attack surface
- defenders investigate suspicious listeners
- telemetry supports behavioral detection engineering
