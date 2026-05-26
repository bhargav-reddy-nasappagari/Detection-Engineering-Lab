# Rogue Python Listener Detection Notes

## Objective

This document contains detection engineering observations and behavioral detection logic derived from the simulated rogue Python HTTP service scenario.

The purpose of this analysis is to:
- identify suspicious behavioral indicators
- understand relevant telemetry sources
- formulate detection opportunities
- correlate process and network activity
- establish foundational detection engineering reasoning

The focus is on:
- behavioral detection logic
- telemetry correlation
- attack surface analysis

rather than vendor-specific rule syntax.

---

# Scenario Overview

A Python HTTP server was manually launched using:

```bash
python3 -m http.server 8080
```

The service:
- created a Python process
- opened TCP port `8080`
- exposed a listener on `0.0.0.0`
- operated under the user account `bunny`
- was launched interactively from `bash`

Observed hierarchy:

```text
bash → python3
```

Observed listener:

```text
0.0.0.0:8080
```

---

# Detection Goal

The primary objective is to detect:
- unauthorized user-launched web services
- suspicious Python-based listeners
- externally exposed development services
- interactive shell-launched network listeners

---

# Behavioral Indicators

## Suspicious Python Listener

### Observed Behavior

A Python interpreter opened a listening TCP port.

This is notable because:
- Python is commonly used for scripting and development
- Python can rapidly create unauthorized services
- attackers frequently use Python for lightweight payload hosting and command infrastructure

---

## Detection Logic

Potential detection conditions:
- `python3` process creates listening socket
- Python process binds to high-numbered port
- Python process exposes external interface
- Python process launched interactively

---

# External Exposure Detection

## Observed Behavior

The listener was bound to:

```text
0.0.0.0
```

This exposed the service across all network interfaces.

---

## Why This Matters

Binding to `0.0.0.0`:
- increases attack surface
- allows remote connections
- may unintentionally expose sensitive data
- may indicate unauthorized service deployment

---

## Detection Opportunities

Potential detections:
- listeners bound to `0.0.0.0`
- unexpected externally accessible services
- non-standard user-space web servers

---

# High-Numbered Port Detection

## Observed Port

```text
8080
```

Port `8080` is commonly associated with:
- development environments
- temporary web services
- testing frameworks

---

## Security Relevance

Unexpected high-numbered listeners may indicate:
- unauthorized development services
- hidden administration panels
- malware listeners
- staging servers

---

## Detection Opportunities

Potential monitoring logic:
- monitor uncommon listening ports
- baseline approved services
- alert on unexpected HTTP listeners

---

# Interactive Shell-Based Execution

## Observed Process Chain

```text
bash → python3
```

---

## Security Relevance

This indicates:
- manual execution
- user-initiated service creation
- non-daemonized process behavior

Interactive shell-launched listeners may be suspicious in:
- enterprise endpoints
- production servers
- restricted environments

---

## Detection Opportunities

Potential behavioral logic:
- shell spawning network listeners
- bash launching Python HTTP services
- interactive user sessions creating exposed services

---

# Process-to-Port Correlation

## Key Observation

The Python process directly owned the listening port.

Observed relationship:

```text
python3 (PID 4978)
        ↓
TCP listener on 8080
```

---

## Detection Importance

Process-to-port correlation allows defenders to:
- identify responsible executables
- determine ownership
- analyze process ancestry
- assess legitimacy

This correlation is foundational for:
- EDR systems
- SIEM detections
- threat hunting workflows

---

# Resource Utilization Analysis

## Observed Behavior

The service:
- consumed low CPU resources
- used approximately 0.5% - 0.7% memory
- remained mostly idle

---

## Detection Insight

Low-resource services may still be dangerous.

Many malicious listeners:
- remain dormant
- avoid resource spikes
- maintain stealth through inactivity

Defenders should avoid relying only on:
- high CPU
- abnormal memory usage

Behavioral context matters more.

---

# Telemetry Sources

Relevant telemetry for this detection scenario includes:

| Telemetry Source | Purpose |
|---|---|
| Process creation logs | Identify Python execution |
| Network socket telemetry | Detect listening ports |
| Parent-child process data | Identify shell-based launches |
| User context | Determine ownership |
| Port exposure data | Assess attack surface |

---

# Potential False Positives

Legitimate scenarios may include:
- developers running temporary HTTP servers
- internal testing environments
- educational lab systems
- local file-sharing workflows

Detection logic should therefore consider:
- environment context
- approved user roles
- expected development activity
- exposure restrictions

---

# Detection Recommendations

## Recommended Monitoring Areas

### Python Network Activity
Monitor:
- Python processes opening listening ports
- unexpected Python web servers

---

### External Exposure
Alert on:
- listeners bound to `0.0.0.0`
- externally exposed development services

---

### Interactive Service Creation
Monitor:
- shell-launched listeners
- user-space web servers
- temporary unauthorized services

---

### High-Numbered Listeners
Investigate:
- uncommon listening ports
- unexpected HTTP services
- unauthorized internal web applications

---

# Threat Hunting Opportunities

Potential hunting queries may focus on:
- Python interpreters with listening sockets
- newly created listeners
- user-launched HTTP services
- unexpected externally accessible ports
- shell-to-network execution chains

---

# Security Impact Assessment

Potential risks associated with this behavior:
- accidental file exposure
- unauthorized remote access
- hidden attacker infrastructure
- internal reconnaissance staging
- malware-hosted web services

The risk level increases if:
- the listener persists
- the service is externally reachable
- unknown users launch the process
- suspicious network traffic is observed

---

# Key Detection Engineering Lessons

- Process behavior provides critical security context
- Network exposure must be correlated with ownership
- Python listeners may represent unauthorized services
- Exposure on `0.0.0.0` increases attack surface
- Parent-child relationships strengthen behavioral analysis
- Low-resource processes can still be malicious
- Behavioral detections are stronger than static signatures

---

# Future Detection Enhancements

Planned future improvements:
- Sigma rule development
- automated listener monitoring
- process baseline comparison
- persistence detection
- network anomaly detection
- process ancestry analysis
- SIEM correlation logic
