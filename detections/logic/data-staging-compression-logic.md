# Detection Logic Engineering – Data Staging and Compression

## Overview

This document defines the detection strategy and behavioral analytics for identifying Data Staging and Compression activity on Linux systems.

The detection logic is derived from:

* Telemetry Analysis
* Investigation Findings
* ATT&CK Threat Mapping

The objective is to detect adversarial collection workflows rather than individual command executions.

---

# Detection Objective

Identify hosts where a user performs:

1. Discovery of potentially valuable files
2. Local staging of collected data
3. Aggregation of files into a temporary location
4. Compression of staged content into an archive

These activities collectively indicate preparation for data movement or exfiltration.

---

# Detection Philosophy

## What We Are NOT Detecting

The following commands alone are poor indicators:

```text
find
cp
mkdir
tar
gzip
```

All are commonly used by administrators, developers, backup software, and automation platforms.

Alerting on these commands independently would generate excessive false positives.

---

## What We ARE Detecting

The detection focuses on the relationship between activities.

Observed attack workflow:

```text
Discovery
        ↓
Temporary Staging
        ↓
Collection
        ↓
Archive Creation
```

The detection seeks to identify this sequence within a single user session.

---

# Behavioral Detection Model

## Phase 1 – Discovery Detection

### Objective

Identify attempts to locate potentially valuable files.

### Behavioral Indicators

Repeated execution of:

```text
find
```

targeting:

```text
*.csv
*.xlsx
*.docx
*.sql
*.conf
*.txt
*.md
```

within a short period.

---

### Detection Reasoning

A single search may be benign.

Multiple searches targeting business and technical data categories indicate intentional discovery activity.

---

### Detection Signal

```text
find execution
+
multiple targeted extensions
+
single session
```

---

# Phase 2 – Local Staging Detection

## Objective

Identify creation of centralized collection locations.

### Behavioral Indicators

Directory creation within:

```text
/tmp
/var/tmp
/dev/shm
```

followed by collection activity.

Examples:

```text
/tmp/archive_stage
/tmp/backup
/tmp/export
```

---

### Detection Reasoning

Adversaries frequently create temporary locations to aggregate data prior to archiving.

The directory itself is not suspicious.

The subsequent use of the directory is what creates detection value.

---

### Detection Signal

```text
mkdir
+
temporary directory
```

---

# Phase 3 – Collection Detection

## Objective

Identify aggregation of files into a common destination.

### Behavioral Indicators

Multiple copy operations:

```text
cp
rsync
mv
```

where:

```text
source files > multiple
destination directory = same
```

within a short execution window.

---

### Detection Reasoning

The pattern demonstrates consolidation of information.

Legitimate users occasionally copy files.

Mass aggregation of heterogeneous data is significantly less common.

---

### Detection Signal

```text
multiple collection operations
        ↓
single destination directory
```

---

# Phase 4 – Archive Creation Detection

## Objective

Identify packaging of collected information.

### Behavioral Indicators

Execution of:

```text
tar
gzip
zip
7z
xz
```

against previously staged content.

Examples:

```text
tar -czf
tar -cf
zip -r
7z a
```

---

### Detection Reasoning

Compression frequently represents the final stage before transfer or exfiltration.

Archive creation becomes highly suspicious when preceded by discovery and collection activity.

---

### Detection Signal

```text
archive utility
+
previous staging activity
```

---

# Core Detection Analytic

## High Confidence Detection

The strongest detection identified during the investigation is:

```text
find
        ↓
mkdir /tmp/*
        ↓
multiple cp operations
        ↓
tar -czf
```

within the same user session.

---

## Analytic Logic

```text
IF

multiple discovery commands occur

AND

temporary staging directory is created

AND

multiple files are collected into that directory

AND

archive creation occurs

THEN

generate alert
```

---

# Detection Conditions

## Required Conditions

At minimum:

### Discovery

```text
2 or more file discovery commands
```

AND

### Collection

```text
multiple file aggregation events
```

AND

### Compression

```text
archive creation utility execution
```

---

## Optional Conditions

Confidence can be increased if:

```text
temporary staging directory observed
```

OR

```text
archive validation observed
```

OR

```text
archive located in temporary directory
```

---

# Archive Validation Analytic

## Observed Behavior

The investigation identified:

```text
tar -czf
        ↓
tar -tzf
```

within the same session.

---

## Detection Value

This sequence indicates:

* archive verification
* archive quality checking
* preparation for movement

---

## Detection Signal

```text
archive creation
        ↓
archive inspection
```

within a short timeframe.

---

# Correlation Opportunities

## User Correlation

Correlate:

```text
uid
username
```

across all events.

---

## Session Correlation

Correlate:

```text
pid
ppid
tty
session
```

where available.

---

## Time Correlation

Correlate:

```text
Discovery
Collection
Compression
```

within a limited observation window.

Recommended:

```text
30–60 minutes
```

---

# Detection Severity Assessment

## Discovery Only

```text
Low
```

Reason:

May represent normal administration.

---

## Discovery + Collection

```text
Medium
```

Reason:

Potential staging activity.

---

## Discovery + Collection + Compression

```text
High
```

Reason:

Strong evidence of data aggregation and packaging.

---

## Discovery + Collection + Compression + Validation

```text
Critical
```

Reason:

Represents a nearly complete pre-exfiltration workflow.

---

# False Positive Considerations

## Potential Legitimate Sources

* Backup operations
* Administrative audits
* System migrations
* Developer packaging activities
* Documentation exports

---

## FP Reduction Strategies

Require:

```text
Discovery
+
Collection
+
Compression
```

rather than any single event.

Prioritize:

```text
temporary staging locations
```

and

```text
heterogeneous file types
```

over archive creation alone.

---

# Data Sources Required

## auditd

Required visibility:

```text
EXECVE
SYSCALL
cwd
uid
pid
ppid
command line
```

---

## Sysmon for Linux

Required visibility:

```text
ProcessCreate
ProcessTerminate
CommandLine
ParentProcess
Image
Hashes
```

---

# Detection Logic Summary

The investigation determined that the most reliable detection strategy is behavioral correlation.

The recommended analytic chain is:

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

Rather than alerting on utilities such as:

```text
find
cp
tar
gzip
```

individually, detections should identify the complete collection workflow.

The combination of discovery, aggregation, staging, and compression provides the highest-fidelity indicator of data staging activity and produces significantly fewer false positives than command-based detections.
