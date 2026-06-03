# Telemetry Analysis – Data Staging and Compression

## Overview

This document analyzes telemetry generated during the Data Staging and Compression simulation.

The objective of the simulation was to emulate an adversary locating potentially valuable files, staging them into a temporary directory, collecting them into a centralized location, and compressing the data into an archive for potential exfiltration.

Telemetry was collected from:

* auditd
* Sysmon for Linux

Analysis focuses on behavioral indicators, telemetry visibility, detection opportunities, and investigative value.

---

# Telemetry Sources

## auditd

auditd provided:

* Process execution telemetry
* Command-line arguments
* Working directory context
* Parent process identifiers
* User attribution
* Process identifiers

Important fields:

```text
type=EXECVE
type=SYSCALL

comm=
exe=
pid=
ppid=
uid=
cwd=
a0=
a1=
a2=
...
```

---

## Sysmon for Linux

Sysmon provided:

* Process creation events
* Process termination events
* Process GUIDs
* Command-line visibility
* Parent process metadata
* Hash information

Important fields:

```text
Event ID 1
Event ID 5

Image
CommandLine
ProcessId
ProcessGuid
ParentProcessId
ParentImage
Hashes
User
```

---

# Telemetry Analysis by Phase

---

# Phase 1 – Discovery Activity

## Observed Commands

```bash
find /home/bunny -name "*.csv"
find /home/bunny -name "*.xlsx"
find /home/bunny -name "*.docx"
find /home/bunny -name "*.conf"
find /home/bunny -name "*.txt"
find /home/bunny -name "*.sql"
find /home/bunny -name "*.md"
```

---

## Telemetry Observed

auditd:

```text
comm="find"
exe="/usr/bin/find"
ppid=11000
cwd="/home/bunny/Data-Staging-Lab"
```

Sysmon:

```text
Image=/usr/bin/find
CommandLine=find /home/bunny -name *.csv
ParentProcessId=11000
ParentImage=/usr/bin/bash
```

---

## Investigative Value

Discovery telemetry reveals:

* User intent
* Targeted file types
* Search scope
* Sequence of collection planning

The repeated use of find against multiple business-related file extensions demonstrates systematic data discovery rather than routine administration.

---

## Detection Opportunities

Indicators:

* Multiple find executions within a short timeframe
* Repeated targeting of document extensions
* Searches for database exports
* Searches for configuration files

Potential detection:

```text
Multiple find executions
+
Sensitive file extension targeting
+
Single interactive session
```

---

# Phase 2 – Staging Directory Creation

## Observed Commands

```bash
mkdir /tmp/archive_stage
ls -ld /tmp/archive_stage
```

---

## Telemetry Observed

auditd:

```text
comm="mkdir"
exe="/usr/bin/mkdir"
```

Sysmon:

```text
Image=/usr/lib/cargo/bin/coreutils/mkdir
CommandLine=mkdir /tmp/archive_stage
```

---

## Investigative Value

Creation of a temporary collection directory provides evidence that files are being centralized before archiving or exfiltration.

The location:

```text
/tmp/archive_stage
```

is particularly relevant because:

* temporary storage locations are commonly abused
* files become easier to package
* subsequent file activity can be correlated to the directory

---

## Detection Opportunities

Indicators:

```text
mkdir under /tmp
followed by
multiple file copy operations
```

Potential detection:

```text
Creation of temporary staging directory
+
Subsequent collection activity
```

---

# Phase 3 – Data Collection

## Observed Commands

```bash
cp Employee_Compensation.csv Payroll_Data.csv
cp Budget_2026.xlsx Q1_Financial_Report.xlsx
cp Meeting_Minutes.docx Project_Roadmap.docx Vendor_List.docx
cp database_backup.sql
cp nginx.conf server_backup.conf
cp architecture.md roadmap.md
```

---

## Telemetry Observed

auditd:

```text
comm="cp"
exe="/usr/bin/cp"
```

Sysmon:

```text
Image=/usr/bin/gnucp
CommandLine=cp <source files> /tmp/archive_stage
```

---

## Investigative Value

Collection telemetry provides direct evidence of:

* file aggregation
* target selection
* business data concentration

Collected data categories included:

| Category           | Examples                      |
| ------------------ | ----------------------------- |
| Financial Data     | Payroll, Budget, Compensation |
| Database Data      | SQL Backups                   |
| Documentation      | Roadmaps, Meeting Notes       |
| Configuration Data | nginx.conf                    |
| Operational Data   | Internal Notes                |

This demonstrates deliberate collection of high-value information.

---

## Detection Opportunities

Indicators:

```text
Multiple cp executions
Same destination directory
Short execution window
```

Potential detection:

```text
Burst file copy activity
into
temporary directory
```

This produces substantially fewer false positives than monitoring cp alone.

---

# Phase 4 – Archive Creation

## Observed Command

```bash
tar -czf /tmp/company_backup.tar.gz /tmp/archive_stage
```

---

## Telemetry Observed

auditd:

```text
comm="tar"
```

Sysmon:

```text
Image=/usr/bin/tar
CommandLine=tar -czf ...
```

Observed child process:

```text
gzip
```

---

## Investigative Value

Archive creation marks the transition from collection activity to preparation for exfiltration.

The archive:

```text
/tmp/company_backup.tar.gz
```

contains previously staged data.

The appearance of gzip immediately following tar provides strong evidence of archive compression.

---

## Detection Opportunities

Indicators:

```text
tar -czf
gzip
archive creation in /tmp
```

Potential detection:

```text
Compression utility
+
Temporary staging directory
+
Previously observed collection activity
```

---

# Phase 5 – Archive Validation

## Observed Commands

```bash
ls -lh /tmp/company_backup.tar.gz
tar -tzf /tmp/company_backup.tar.gz
```

---

## Telemetry Observed

Sysmon:

```text
Image=/usr/bin/tar
CommandLine=tar -tzf ...
```

Observed child process:

```text
gzip -d
```

---

## Investigative Value

Archive validation demonstrates operator verification before archive movement or exfiltration.

This behavior frequently occurs immediately before:

* network transfer
* cloud upload
* removable media staging

---

## Detection Opportunities

Indicators:

```text
Archive creation
followed by
archive inspection
```

Potential detection:

```text
tar -czf
followed by
tar -tzf
within same session
```

---

# Key Suspicious Telemetry

## Discovery Pattern

```text
find
find
find
find
find
find
find
```

Targeting:

* CSV
* XLSX
* DOCX
* SQL
* CONF
* TXT
* MD

Represents structured file discovery behavior.

---

## Temporary Staging Directory

```text
mkdir /tmp/archive_stage
```

Creation of a dedicated collection location.

---

## Burst Collection Activity

Multiple file-copy operations into a single destination.

Observed pattern:

```text
cp
cp
cp
cp
cp
cp
```

within a limited timeframe.

---

## Compression Activity

```text
tar -czf
```

followed by

```text
gzip
```

Strong indicator of archive preparation.

---

## Archive Verification

```text
tar -tzf
```

immediately after archive creation.

Demonstrates archive validation workflow.

---

# Detection Engineering Takeaways

## High Fidelity Detection Chain

The strongest behavioral chain observed was:

```text
find
        ↓
mkdir /tmp/archive_stage
        ↓
multiple cp operations
        ↓
tar -czf
        ↓
gzip
```

This sequence represents:

* Discovery
* Collection
* Local Staging
* Compression

within a single user session.

---

## Weak Detection Signals

The following alone are poor detections:

```text
find
cp
tar
gzip
```

Each can be legitimate administrative activity.

---

## Strong Detection Signals

The following combination significantly increases confidence:

```text
Multiple file discovery commands
+
Temporary staging directory
+
Burst collection activity
+
Archive creation
+
Compression
```

---

# Investigation Takeaways

The telemetry demonstrates a complete collection workflow consistent with ATT&CK collection and staging behaviors.

Evidence supports the following progression:

```text
Discovery
        ↓
Data Selection
        ↓
Local Staging
        ↓
Collection
        ↓
Compression
        ↓
Archive Validation
```

The archive creation activity appears intentional and organized, indicating preparation for a potential exfiltration stage rather than routine file management.

Relevant ATT&CK Techniques:

* T1083 – File and Directory Discovery
* T1005 – Data from Local System
* T1074.001 – Local Data Staging
* T1560.001 – Archive via Utility
