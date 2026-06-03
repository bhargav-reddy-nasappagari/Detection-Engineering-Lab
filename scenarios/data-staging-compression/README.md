# Data Staging & Compression

## Overview

This scenario simulates an adversary collecting locally accessible files, staging them into a temporary directory, and compressing the collected data into an archive in preparation for exfiltration.

The simulation focuses on attacker behavior commonly observed prior to data theft operations and generates telemetry suitable for detection engineering, behavioral analysis, ATT&CK mapping, Sigma rule development, and validation.

The exercise intentionally stops before exfiltration to maintain focus on collection, staging, and archival activities.

---

# ATT&CK Mapping

## Primary Techniques

| Technique | Name                                        |
| --------- | ------------------------------------------- |
| T1005     | Data from Local System                      |
| T1074     | Data Staged                                 |
| T1560.001 | Archive Collected Data: Archive via Utility |

## Supporting Techniques

| Technique | Name                         |
| --------- | ---------------------------- |
| T1083     | File and Directory Discovery |
| T1033     | System Owner/User Discovery  |

---

# Scenario Objective

Simulate a compromised Linux user account performing:

1. File discovery
2. Data collection
3. Temporary staging
4. Archive creation

The goal is to observe how these activities manifest within Linux process telemetry and determine whether the behavior can be reliably detected.

---

# Lab Environment

## Simulated Data

The environment contained multiple business-like files distributed across several directories.

```text
/home/bunny/Documents/
/home/bunny/Finance/
/home/bunny/Backups/
/home/bunny/Projects/
```

Example files:

```text
Payroll_Data.csv
Employee_Compensation.csv
Q1_Financial_Report.xlsx
Project_Roadmap.docx
Internal_Notes.txt
server_backup.conf
database_backup.sql
architecture.md
```

These files represented potential collection targets for the simulated adversary.

---

# Simulation Execution

## Phase 1 – Discovery

The adversary searched the filesystem for potentially valuable files.

Example commands:

```bash
find /home/bunny -name "*.csv"

find /home/bunny -name "*.xlsx"

find /home/bunny -name "*.docx"
```

Purpose:

```text
Identify sensitive or valuable documents
for later collection.
```

Observed Process Activity:

```text
bash
 └── find
```

---

## Phase 2 – Data Staging

A temporary staging directory was created.

```bash
mkdir /tmp/archive_stage
```

Purpose:

```text
Centralize collected files
before compression.
```

Observed Process Activity:

```text
bash
 └── mkdir
```

---

## Phase 3 – File Collection

Files were copied into the staging directory.

```bash
cp ~/Finance/*.csv /tmp/archive_stage/

cp ~/Documents/*.txt /tmp/archive_stage/

cp ~/Backups/*.conf /tmp/archive_stage/
```

Purpose:

```text
Aggregate files into
a single collection location.
```

Observed Process Activity:

```text
bash
 ├── cp
 ├── cp
 └── cp
```

---

## Phase 4 – Compression

The collected files were archived using tar.

```bash
tar -czf /tmp/company_backup.tar.gz /tmp/archive_stage
```

Archive verification:

```bash
tar -tzf /tmp/company_backup.tar.gz
```

Purpose:

```text
Compress collected data
into a transferable archive.
```

Observed Process Activity:

```text
bash
 └── tar
```

---

# Telemetry Collection

## Telemetry Sources

### auditd

Process execution telemetry was collected using execve monitoring.

Captured events included:

```text
find
mkdir
cp
tar
```

### Sysmon for Linux

Process creation events were collected to reconstruct execution chains and parent-child relationships.

### Process Snapshots

Process hierarchy and execution lineage were preserved using:

```bash
ps -ef

pstree -ap
```

---

# Telemetry Analysis

Analysis of collected telemetry revealed a structured workflow consistent with adversary collection behavior.

## Reconstructed Timeline

```text
find
find
find
    ↓
mkdir
    ↓
cp
cp
cp
    ↓
tar
    ↓
tar
```

## Reconstructed Process Lineage

```text
bash
 ├── find
 ├── find
 ├── find
 ├── mkdir
 ├── cp
 ├── cp
 ├── cp
 ├── tar
 └── tar
```

---

# Investigation Findings

## What Happened?

A user performed targeted file discovery, aggregated selected files into a temporary directory, and compressed the staged data into a tar archive.

## Was Data Staging Observed?

Yes.

The creation of:

```text
/tmp/archive_stage
```

followed by multiple file copy operations demonstrated explicit staging behavior.

## Was Data Compression Observed?

Yes.

The following archive was created:

```text
/tmp/company_backup.tar.gz
```

using:

```bash
tar -czf
```

## Was Exfiltration Observed?

No.

No outbound transfer activity occurred.

The simulation concluded immediately after archive verification.

---

# Behavioral Analysis

The observed activity aligns closely with common attacker preparation workflows performed before exfiltration.

Observed behavioral sequence:

```text
Discovery
    ↓
Collection
    ↓
Staging
    ↓
Compression
```

Mapped process sequence:

```text
find
    ↓
mkdir
    ↓
cp
    ↓
tar
```

This sequence represents a practical implementation of:

```text
T1005
T1074
T1560.001
```

within a Linux environment.

---

# Detection Logic Engineering

## Detection Objective

Identify suspicious archival activity associated with temporary staging locations.

## Analytic Logic

A user:

```text
Discovers files
    ↓
Stages files
    ↓
Creates archive
```

using Linux archive utilities.

## Key Indicators

### Discovery Activity

```text
find
```

### Staging Activity

```text
mkdir
cp
mv
```

### Compression Activity

```text
tar
zip
gzip
7z
xz
```

### Suspicious Locations

```text
/tmp/
/var/tmp/
/dev/shm/
```

---

# Detection Strategy

## Low Fidelity

Archive utility execution.

```text
tar
zip
gzip
```

Risk:

High false positives.

---

## Medium Fidelity

Archive creation within temporary directories.

```text
/tmp/
/var/tmp/
/dev/shm/
```

Risk:

Moderate false positives.

---

## High Fidelity

Behavior sequence:

```text
Discovery
    ↓
Collection
    ↓
Archive Creation
```

This represents the primary behavioral analytic used in the investigation.

---

# Sigma Rule

## Detection Goal

Identify archive creation activity occurring within temporary filesystem locations.

```yaml
title: Suspicious Archive Creation In Temporary Directory

logsource:
  product: linux
  category: process_creation

detection:

  selection_image:
    Image|endswith:
      - '/tar'

  selection_args:
    CommandLine|contains:
      - '-czf'
      - '.tar.gz'

  selection_location:
    CommandLine|contains:
      - '/tmp/'
      - '/var/tmp/'
      - '/dev/shm/'

  condition: all of selection_*

falsepositives:
  - Administrative backups
  - Temporary packaging operations

level: medium
```

---

# Validation

## Validation Objective

Verify that the Sigma rule successfully identifies archive creation generated during the simulation.

## Validation Method

The simulation was executed a second time using identical commands.

Observed command:

```bash
tar -czf /tmp/company_backup.tar.gz /tmp/archive_stage
```

Expected result:

```text
Detection Triggered
```

## Validation Outcome

| Validation Check     | Result |
| -------------------- | ------ |
| Discovery Captured   | PASS   |
| Staging Captured     | PASS   |
| Compression Captured | PASS   |
| Archive Created      | PASS   |
| Sigma Rule Triggered | PASS   |

---

# Detection Coverage

| Behavior             | Covered       |
| -------------------- | ------------- |
| File Discovery       | Investigation |
| Data Collection      | Investigation |
| Data Staging         | Investigation |
| Archive Creation     | Detection     |
| Archive Verification | Investigation |

---

# Conclusion

The simulation successfully reproduced a realistic data staging and compression workflow frequently observed prior to data exfiltration activities.

Telemetry captured through auditd and process monitoring provided sufficient visibility to reconstruct the complete attack sequence.

Behavioral analysis identified a clear progression from discovery to staging and ultimately archival, resulting in ATT&CK-aligned detection content.

The resulting Sigma rule reliably identified suspicious archive creation within temporary directories and was successfully validated against the simulated attack activity.
