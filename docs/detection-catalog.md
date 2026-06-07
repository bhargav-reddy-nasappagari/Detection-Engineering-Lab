# Detection Catalog

## Overview

The Detection Engineering Laboratory is a Linux-focused detection engineering repository built to simulate realistic adversary behaviors, collect telemetry, perform investigations, engineer detections, develop Sigma rules, and validate detection effectiveness.

Each detection scenario follows a consistent engineering workflow:

```text
Scenario Planning
    ↓
Scenario Execution
    ↓
Telemetry Collection
    ↓
Telemetry Analysis
    ↓
Investigation
    ↓
Threat Mapping
    ↓
Detection Logic Engineering
    ↓
Sigma Rule Development
    ↓
Validation
    ↓
Evidence Collection
```

The repository currently contains twelve completed detection engineering scenarios covering execution, persistence, discovery, privilege escalation, credential access, command and control, collection, ingress tool transfer, and defense evasion techniques.

---

# Detection Coverage Catalog

| #  | Detection Scenario                | ATT&CK Technique                                           | ATT&CK Tactic        | Primary Data Sources                                     | Sigma Validated |
| -- | --------------------------------- | ---------------------------------------------------------- | -------------------- | -------------------------------------------------------- | --------------- |
| 1  | Cron Persistence                  | T1053.003 Scheduled Task/Job: Cron                         | Persistence          | Auditd, Sysmon for Linux, Process Telemetry              | Yes             |
| 2  | Systemd Service Persistence       | T1543.002 Create or Modify System Process: Systemd Service | Persistence          | Auditd, Journalctl, Process Telemetry                    | Yes             |
| 3  | Reverse Shell Execution           | T1059 Command and Scripting Interpreter                    | Execution            | Auditd, Sysmon for Linux, Network Telemetry              | Yes             |
| 4  | SSH Brute Force                   | T1110 Brute Force                                          | Credential Access    | Auth Logs, PAM Logs, SSH Logs                            | Yes             |
| 5  | Suspicious Enumeration Activity   | T1082 System Information Discovery                         | Discovery            | Auditd, Process Execution Logs                           | Yes             |
| 6  | Encoded Command Execution         | T1027 Obfuscated Files or Information                      | Defense Evasion      | Auditd, Sysmon for Linux, Process Telemetry              | Yes             |
| 7  | Rogue HTTP Server                 | T1105 Ingress Tool Transfer                                | Command and Control  | Auditd, Network Socket Telemetry, Process Execution Logs | Yes             |
| 8  | Sudo Abuse / Privilege Escalation | T1548 Abuse Elevation Control Mechanism                    | Privilege Escalation | Auditd, Sysmon for Linux, Sudo Logs                      | Yes             |
| 9  | Data Staging and Compression      | T1560 Archive Collected Data                               | Collection           | Auditd, Process Telemetry, File Activity                 | Yes             |
| 10 | Beaconing / Periodic Callbacks    | T1071 Application Layer Protocol                           | Command and Control  | Auditd, Network Telemetry, Web Server Logs               | Yes             |
| 11 | Suspicious File Download Activity | T1105 Ingress Tool Transfer                                | Command and Control  | Auditd, Network Traffic, File Metadata, Web/FTP Logs     | Yes             |
| 12 | Log Tampering / Defense Evasion   | T1070 Indicator Removal on Host                            | Defense Evasion      | Auditd, Authentication Logs, System Logs                 | Yes             |

---

# Telemetry Sources Utilized

The laboratory emphasizes telemetry-driven detection engineering. Detection logic was engineered from observed artifacts generated during simulation rather than assumptions.

The primary telemetry sources used across scenarios include:

| Telemetry Source               | Usage                                                               |
| ------------------------------ | ------------------------------------------------------------------- |
| Auditd                         | Process execution, command-line activity, file operations           |
| Sysmon for Linux               | Process creation, parent-child relationships, behavioral visibility |
| Journalctl                     | Service execution, daemon activity, system events                   |
| Authentication Logs            | Login attempts, authentication failures, privilege escalation       |
| Network Traffic Captures       | Command and control activity, payload delivery, beaconing           |
| Web Server Logs                | Payload delivery validation and callback verification               |
| FTP Server Logs                | Alternate ingress tool transfer validation                          |
| File Metadata Analysis         | Permission changes, payload staging, persistence artifacts          |
| Process Lineage Reconstruction | Parent-child execution analysis and attack reconstruction           |

---

# Detection Engineering Outcomes

The laboratory produced the following detection engineering artifacts:

* Detection logic documentation for every scenario
* ATT&CK-aligned threat mapping
* Sigma detection rules
* Validation procedures
* Raw telemetry preservation
* Investigation reports
* Sample alert artifacts
* Sample normalized events
* Evidence packages
* Attack timelines
* Process lineage reconstructions

---

# Laboratory Metrics

| Category                     | Count                 |
| ---------------------------- | --------------------- |
| Simulated Attack Scenarios   | 12                    |
| Detection Logic Documents    | 12                    |
| Investigation Reports        | 12                    |
| Threat Mapping Documents     | 12                    |
| Telemetry Analysis Documents | 12                    |
| Validation Documents         | 12                    |
| Sigma Rules                  | 15+                   |
| Evidence Collections         | 12                    |
| Sample Datasets              | Multiple per Scenario |

---

# Conclusion

This repository demonstrates a complete detection engineering lifecycle rather than isolated detection development.

Every detection was derived through practical adversary simulation, telemetry collection, investigation, behavioral analysis, ATT&CK mapping, detection engineering, Sigma development, and validation.

The objective of the laboratory was not to generate signatures for specific tools or payloads. Instead, the focus was on identifying repeatable adversary behaviors and converting those behaviors into durable detection logic capable of detecting technique-level activity.

The resulting repository provides:

* Reproducible Linux adversary simulations
* Real telemetry datasets
* Investigation-driven detection development
* ATT&CK-aligned coverage
* Sigma-based detection content
* Validation evidence for every detection

The Detection Engineering Laboratory serves as a practical portfolio of detection engineering methodologies and demonstrates the ability to transform observed attacker behavior into validated and operational detection content.
