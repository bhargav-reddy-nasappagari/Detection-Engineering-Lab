# Detection Validation
# systemd Service Persistence

---

# Validation Overview

## Detection Name

Suspicious systemd Service Persistence via Interpreter Execution

## ATT&CK Technique

T1543.002 — Create or Modify System Process: Systemd Service

## Detection Type

Behavioral Persistence Detection

## Validation Objective

The objective of this validation process is to verify that the engineered detection logic successfully identifies suspicious systemd persistence behavior while minimizing false positives.

The validation process confirms:

- telemetry visibility
- field correctness
- rule triggering behavior
- behavioral correlation effectiveness
- detection resilience
- false positive handling

---

# Validation Goals

The validation is considered successful when:

- the Sigma rule triggers during malicious service execution
- telemetry fields populate correctly
- suspicious process lineage is observable
- writable-path execution is detected
- service persistence behavior is captured
- false positives remain manageable
- detection logic survives execution variations

---

# Validation Scope

This validation focuses on detecting:

- systemd spawning interpreters
- writable-path payload execution
- suspicious ExecStart behavior
- persistence-oriented service execution
- abnormal daemon process lineage

The validation does NOT focus on:

- static service names
- file hashes
- IOC-only detection
- signature-only analytics

This ensures the detection remains behavior-driven.

---

# Validation Environment

## Operating System

```text
Ubuntu Linux VM
```

---

## Detection Environment

```text
Linux Virtual Machine
systemd enabled
```

---

## Telemetry Sources

### Process Creation Telemetry

Required for:

- process lineage
- command-line visibility
- parent-child correlation

Examples:

```text
systemd → bash
systemd → python
```

Telemetry providers:

- auditd
- Sysmon for Linux
- EDR telemetry
- eBPF sensors

---

### Filesystem Monitoring

Required for:

- service file creation
- service modification
- persistence artifact tracking

Monitored paths:

```text
/etc/systemd/system/
/etc/systemd/user/
```

---

### Journal Logs

Required for:

- service startup visibility
- restart monitoring
- daemon activity tracking

Example:

```bash
journalctl -u updater.service
```

---

# Validation Preconditions

Before validation begins, ensure:

- telemetry collection is functioning
- process creation events are visible
- journald logging is enabled
- systemd service monitoring exists
- writable-path execution is observable

---

# Simulated Persistence Behavior

## Example Malicious Service

Example service definition:

```ini
[Unit]
Description=Updater Service

[Service]
ExecStart=/bin/bash /home/user/persist.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## Expected Execution Chain

Expected suspicious lineage:

```text
systemd → bash → persist.sh
```

---

## Expected Behavioral Indicators

The simulation should generate:

| Indicator | Expected |
|---|---|
| systemd spawning bash | YES |
| writable-path execution | YES |
| Restart=always usage | YES |
| service persistence | YES |
| journald entries | YES |

---

# Validation Methodology

---

# Step 1 — Service Creation Validation

## Objective

Validate that malicious service creation generates observable telemetry.

---

## Actions Performed

- create suspicious service file
- place payload in writable directory
- enable service using systemctl
- reload daemon configuration

Example commands:

```bash
sudo systemctl daemon-reload
sudo systemctl enable updater.service
sudo systemctl start updater.service
```

---

## Expected Telemetry

Expected observable events:

- service file creation
- daemon reload activity
- service enablement
- service startup

---

## Expected Evidence

Expected artifacts:

```text
/etc/systemd/system/updater.service
```

and:

```text
journalctl entries
```

---

# Step 2 — Process Lineage Validation

## Objective

Validate suspicious parent-child execution relationships.

---

## Expected Process Chain

Expected lineage:

```text
systemd → bash → persist.sh
```

---

## Expected Detection Behavior

The Sigma rule should trigger because:

- ParentImage contains systemd
- Image contains bash
- CommandLine references writable path

---

## Validation Focus

Validate:

| Validation Item | Expected Result |
|---|---|
| ParentImage populated | YES |
| Image populated | YES |
| CommandLine populated | YES |
| Writable path visible | YES |
| Correlation successful | YES |

---

# Step 3 — Writable Path Detection Validation

## Objective

Validate detection of ExecStart execution from writable locations.

---

## Writable Paths Tested

```text
/home/
/tmp/
/dev/shm/
/var/tmp/
```

---

## Expected Trigger Behavior

The rule should trigger when:

```text
ExecStart=/home/user/persist.sh
```

or:

```text
ExecStart=/tmp/beacon.sh
```

is executed through systemd.

---

# Step 4 — Interpreter Execution Validation

## Objective

Validate detection of suspicious interpreter execution.

---

## Interpreters Tested

```text
bash
sh
python
perl
php
```

---

## Expected Trigger Behavior

The rule should trigger when systemd launches interpreters from suspicious paths.

Example:

```text
systemd → python → /tmp/payload.py
```

---

# Step 5 — Restart Persistence Validation

## Objective

Validate persistence-oriented restart behavior.

---

## Tested Configurations

```ini
Restart=always
Restart=on-failure
```

---

## Expected Results

Expected observations:

- repeated service execution
- restart loop visibility
- journald restart entries
- persistence continuity

---

# Sigma Rule Validation

## Rule Logic Validated

The following logic was validated:

```yaml
selection_parent_systemd
and selection_interpreter_execution
and selection_writable_paths
```

---

## Detection Outcome

The rule successfully identified:

- suspicious interpreter execution
- writable-path payload execution
- systemd persistence behavior
- abnormal daemon orchestration

---

# Telemetry Field Validation

## Required Fields

| Field | Validation Status |
|---|---|
| ParentImage | VERIFIED |
| Image | VERIFIED |
| CommandLine | VERIFIED |
| ProcessId | VERIFIED |
| ParentProcessId | VERIFIED |
| User | VERIFIED |

---

## Validation Notes

Telemetry successfully captured:

- parent-child relationships
- interpreter execution
- writable-path references
- suspicious service behavior

---

# False Positive Validation

---

# Legitimate Behaviors Tested

The following legitimate behaviors were evaluated:

| Legitimate Activity | Result |
|---|---|
| developer test services | possible trigger |
| automation scripts | possible trigger |
| monitoring agents | possible trigger |
| administrative wrappers | possible trigger |

---

# Noise Reduction Analysis

Signal correlation significantly reduced noise.

Weak signal example:

```text
bash execution
```

High-confidence signal example:

```text
systemd → bash + writable-path execution
```

This improved detection quality.

---

# Detection Reliability Assessment

| Validation Area | Result |
|---|---|
| Parent-child correlation | SUCCESSFUL |
| Writable-path detection | SUCCESSFUL |
| Interpreter detection | SUCCESSFUL |
| Restart persistence visibility | SUCCESSFUL |
| journald visibility | SUCCESSFUL |

---

# Detection Strengths

The detection successfully identifies:

- behavioral persistence patterns
- daemon abuse
- suspicious service execution
- interpreter-based persistence
- writable-path payload execution

The detection is resilient because it avoids:

- static IOC dependency
- service-name dependency
- file-hash dependency

---

# Detection Limitations

Potential limitations include:

- legitimate automation overlap
- missing telemetry fields
- incomplete process visibility
- restricted command-line logging
- highly customized environments

---

# Recommended Improvements

Future improvements may include:

- service file hash monitoring
- user-context enrichment
- package ownership validation
- service age analysis
- baseline service profiling
- journald correlation analytics

---

# Analyst Investigation Workflow

Upon detection trigger, analysts should:

---

## 1. Inspect Service Definition

Review:

```ini
ExecStart=
Restart=
User=
WorkingDirectory=
```

---

## 2. Validate Payload Location

Determine:

- is the payload trusted?
- is the directory writable?
- is execution expected?

---

## 3. Analyze Process Lineage

Focus on:

```text
systemd → interpreter → payload
```

---

## 4. Review Journal Logs

Example:

```bash
journalctl -u <service>
```

Look for:

- restart loops
- execution failures
- unusual execution timing

---

# Evidence Collected

The following evidence was successfully collected:

- malicious service definition
- process lineage visibility
- journald execution logs
- writable-path execution artifacts
- suspicious interpreter execution
- detection trigger confirmation

---

# Validation Conclusion

The validation confirmed that the engineered Sigma rule successfully detects suspicious systemd persistence behavior through correlated behavioral analytics.

The rule effectively identified:

- systemd spawning interpreters
- writable-path payload execution
- persistence-oriented restart behavior
- suspicious daemon execution chains

The detection demonstrated:

- behavioral resilience
- ATT&CK alignment
- reusable detection logic
- investigation-ready telemetry correlation

The validation also confirmed that signal correlation significantly improves detection confidence while reducing false positives.

---

# Final Validation Outcome

```text
VALIDATION SUCCESSFUL
```

The detection is suitable for:

- behavioral persistence detection
- Linux threat hunting
- ATT&CK-aligned analytics
- SOC triage workflows
- detection engineering portfolios

---
