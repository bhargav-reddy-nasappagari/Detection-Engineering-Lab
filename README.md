# Detection Engineering Laboratory

> A telemetry-driven Linux Detection Engineering project focused on adversary simulation, investigation, ATT&CK mapping, Sigma rule development, validation, and evidence-based detection engineering.

---

## Project Overview

Detection Engineering Laboratory is a hands-on blue-team project designed to replicate the complete detection engineering lifecycle.

Rather than starting with detection rules, every detection begins with observable attacker behavior.

Each scenario follows a structured workflow:

```text
Attacker Scenario
        ↓
Scenario Planning
        ↓
Environment Setup
        ↓
Adversary Simulation
        ↓
Telemetry Collection
        ↓
Telemetry Analysis
        ↓
Investigation
        ↓
Threat Mapping
        ↓
Detection Logic Development
        ↓
Sigma Rule Engineering
        ↓
Validation
        ↓
Evidence & Sample Collection
        ↓
Documentation
```

The objective is to understand how attacks appear in telemetry and transform those observations into validated detections.

---

## Project Highlights

| Metric | Count |
|----------|----------|
| Adversary Simulations | 12 |
| Detection Strategies | 12 |
| Validation Reports | 12 |
| Threat Mapping Reports | 12 |
| Investigation Reports | 12 |
| Telemetry Studies | 12 |
| Sigma Rules | 15+ |
| Evidence Artifacts | 400+ |

---

## Skills Demonstrated

This project demonstrates practical experience in:

- Detection Engineering
- Linux Security Monitoring
- ATT&CK Mapping
- Sigma Rule Development
- Threat Detection
- Telemetry Analysis
- Adversary Simulation
- Incident Investigation
- Session Reconstruction
- Process Lineage Analysis
- Detection Validation
- Behavioral Analytics

---

## Scenario Coverage

| Scenario | ATT&CK Coverage |
|-----------|-----------|
| Cron Persistence | T1053.003 |
| Systemd Service Persistence | T1543.002 |
| Reverse Shell Execution | T1059.004, T1071 |
| SSH Brute Force | T1110 |
| Suspicious Enumeration | T1033, T1057, T1049, T1082 |
| Encoded Command Execution | T1027, T1140, T1059.004 |
| Rogue HTTP Server | T1105 |
| Sudo Abuse | T1548.003 |
| Data Staging & Compression | T1005, T1074.001, T1560.001 |
| Beaconing | T1071 |
| Suspicious File Download Activity | T1105, T1204, T1059.004 |
| Log Tampering | T1070.001, T1070.003, T1562.001 |

---

## Telemetry Sources

The laboratory primarily relies on Linux host telemetry and supporting network evidence.

### Primary Sources

- Auditd
- Sysmon for Linux
- Journalctl
- Auth.log
- PAM Authentication Logs

### Supporting Sources

- Tcpdump Packet Captures
- HTTP Access Logs
- FTP Server Logs
- File Metadata
- Process Lineage Data
- Session Reconstruction Artifacts

---

## Repository Structure

```text
detections/
├── logic/
├── sigma/
└── validation/

docs/
├── detection-catalog.md
├── methodology.md
├── telemetry-prerequisites.md
├── detection-quality-review.md
└── threat-mapping/

investigations/
telemetry/
logs/
samples/
evidence/
scenarios/
```

---

## Documentation

| Document | Purpose |
|-----------|-----------|
| Detection Catalog | Summary of all detections |
| Detection Methodology | Engineering workflow used throughout the project |
| ATT&CK Coverage Matrix | Technique coverage across scenarios |
| Telemetry Prerequisites | Telemetry setup and collection methodology |
| Detection Quality Review | Evaluation of all engineered detections |
| Threat Mapping Reports | ATT&CK alignment for each scenario |
| Validation Reports | Detection testing and false positive analysis |

---

## Detection Engineering Principles

The project follows several core principles:

- Telemetry before detection
- Investigation before rule writing
- Behavior over signatures
- Validation before completion
- Evidence-backed engineering

Detections are developed from observed attacker behavior rather than assumptions.

---

## Key Outcomes

Through this laboratory:

- Multiple ATT&CK techniques were simulated and analyzed
- Linux telemetry sources were evaluated and compared
- Behavioral detections were engineered and validated
- Sigma rules were developed from observed activity
- Investigation workflows were documented
- Detection artifacts were preserved for future reference

---

## Conclusion

Detection Engineering Laboratory demonstrates a complete, evidence-driven detection engineering workflow built around Linux adversary simulations, telemetry analysis, investigation, ATT&CK mapping, Sigma development, and validation.

The repository serves as both a learning platform and a practical portfolio showcasing the process of transforming attacker behavior into validated detection content.
