# Data Staging and Compression – Execution Timeline

## Scenario Overview

This simulation emulates an adversary performing:

* Data Discovery
* Data Staging
* Data Collection
* Archive Creation
* Compression
* Archive Validation

The objective was to stage potentially valuable files into a temporary collection directory and compress them into a single archive for potential exfiltration.

---

# Session Details

| Field             | Value                        |
| ----------------- | ---------------------------- |
| User              | bunny                        |
| Session           | Interactive Shell            |
| Parent Process    | bash                         |
| Parent PID        | 11000                        |
| Terminal          | pts1                         |
| Working Directory | /home/bunny/Data-Staging-Lab |
| Date              | 03 June 2026                 |

---

# Phase 1 – Data Discovery

The operator searched the filesystem for files commonly targeted during collection operations.

### 22:48:38

```bash
find /home/bunny -name "*.csv"
```

Targeted CSV files.

---

### 22:49:04

```bash
find /home/bunny -name "*.xlsx"
```

Targeted spreadsheet files.

---

### 22:49:12

```bash
find /home/bunny -name "*.docx"
```

Targeted Word documents.

---

### 22:49:17

```bash
find /home/bunny -name "*.conf"
```

Targeted configuration files.

---

### 22:49:43

```bash
find /home/bunny -name "*.txt"
```

Targeted text files.

---

### 22:50:27

```bash
find /home/bunny -name "*.sql"
```

Targeted database exports.

---

### 22:50:34

```bash
find /home/bunny -name "*.md"
```

Targeted project documentation.

---

# Phase 2 – Staging Directory Creation

### 22:56:25

```bash
mkdir /tmp/archive_stage
```

Created temporary staging directory.

---

### 22:56:37

```bash
ls -ld /tmp/archive_stage
```

Verified staging directory creation.

---

# Phase 3 – Data Collection

Files identified during discovery were copied into the staging directory.

### 23:06:27

```bash
cp Employee_Compensation.csv Payroll_Data.csv /tmp/archive_stage
```

Collected payroll and compensation records.

---

### 23:06:37

```bash
cp Budget_2026.xlsx Q1_Financial_Report.xlsx /tmp/archive_stage
```

Collected financial spreadsheets.

---

### 23:06:54

```bash
cp Meeting_Minutes.docx Project_Roadmap.docx Vendor_List.docx /tmp/archive_stage
```

Collected business documents.

---

### 23:07:16

```bash
cp Internal_Notes.csv /tmp/archive_stage
```

Collected internal operational data.

---

### 23:07:31

```bash
cp database_backup.sql /tmp/archive_stage
```

Collected database backup.

---

### 23:07:49

```bash
cp nginx.conf server_backup.conf /tmp/archive_stage
```

Collected configuration files.

---

### 23:08:14

```bash
cp architecture.md roadmap.md /tmp/archive_stage
```

Collected project documentation.

---

### 23:08:25

```bash
cp sprint-plan.xlsx /tmp/archive_stage
```

Collected project planning material.

---

# Phase 4 – Archive Creation and Compression

### 23:40:58

```bash
tar -czf /tmp/company_backup.tar.gz /tmp/archive_stage
```

Created compressed archive.

Observed child process:

```bash
gzip
```

Compression was performed through gzip spawned by tar.

---

# Phase 5 – Archive Verification

### 23:47:06

```bash
ls -lh /tmp/company_backup.tar.gz
```

Verified archive existence and size.

---

### 23:47:28

```bash
tar -tzf /tmp/company_backup.tar.gz
```

Enumerated archive contents.

Observed child process:

```bash
gzip -d
```

Used by tar to read compressed archive contents.

---

# Final Outcome

Archive Created:

```text
/tmp/company_backup.tar.gz
```

Staging Directory:

```text
/tmp/archive_stage
```

Collection Behavior Observed:

* File discovery across multiple sensitive extensions
* Temporary staging directory creation
* Consolidation of collected files
* Archive creation using tar
* Compression using gzip
* Archive validation before potential exfiltration

ATT&CK Mapping:

* T1083 – File and Directory Discovery
* T1005 – Data from Local System
* T1074.001 – Data Staged: Local Data Staging
* T1560.001 – Archive Collected Data via Utility

Result:

The complete collection workflow was successfully reconstructed from auditd and Sysmon telemetry despite the absence of a live process tree capture.

