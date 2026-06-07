# Telemetry Collection Prerequisites

## Overview

The Detection Engineering Laboratory relies on telemetry-driven detection development. Every detection scenario within the repository was engineered from observable telemetry generated during controlled adversary simulations.

The objective of telemetry collection was not simply to record attacker activity but to provide sufficient visibility to:

* Reconstruct attacker behavior
* Perform investigations
* Map activity to ATT&CK techniques
* Engineer detections
* Validate Sigma rules
* Preserve forensic evidence

This document describes the telemetry sources used throughout the laboratory, environment preparation requirements, setup considerations, collection methodology, operational challenges, and lessons learned.

---

# Telemetry Collection Architecture

The laboratory utilized multiple telemetry sources to provide visibility across process execution, authentication activity, persistence mechanisms, file operations, and network communications.

```text
Attacker Activity
        ↓
Linux Host
        ↓
┌─────────────────────────────┐
│ Auditd                      │
│ Sysmon for Linux            │
│ Authentication Logs         │
│ Journalctl                  │
│ Network Packet Capture      │
│ Service Logs                │
│ File Metadata Collection    │
└─────────────────────────────┘
        ↓
Telemetry Analysis
        ↓
Investigation
        ↓
Detection Engineering
```

No single telemetry source was sufficient to explain attacker behavior. Correlation across multiple sources was required throughout the project.

---

# Laboratory Environment

## Host Platform

| Component                    | Purpose                                |
| ---------------------------- | -------------------------------------- |
| Ubuntu Linux VM              | Victim System                          |
| Ubuntu Linux VM              | Attacker System                        |
| VirtualBox Host-Only Network | Controlled Communication               |
| Python HTTP Server           | Payload Delivery                       |
| FTP Server                   | Alternate Payload Delivery             |
| Netcat Listener              | Reverse Shell and Beaconing Validation |

---

# Telemetry Source 1: Auditd

## Purpose

Auditd served as the primary telemetry source throughout the laboratory.

It was used to collect:

* Process execution
* Command-line activity
* Privilege escalation events
* Service management activity
* File access operations

---

## Environment Preparation

Install Auditd:

```bash
sudo apt install auditd audispd-plugins
```

Verify service status:

```bash
sudo systemctl status auditd
```

Create custom rules:

```bash
sudo auditctl -a always,exit -F arch=b64 -S execve
```

Example scenario-specific monitoring:

```bash
sudo auditctl -w /etc/crontab -p wa
sudo auditctl -w /etc/systemd/system -p wa
```

---

## Collection Method

Telemetry was collected using:

```bash
ausearch
```

and

```bash
aureport
```

Relevant events were preserved as raw artifacts within the repository.

---

## Value Provided

Auditd became the most important telemetry source because it captured:

* Executed commands
* Arguments
* User context
* Process creation activity

Most detections in the repository were derived directly from Auditd observations.

---

# Telemetry Source 2: Sysmon for Linux

## Purpose

Sysmon for Linux was used to supplement Auditd and improve process visibility.

Primary use cases:

* Process lineage
* Parent-child relationships
* Command execution context
* Event correlation

---

## Environment Preparation

Install Sysmon for Linux.

Deploy configuration file:

```bash
sysmon -i sysmonconfig.xml
```

Verify service:

```bash
sudo systemctl status sysmon
```

Verify event generation:

```bash
journalctl -u sysmon
```

---

## Collection Method

Events were extracted from:

```bash
journalctl
```

and preserved for investigation.

---

## Value Provided

Sysmon provided visibility that Auditd alone could not easily provide:

* Parent process relationships
* Process ancestry
* Execution chains

This became particularly valuable during:

* Reverse Shell Execution
* Suspicious Enumeration
* Beaconing
* Encoded Command Execution

---

# Telemetry Source 3: Authentication Logs

## Purpose

Authentication logs provided visibility into:

* SSH authentication activity
* Failed login attempts
* Sudo activity
* Privilege escalation events

---

## Environment Preparation

Authentication logging is enabled by default on Ubuntu systems.

Primary log source:

```bash
/var/log/auth.log
```

Monitoring:

```bash
tail -f /var/log/auth.log
```

---

## Collection Method

Relevant entries were extracted and preserved during:

* SSH Brute Force
* Sudo Abuse
* Log Tampering

---

## Value Provided

Authentication logs provided behavioral context that process telemetry alone could not provide.

---

# Telemetry Source 4: Journalctl

## Purpose

Journalctl was used to monitor:

* Systemd activity
* Service creation
* Service execution
* Daemon behavior

---

## Environment Preparation

Verify journal service:

```bash
sudo systemctl status systemd-journald
```

Query logs:

```bash
journalctl
```

Monitor live:

```bash
journalctl -f
```

---

## Collection Method

Logs were collected during:

* Systemd Service Persistence
* Service enablement
* Daemon reload activity

---

## Value Provided

Journalctl provided operational visibility into service-based persistence mechanisms.

---

# Telemetry Source 5: Network Packet Capture

## Purpose

Packet captures were used to validate:

* Reverse shell activity
* Beaconing
* Payload downloads
* HTTP communications
* FTP transfers

---

## Environment Preparation

Install tcpdump:

```bash
sudo apt install tcpdump
```

Identify active interface:

```bash
ip addr
```

Capture traffic:

```bash
sudo tcpdump -i <interface>
```

Example:

```bash
sudo tcpdump -i enp0s3
```

---

## Collection Method

Packet captures were preserved as:

```text
*.pcap
```

files and supporting analysis logs.

---

## Value Provided

Packet captures provided validation of network-based attacker behavior.

This telemetry was critical for:

* Reverse Shell Execution
* Beaconing
* Suspicious File Download Activity

---

# Telemetry Source 6: HTTP Server Logs

## Purpose

HTTP logs validated payload delivery operations.

---

## Environment Preparation

Launch server:

```bash
python3 -m http.server 8000
```

Monitor requests:

```bash
tail -f access.log
```

or terminal output.

---

## Collection Method

Logs were preserved alongside network captures.

---

## Value Provided

Provided confirmation of:

* Payload retrieval
* Callback activity
* Download timing

---

# Telemetry Source 7: FTP Server Logs

## Purpose

Used to validate alternate ingress tool transfer techniques.

---

## Environment Preparation

Install FTP server.

Verify listener:

```bash
ss -tulpn
```

Verify downloads:

```bash
ftp
```

---

## Collection Method

Logs were preserved alongside packet captures and process telemetry.

---

## Value Provided

Allowed validation of multiple payload delivery methods.

---

# Telemetry Source 8: File Metadata Collection

## Purpose

File metadata collection supported:

* Permission change tracking
* Persistence analysis
* Payload execution investigations

---

## Collection Method

Commands used:

```bash
ls -la
```

```bash
stat
```

```bash
file
```

```bash
sha256sum
```

---

## Value Provided

Provided evidence of:

* Payload staging
* chmod activity
* Persistence artifacts
* Archive creation

---

# Telemetry Collection Challenges

## Challenge 1: Telemetry Gaps

Some activities generated limited visibility from a single source.

Examples:

* File downloads
* Permission modifications
* Service execution

These often required multiple telemetry sources for full reconstruction.

---

## Challenge 2: Correlation Complexity

A single attack frequently produced:

* Auditd events
* Sysmon events
* Network artifacts
* Log entries

Correlating these sources required timeline reconstruction and process lineage analysis.

---

## Challenge 3: Noise vs Signal

Many attacker actions closely resembled legitimate administration.

Examples:

* wget
* curl
* tar
* sudo
* systemctl

Behavioral context was necessary to distinguish suspicious activity.

---

## Challenge 4: Environment Consistency

Detection validation required:

* Repeatable simulations
* Consistent logging
* Stable network configurations
* Reliable telemetry generation

Minor environmental changes could impact collected evidence.

---

## Challenge 5: Validation Fidelity

Successful attack execution does not guarantee useful telemetry.

Several simulations required repeated execution to ensure:

* Logging was functioning
* Events were captured
* Detection logic could be validated

---

# Lessons Learned

Throughout the laboratory, several key observations emerged.

## Multiple Sources Are Essential

No single telemetry source provided complete visibility.

Reliable investigations required telemetry correlation.

---

## Process Visibility Is Foundational

Most attacker techniques ultimately resulted in process execution.

Process telemetry became the foundation of nearly every detection.

---

## Network Telemetry Provides Context

Host telemetry explains what happened.

Network telemetry explains where communications occurred.

Both are necessary for complete investigations.

---

## Detection Quality Depends on Telemetry Quality

Poor telemetry results in weak detections.

Comprehensive telemetry enables behavioral detections and reduces reliance on fragile indicators.

---

# Conclusion

The Detection Engineering Laboratory was built upon a telemetry-first philosophy in which every detection originated from observable system activity.

The laboratory leveraged Auditd, Sysmon for Linux, authentication logs, Journalctl, packet captures, service logs, and file metadata collection to create a comprehensive visibility framework for Linux adversary simulations.

The collection and correlation of telemetry enabled:

* Adversary behavior reconstruction
* ATT&CK-aligned threat mapping
* Investigation-driven detection development
* Sigma rule engineering
* Validation of detection effectiveness

The experience reinforced a fundamental principle of detection engineering:

Effective detections are not created from assumptions; they are engineered from telemetry.
