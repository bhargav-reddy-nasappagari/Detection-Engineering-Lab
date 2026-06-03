# Investigation Report – Data Staging and Compression

## Overview

This investigation reconstructs operator activity observed during the Data Staging and Compression simulation.

Analysis is based on auditd and Sysmon telemetry collected throughout the execution of the scenario.

The investigation focuses on reconstructing the operator's objectives, identifying suspicious behavioral patterns, correlating telemetry across execution phases, and determining whether the observed activity aligns with adversarial collection and staging techniques.

---

# Investigation Objective

Determine whether observed activity represents:

* Normal administrative operations
* Legitimate backup behavior
* Deliberate collection and staging of potentially sensitive data

and reconstruct the workflow followed by the operator.

---

# Executive Assessment

Investigation findings indicate a deliberate and structured workflow consistent with data collection and staging operations.

The activity did not consist of isolated file management actions.

Instead, telemetry reveals a coordinated sequence involving:

1. Identification of valuable files
2. Centralization of selected data
3. Preparation of a staging location
4. Consolidation of collected material
5. Compression into a transportable archive
6. Validation of archive contents

The behavioral sequence closely aligns with adversary collection and staging techniques commonly observed prior to exfiltration.

---

# Investigation Methodology

The investigation was performed by correlating:

* Process execution telemetry
* Command-line arguments
* Parent-child relationships
* Temporal execution patterns
* File collection behavior
* Compression activity

Each activity was evaluated in the context of preceding and subsequent actions.

---

# Behavioral Reconstruction

## Stage 1 – Target Identification

### Observed Behavior

The session began with repeated use of the find utility against multiple file extensions.

Observed targeting included:

```text id="5gfln9"
*.csv
*.xlsx
*.docx
*.conf
*.txt
*.sql
*.md
```

---

### Investigative Assessment

This activity demonstrates deliberate discovery rather than casual filesystem browsing.

The selected file extensions are notable because they commonly contain:

| Extension | Typical Content                |
| --------- | ------------------------------ |
| CSV       | Financial and operational data |
| XLSX      | Business records and reporting |
| DOCX      | Internal documentation         |
| SQL       | Database exports               |
| CONF      | System configurations          |
| MD        | Project documentation          |
| TXT       | Notes and miscellaneous data   |

The operator did not search for a single file type.

Instead, the activity targeted multiple categories of potentially valuable information.

---

### Behavioral Finding

The discovery activity appears intended to identify data sources suitable for later collection.

This represents the beginning of a collection workflow.

---

# Stage 2 – Staging Preparation

## Observed Behavior

A dedicated directory was created:

```text id="hxrjlwm"
/tmp/archive_stage
```

followed by verification of its existence.

---

## Investigative Assessment

This directory was not used as a normal working location.

Its creation occurred immediately before collection activity began.

The naming convention:

```text id="75nruo"
archive_stage
```

suggests intentional preparation for aggregation and packaging.

Temporary directories are frequently used because they:

* reduce visibility
* simplify collection operations
* support archive creation workflows

---

## Behavioral Finding

The operator prepared infrastructure required for centralized data collection.

This marks a transition from discovery to staging.

---

# Stage 3 – Collection Activity

## Observed Behavior

Numerous copy operations transferred files into the staging directory.

Collected content included:

### Financial Information

```text id="l4v8mx"
Employee_Compensation.csv
Payroll_Data.csv
Budget_2026.xlsx
Q1_Financial_Report.xlsx
```

### Business Documentation

```text id="k95kbf"
Meeting_Minutes.docx
Project_Roadmap.docx
Vendor_List.docx
```

### Technical Information

```text id="5v6v3i"
database_backup.sql
nginx.conf
server_backup.conf
```

### Operational Data

```text id="ib4xvq"
Internal_Notes.csv
architecture.md
roadmap.md
sprint-plan.xlsx
```

---

## Investigative Assessment

The collected files span multiple business functions.

This is significant because the operator was not focused on a single dataset.

Instead, the activity targeted:

* Financial information
* Technical information
* Operational information
* Documentation

Such broad collection is frequently associated with information gathering and preparation for removal from the environment.

---

## Behavioral Finding

The operator demonstrated deliberate selection of potentially valuable files and centralized them into a single staging location.

This behavior strongly supports a collection objective.

---

# Stage 4 – Archive Creation

## Observed Behavior

The staging directory was compressed into:

```text id="sj7d26"
/tmp/company_backup.tar.gz
```

using:

```text id="u8m7an"
tar -czf
```

with gzip observed during execution.

---

## Investigative Assessment

Archive creation serves several purposes:

* Reduce file count
* Reduce transfer complexity
* Preserve directory structure
* Prepare for transport or exfiltration

Compression occurred only after collection activity had completed.

This indicates the archive was the intended final container for staged material.

---

## Behavioral Finding

The operator converted collected data into a portable package suitable for transfer.

This behavior represents the culmination of the staging process.

---

# Stage 5 – Archive Verification

## Observed Behavior

The archive was immediately inspected using:

```text id="ch8hgu"
tar -tzf /tmp/company_backup.tar.gz
```

---

## Investigative Assessment

Archive inspection demonstrates validation behavior.

The operator verified:

* archive creation success
* archive readability
* expected contents

This activity is commonly observed immediately before archive movement or transmission.

---

## Behavioral Finding

The operator performed quality assurance of the staged package before potential exfiltration.

---

# Why The Telemetry Becomes Suspicious

Individually, none of the observed commands are inherently malicious.

Examples:

```text id="s8nd0u"
find
cp
mkdir
tar
gzip
```

are common administrative utilities.

The suspicious nature emerges from the relationship between these commands.

---

## Pattern 1 – Systematic Discovery

The operator repeatedly searched for data-bearing file extensions.

Observed sequence:

```text id="z0b03v"
find
find
find
find
find
find
find
```

This demonstrates intentional targeting rather than casual exploration.

---

## Pattern 2 – Immediate Staging Preparation

Discovery activity was followed by creation of a dedicated collection directory.

Observed sequence:

```text id="y0zbxu"
find
        ↓
mkdir /tmp/archive_stage
```

This suggests planning and preparation.

---

## Pattern 3 – Burst Collection Activity

Numerous files were copied into the same location.

Observed sequence:

```text id="37zn0e"
cp
cp
cp
cp
cp
cp
```

All activity converged into a single directory.

---

## Pattern 4 – Archive Packaging

After collection completed:

```text id="nmg2hu"
tar -czf
```

was executed.

This indicates collected material was intentionally packaged.

---

## Pattern 5 – Archive Validation

The archive was immediately inspected.

Observed sequence:

```text id="gt0p3w"
tar -czf
        ↓
tar -tzf
```

This demonstrates operator verification.

---

# Reconstructed Operator Intent

Based on observed behavior, the likely operator workflow was:

```text id="uivj8x"
Identify valuable files
        ↓
Create collection location
        ↓
Copy selected data
        ↓
Aggregate data
        ↓
Compress collected material
        ↓
Validate archive
```

No evidence suggests accidental execution.

Each step logically depends on the completion of the previous step.

---

# ATT&CK-Aligned Behavioral Assessment

The activity maps closely to the following ATT&CK techniques:

| Technique | Description                        |
| --------- | ---------------------------------- |
| T1083     | File and Directory Discovery       |
| T1005     | Data from Local System             |
| T1074.001 | Local Data Staging                 |
| T1560.001 | Archive Collected Data via Utility |

---

# Investigation Conclusions

The investigation identified a complete collection and staging workflow.

The strongest evidence is not any individual command but the sequence connecting them.

Observed progression:

```text id="fkrmzx"
Discovery
        ↓
Staging Preparation
        ↓
Collection
        ↓
Archive Creation
        ↓
Archive Validation
```

This behavioral chain demonstrates intentional aggregation and packaging of potentially valuable information.

From an investigative perspective, the activity is highly consistent with data staging operations performed immediately prior to exfiltration, even though no outbound transfer activity was observed during the simulation.

Risk Assessment:

```text id="u7h47u"
Medium-High
```

The workflow exhibits multiple collection-stage behaviors and provides strong evidence of preparation for data movement outside the originating location.
