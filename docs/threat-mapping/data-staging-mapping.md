# Threat Mapping – Data Staging and Compression

## Overview

This document maps observed behaviors from the Data Staging and Compression investigation to relevant MITRE ATT&CK techniques.

The purpose of threat mapping is to determine how the observed activity aligns with known adversary tradecraft and to provide behavioral context for detection engineering efforts.

The analysis is based on telemetry collected during the simulation and behavioral conclusions established during the investigation phase.

---

# Attack Flow Summary

The investigation reconstructed the following workflow:

```text
File Discovery
        ↓
Data Selection
        ↓
Local Staging
        ↓
Data Collection
        ↓
Archive Creation
        ↓
Archive Validation
```

This sequence closely resembles collection and preparation activities frequently performed prior to data exfiltration.

---

# ATT&CK Mapping Overview

| ATT&CK ID | Technique                          | Confidence |
| --------- | ---------------------------------- | ---------- |
| T1083     | File and Directory Discovery       | High       |
| T1005     | Data from Local System             | High       |
| T1074.001 | Data Staged: Local Data Staging    | High       |
| T1560.001 | Archive Collected Data via Utility | High       |

---

# T1083 – File and Directory Discovery

## ATT&CK Description

Adversaries may enumerate files and directories to identify information of interest for collection, credential theft, staging, or exfiltration.

---

## Observed Behavior

The operator repeatedly executed:

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

## Why This Maps

The purpose of these commands was not file management.

The commands were used to locate:

* Financial records
* Business documents
* Database exports
* Configuration files
* Project documentation

The activity demonstrates intentional identification of potentially valuable files.

This directly aligns with ATT&CK's definition of File and Directory Discovery.

---

## Supporting Telemetry

Observed indicators:

```text
find
find
find
find
find
find
find
```

Targeting multiple sensitive extensions.

---

## Detection Opportunities

Potential detection characteristics:

```text
Multiple find executions
+
Sensitive file extensions
+
Short execution window
```

---

# T1005 – Data from Local System

## ATT&CK Description

Adversaries may search local systems and collect files for later staging or exfiltration.

---

## Observed Behavior

Files were copied into a centralized location:

```text
Employee_Compensation.csv
Payroll_Data.csv
Budget_2026.xlsx
Q1_Financial_Report.xlsx

Meeting_Minutes.docx
Project_Roadmap.docx
Vendor_List.docx

database_backup.sql

nginx.conf
server_backup.conf
```

---

## Why This Maps

The operator actively gathered files from multiple locations and consolidated them into a single directory.

The collected material spans:

* Financial data
* Business documentation
* Technical information
* Operational records

The behavior reflects deliberate collection of locally available information.

---

## Supporting Telemetry

Observed pattern:

```text
cp
cp
cp
cp
cp
cp
```

All directed toward the same destination.

---

## Detection Opportunities

Potential indicators:

```text
Multiple collection operations
into
single destination
```

within a short timeframe.

---

# T1074.001 – Data Staged: Local Data Staging

## ATT&CK Description

Adversaries may stage collected data in a centralized location before transferring or exfiltrating it.

---

## Observed Behavior

Creation of:

```text
/tmp/archive_stage
```

followed by repeated file aggregation.

---

## Why This Maps

The directory was created specifically to serve as a collection point.

Evidence supporting staging behavior:

1. Directory creation occurred after discovery.
2. Directory creation occurred before collection.
3. All collected files were moved into the directory.
4. The directory became the source of the final archive.

This sequence precisely matches ATT&CK's definition of local data staging.

---

## Supporting Telemetry

Observed progression:

```text
mkdir /tmp/archive_stage
        ↓
cp
cp
cp
cp
cp
```

---

## Detection Opportunities

Indicators:

```text
Temporary directory creation
+
Burst file collection
+
Archive creation
```

---

# T1560.001 – Archive Collected Data via Utility

## ATT&CK Description

Adversaries may compress or archive collected data using native utilities before exfiltration.

---

## Observed Behavior

Archive creation:

```bash
tar -czf /tmp/company_backup.tar.gz /tmp/archive_stage
```

Observed supporting process:

```text
gzip
```

Archive verification:

```bash
tar -tzf /tmp/company_backup.tar.gz
```

---

## Why This Maps

The operator converted staged data into a compressed archive.

The archive:

```text
company_backup.tar.gz
```

contained previously collected material.

Compression reduced the number of files and created a portable package suitable for transfer.

This behavior directly aligns with ATT&CK's Archive Collected Data via Utility technique.

---

## Supporting Telemetry

Observed sequence:

```text
tar -czf
        ↓
gzip
        ↓
tar -tzf
```

---

## Detection Opportunities

Indicators:

```text
tar
+
gzip
+
temporary staging directory
```

or

```text
archive creation
followed by
archive validation
```

---

# Behavioral Correlation Across ATT&CK Techniques

The observed techniques were not isolated.

Each technique supported the next stage of the operation.

Observed progression:

```text
T1083
File Discovery
        ↓
T1005
Data Collection
        ↓
T1074.001
Local Staging
        ↓
T1560.001
Archive Creation
```

This progression represents a complete collection workflow.

---

# ATT&CK Tactic Mapping

| Tactic     | Technique |
| ---------- | --------- |
| Discovery  | T1083     |
| Collection | T1005     |
| Collection | T1074.001 |
| Collection | T1560.001 |

---

# Adversary Tradecraft Assessment

The observed workflow demonstrates a structured collection operation.

Key characteristics:

* Deliberate file targeting
* Selection of potentially valuable information
* Centralized staging
* Archive preparation
* Archive verification

The behavior is consistent with collection operations commonly observed before data movement or exfiltration phases.

No evidence of exfiltration was observed during the simulation; however, all preparatory behaviors required for exfiltration were present.

---

# Detection Engineering Implications

The strongest detection opportunity is not any individual ATT&CK technique.

The highest-fidelity detection emerges from the combination of techniques.

Observed behavioral chain:

```text
T1083
        ↓
T1005
        ↓
T1074.001
        ↓
T1560.001
```

Detection logic capable of correlating these activities will produce substantially higher confidence than monitoring individual commands such as:

```text
find
cp
tar
gzip
```

in isolation.

---

# Threat Mapping Conclusions

The investigation identified a complete ATT&CK-aligned collection workflow.

Observed activity maps with high confidence to:

* T1083 – File and Directory Discovery
* T1005 – Data from Local System
* T1074.001 – Data Staged: Local Data Staging
* T1560.001 – Archive Collected Data via Utility

The mapped behaviors collectively demonstrate a structured process of identifying, collecting, staging, and packaging information in preparation for potential exfiltration.

The strongest detection opportunities emerge from correlating the entire behavioral chain rather than focusing on any single utility execution.
