# Investigation Report: Rogue HTTP Server (T1105 – Ingress Tool Transfer)

## Investigation Overview

This investigation analyzes telemetry generated during the Rogue HTTP Server simulation and focuses on identifying suspicious behaviors, attacker tradecraft, and detection opportunities.

The objective of this phase is not to validate individual events but to examine how those events combine to form recognizable adversary behavior. By reconstructing execution flow and evaluating process relationships, investigators can determine whether the observed activity resembles legitimate administrative behavior or potential malicious activity.

The investigation assumes a post-compromise scenario where an attacker already possesses command execution on the host and uses a temporary HTTP server to stage and transfer additional tooling.

---

# Investigative Questions

The investigation seeks to answer the following questions:

1. Was a temporary staging service established?
2. Was a tool transferred onto the system?
3. Was the transferred tool prepared for execution?
4. Was the tool executed?
5. Did the tool perform follow-on activity?
6. Does the overall sequence resemble known attacker tradecraft?
7. Which behavioral patterns should be converted into detections?

---

# Behavioral Reconstruction

The observed activity can be reconstructed as:

```text
bash
    │
    ├── python3 -m http.server 8000
    │
    ├── curl http://127.0.0.1:8000/updater.sh
    │
    ├── chmod +x /tmp/updater.sh
    │
    └── /bin/bash /tmp/updater.sh
             │
             ├── whoami
             ├── id
             └── hostname
```

The process sequence demonstrates a complete lifecycle of staging, transfer, execution, and reconnaissance.

While each command may appear benign in isolation, the sequence as a whole presents a significantly different investigative picture.

---

# Suspicious Activity Analysis

## Finding 1: Temporary HTTP Service Creation

### Observed Behavior

A Python HTTP server was launched using:

```bash
python3 -m http.server 8000
```

### Why It Is Suspicious

Python is primarily used for scripting and application development.

The use of Python to expose a temporary web service is relatively uncommon on production Linux systems and frequently appears during:

* Adversary staging operations
* Red team exercises
* Malware delivery
* Tool hosting
* Data exfiltration staging

The server was not launched as a system service and did not appear to be associated with a legitimate application stack.

### Attacker Tradecraft Assessment

This behavior aligns with a common attacker technique of establishing lightweight infrastructure using native tools already present on the host.

### Investigation Conclusion

The HTTP server itself is not malicious.

However, it represents the first indication that the host is being used to host attacker-controlled content.

---

## Finding 2: Payload Retrieval Using Curl

### Observed Behavior

The HTTP server was followed by:

```bash
curl http://127.0.0.1:8000/updater.sh -o /tmp/updater.sh
```

### Why It Is Suspicious

The command demonstrates intentional retrieval of executable content.

Several elements increase investigative concern:

* Download utility usage
* Script retrieval
* Destination within `/tmp`
* Immediate follow-on activity

Legitimate downloads often terminate after retrieval.

In this case, the download became part of a larger execution chain.

### Attacker Tradecraft Assessment

Downloading additional tooling after obtaining shell access is one of the most common post-compromise activities observed during real intrusions.

### Investigation Conclusion

This activity strongly resembles ingress tool transfer behavior.

---

## Finding 3: Tool Staging in Temporary Storage

### Observed Behavior

The payload was written to:

```text
/tmp/updater.sh
```

### Why It Is Suspicious

Temporary directories are commonly abused because they:

* Are writable by users
* Require minimal privileges
* Frequently evade administrator attention
* Are regularly used for attacker staging

Investigators routinely encounter malware, droppers, scripts, and persistence mechanisms operating from:

```text
/tmp
/var/tmp
/dev/shm
```

### Attacker Tradecraft Assessment

This behavior is highly consistent with post-compromise staging activity.

### Investigation Conclusion

The storage location increases the likelihood that the file represents attacker-controlled tooling rather than a legitimate administrative script.

---

## Finding 4: Permission Modification Prior to Execution

### Observed Behavior

The downloaded file was modified using:

```bash
chmod +x /tmp/updater.sh
```

### Why It Is Suspicious

Permission modification immediately following a download is frequently observed in attacker workflows.

The sequence indicates preparation for execution.

The file was not merely downloaded.

The file was intentionally prepared to run.

### Attacker Tradecraft Assessment

This behavior appears in:

* Malware deployment
* Remote script execution
* Payload staging
* Red team operations

### Investigation Conclusion

The permission change significantly increases confidence that execution is imminent.

---

## Finding 5: Execution of Recently Downloaded Content

### Observed Behavior

The payload was executed:

```bash
/bin/bash /tmp/updater.sh
```

### Why It Is Suspicious

The executed file satisfies multiple investigative conditions:

* Recently downloaded
* Stored in a temporary directory
* Permission modified shortly beforehand
* Executed from the same interactive session

These characteristics collectively form a strong malicious pattern.

### Attacker Tradecraft Assessment

Execution of freshly staged tooling is one of the most reliable indicators of post-compromise activity.

### Investigation Conclusion

This represents the strongest suspicious event observed during the simulation.

---

## Finding 6: Immediate Discovery Activity

### Observed Behavior

The script executed:

```bash
whoami
id
hostname
```

### Why It Is Suspicious

These commands are commonly used to answer:

* Which user am I?
* What privileges do I have?
* Which host am I operating on?

Such questions are frequently asked immediately after gaining access to a system.

### Attacker Tradecraft Assessment

The behavior aligns closely with attacker reconnaissance and environmental discovery activity.

### Investigation Conclusion

The payload demonstrates characteristics consistent with post-compromise host discovery.

---

# Behavioral Correlation Analysis

No single process observed during the simulation is inherently malicious.

The investigation becomes meaningful only when events are correlated.

The following sequence was observed:

```text
HTTP Server Creation
        ↓
Payload Download
        ↓
Temporary File Creation
        ↓
Permission Modification
        ↓
Payload Execution
        ↓
Discovery Commands
```

Each stage increases investigative confidence.

Viewed individually:

| Event               | Suspicious? |
| ------------------- | ----------- |
| python3 http.server | Low         |
| curl download       | Low         |
| file in /tmp        | Medium      |
| chmod +x            | Medium      |
| execution           | High        |
| discovery activity  | High        |

Viewed together:

```text
Overall Confidence: High
```

The complete chain strongly resembles attacker behavior.

---

# Could This Represent a Real Attack?

## Assessment

Yes.

The observed sequence closely resembles activity seen during:

* Initial post-exploitation operations
* Red team exercises
* Malware staging
* Tool transfer operations
* Interactive attacker sessions

The workflow demonstrates a realistic attack progression:

```text
Obtain Access
        ↓
Transfer Tool
        ↓
Stage Tool
        ↓
Execute Tool
        ↓
Perform Discovery
```

This progression maps directly to established ATT&CK techniques.

---

# Behavioral Findings

## Behavioral Finding 1

### Temporary HTTP Server Used for Tool Staging

Pattern:

```text
python3 -m http.server
```

Detection Value:

High

---

## Behavioral Finding 2

### Download Utility Retrieves Executable Content

Pattern:

```text
curl
        ↓
script file
```

Detection Value:

High

---

## Behavioral Finding 3

### Executable Created in Temporary Directory

Pattern:

```text
/tmp/*.sh
```

Detection Value:

High

---

## Behavioral Finding 4

### Download → Permission Change → Execute

Pattern:

```text
download
        ↓
chmod
        ↓
execution
```

Detection Value:

Very High

This is the strongest behavioral finding identified during the investigation.

---

## Behavioral Finding 5

### Execution of Newly Staged Tool

Pattern:

```text
temporary directory
        ↓
shell execution
```

Detection Value:

Very High

---

## Behavioral Finding 6

### Tool Execution Immediately Followed by Discovery Activity

Pattern:

```text
execution
        ↓
whoami
id
hostname
```

Detection Value:

High

---

# Detection Engineering Recommendations

Detection development should prioritize behavioral chains rather than individual commands.

The highest-value detection candidate identified during the investigation is:

```text
curl/wget
        ↓
file created in temporary directory
        ↓
chmod +x
        ↓
execution
```

This sequence is significantly more resilient than simple command-based detections and more closely reflects attacker behavior.

Secondary detections should focus on:

* Python HTTP server creation
* Execution from temporary directories
* Newly downloaded script execution
* Discovery commands immediately following payload execution

---

# Investigation Conclusion

The observed activity represents a realistic post-compromise ingress tool transfer workflow. The telemetry demonstrates the establishment of a temporary staging service, transfer of attacker-controlled tooling, preparation of the payload for execution, execution of the transferred content, and subsequent host discovery activity.

While no individual process is conclusively malicious in isolation, the correlated behavioral sequence closely matches known attacker tradecraft and provides multiple high-confidence detection opportunities for subsequent detection engineering efforts.
