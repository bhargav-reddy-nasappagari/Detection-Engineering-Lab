# ATT&CK Coverage Matrix

## Overview

The Detection Engineering Laboratory was developed to simulate realistic Linux adversary behaviors and transform observed attack techniques into validated detection content.

Each scenario focuses on a specific adversary behavior, generates telemetry, and produces detection logic, Sigma rules, validation artifacts, and investigation documentation.

This document provides a consolidated view of the ATT&CK techniques covered throughout the laboratory.

---

# ATT&CK Technique Coverage Summary

| #  | Detection Scenario                | ATT&CK Technique                                 | ATT&CK ID | ATT&CK Tactic        | Technique Description                                                                                                 |
| -- | --------------------------------- | ------------------------------------------------ | --------- | -------------------- | --------------------------------------------------------------------------------------------------------------------- |
| 1  | Cron Persistence                  | Scheduled Task/Job: Cron                         | T1053.003 | Persistence          | Adversaries establish persistence by scheduling recurring execution through cron jobs.                                |
| 2  | Systemd Service Persistence       | Create or Modify System Process: Systemd Service | T1543.002 | Persistence          | Adversaries create or modify systemd services to maintain execution after reboot or user logout.                      |
| 3  | Reverse Shell Execution           | Command and Scripting Interpreter                | T1059     | Execution            | Adversaries execute shell interpreters to gain remote command execution capability.                                   |
| 4  | SSH Brute Force                   | Brute Force                                      | T1110     | Credential Access    | Adversaries attempt repeated authentication attempts to obtain valid credentials.                                     |
| 5  | Suspicious Enumeration Activity   | System Information Discovery                     | T1082     | Discovery            | Adversaries collect host information to understand the environment and identify opportunities for further compromise. |
| 6  | Encoded Command Execution         | Obfuscated Files or Information                  | T1027     | Defense Evasion      | Adversaries encode commands or payloads to conceal malicious activity from defenders.                                 |
| 7  | Rogue HTTP Server                 | Ingress Tool Transfer                            | T1105     | Command and Control  | Adversaries transfer tools or payloads through locally hosted HTTP services.                                          |
| 8  | Sudo Abuse / Privilege Escalation | Abuse Elevation Control Mechanism                | T1548     | Privilege Escalation | Adversaries abuse sudo privileges to execute commands with elevated permissions.                                      |
| 9  | Data Staging and Compression      | Archive Collected Data                           | T1560     | Collection           | Adversaries aggregate and compress files before exfiltration or lateral movement.                                     |
| 10 | Beaconing / Periodic Callbacks    | Application Layer Protocol                       | T1071     | Command and Control  | Adversaries establish recurring outbound communications with remote infrastructure.                                   |
| 11 | Suspicious File Download Activity | Ingress Tool Transfer                            | T1105     | Command and Control  | Adversaries retrieve payloads or tooling from remote infrastructure for execution on the host.                        |
| 12 | Log Tampering / Defense Evasion   | Indicator Removal on Host                        | T1070     | Defense Evasion      | Adversaries attempt to remove logs and forensic artifacts to hinder investigation and detection.                      |

---

# Scenario-to-Technique Mapping

## 1. Cron Persistence

| Field              | Value                                                                            |
| ------------------ | -------------------------------------------------------------------------------- |
| ATT&CK Technique   | T1053.003                                                                        |
| Technique Name     | Scheduled Task/Job: Cron                                                         |
| ATT&CK Tactic      | Persistence                                                                      |
| Detection Scenario | Creation of recurring cron jobs that repeatedly execute a payload on the system. |

---

## 2. Systemd Service Persistence

| Field              | Value                                                                          |
| ------------------ | ------------------------------------------------------------------------------ |
| ATT&CK Technique   | T1543.002                                                                      |
| Technique Name     | Create or Modify System Process: Systemd Service                               |
| ATT&CK Tactic      | Persistence                                                                    |
| Detection Scenario | Creation and enablement of a malicious systemd service to achieve persistence. |

---

## 3. Reverse Shell Execution

| Field              | Value                                                                     |
| ------------------ | ------------------------------------------------------------------------- |
| ATT&CK Technique   | T1059                                                                     |
| Technique Name     | Command and Scripting Interpreter                                         |
| ATT&CK Tactic      | Execution                                                                 |
| Detection Scenario | Interactive shell execution through an outbound reverse shell connection. |

---

## 4. SSH Brute Force

| Field              | Value                                                          |
| ------------------ | -------------------------------------------------------------- |
| ATT&CK Technique   | T1110                                                          |
| Technique Name     | Brute Force                                                    |
| ATT&CK Tactic      | Credential Access                                              |
| Detection Scenario | Repeated SSH authentication attempts against a target account. |

---

## 5. Suspicious Enumeration Activity

| Field              | Value                                                                                  |
| ------------------ | -------------------------------------------------------------------------------------- |
| ATT&CK Technique   | T1082                                                                                  |
| Technique Name     | System Information Discovery                                                           |
| ATT&CK Tactic      | Discovery                                                                              |
| Detection Scenario | Execution of multiple host discovery and enumeration commands within a single session. |

---

## 6. Encoded Command Execution

| Field              | Value                                                                                     |
| ------------------ | ----------------------------------------------------------------------------------------- |
| ATT&CK Technique   | T1027                                                                                     |
| Technique Name     | Obfuscated Files or Information                                                           |
| ATT&CK Tactic      | Defense Evasion                                                                           |
| Detection Scenario | Execution of Base64-encoded and reconstructed payloads through multiple decoding methods. |

---

## 7. Rogue HTTP Server

| Field              | Value                                                                        |
| ------------------ | ---------------------------------------------------------------------------- |
| ATT&CK Technique   | T1105                                                                        |
| Technique Name     | Ingress Tool Transfer                                                        |
| ATT&CK Tactic      | Command and Control                                                          |
| Detection Scenario | Unauthorized HTTP server hosting and delivery of payloads to remote systems. |

---

## 8. Sudo Abuse / Privilege Escalation

| Field              | Value                                                                      |
| ------------------ | -------------------------------------------------------------------------- |
| ATT&CK Technique   | T1548                                                                      |
| Technique Name     | Abuse Elevation Control Mechanism                                          |
| ATT&CK Tactic      | Privilege Escalation                                                       |
| Detection Scenario | Abuse of sudo to execute privileged commands and spawn elevated processes. |

---

## 9. Data Staging and Compression

| Field              | Value                                                                                       |
| ------------------ | ------------------------------------------------------------------------------------------- |
| ATT&CK Technique   | T1560                                                                                       |
| Technique Name     | Archive Collected Data                                                                      |
| ATT&CK Tactic      | Collection                                                                                  |
| Detection Scenario | Discovery, staging, and compression of files into an archive before potential exfiltration. |

---

## 10. Beaconing / Periodic Callbacks

| Field              | Value                                                                |
| ------------------ | -------------------------------------------------------------------- |
| ATT&CK Technique   | T1071                                                                |
| Technique Name     | Application Layer Protocol                                           |
| ATT&CK Tactic      | Command and Control                                                  |
| Detection Scenario | Periodic outbound HTTP callbacks generated at predictable intervals. |

---

## 11. Suspicious File Download Activity

| Field              | Value                                                                                     |
| ------------------ | ----------------------------------------------------------------------------------------- |
| ATT&CK Technique   | T1105                                                                                     |
| Technique Name     | Ingress Tool Transfer                                                                     |
| ATT&CK Tactic      | Command and Control                                                                       |
| Detection Scenario | Payload download to writable locations followed by permission modification and execution. |

---

## 12. Log Tampering / Defense Evasion

| Field              | Value                                                                                         |
| ------------------ | --------------------------------------------------------------------------------------------- |
| ATT&CK Technique   | T1070                                                                                         |
| Technique Name     | Indicator Removal on Host                                                                     |
| ATT&CK Tactic      | Defense Evasion                                                                               |
| Detection Scenario | Removal or modification of logging artifacts and shell history to reduce forensic visibility. |

---

# ATT&CK Tactic Coverage Summary

| ATT&CK Tactic        | Techniques Covered   | Scenarios |
| -------------------- | -------------------- | --------- |
| Persistence          | T1053.003, T1543.002 | 2         |
| Execution            | T1059                | 1         |
| Privilege Escalation | T1548                | 1         |
| Credential Access    | T1110                | 1         |
| Discovery            | T1082                | 1         |
| Collection           | T1560                | 1         |
| Command and Control  | T1071, T1105         | 3         |
| Defense Evasion      | T1027, T1070         | 2         |

---

# Coverage Observations

The laboratory focuses on behavior-driven Linux detection engineering and provides coverage across multiple stages of the attack lifecycle.

Key coverage areas include:

* Initial payload acquisition and delivery
* Command execution and shell activity
* Host discovery and reconnaissance
* Privilege escalation behavior
* Persistence mechanisms
* Data staging and preparation
* Command and control communications
* Defense evasion and log tampering

The scenarios were intentionally selected to represent common attacker tradecraft that can be observed through host telemetry and converted into reliable detection logic.

---

# Conclusion

The Detection Engineering Laboratory currently provides validated ATT&CK coverage across twelve adversary simulation scenarios.

Each scenario includes telemetry collection, investigation, ATT&CK mapping, detection engineering, Sigma rule development, validation, and evidence preservation.

Together, these scenarios form a practical Linux-focused detection engineering knowledge base and demonstrate a complete workflow for converting adversary behavior into operational detection content.
