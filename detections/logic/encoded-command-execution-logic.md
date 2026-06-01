# Encoded Command Execution

## Overview

This phase focuses on deriving detection logic from the behaviors observed throughout the Encoded Command Execution simulations.

The purpose of this activity is to identify stable behavioral patterns that remain observable despite variations in execution technique. These patterns serve as the foundation for Sigma rule engineering.

Rather than detecting individual commands or specific payloads, the objective is to identify behavioral relationships between processes, execution stages, and telemetry artifacts that collectively indicate encoded command execution activity.

---

# Detection Engineering Objective

The simulations demonstrated that adversaries may alter:

* Encoding methods
* Decoding mechanisms
* Payload storage methods
* Execution chains
* Parent-child relationships

However, the operational objective remains consistent:

```text
Concealed Payload
        ↓
Payload Reconstruction
        ↓
Interpreter Execution
        ↓
Payload Activity
```

The detection strategy therefore focuses on identifying evidence of payload reconstruction followed by command execution.

---

# Variant Analysis

## Variant 1 – Inline Base64 Decode and Execute

### Observed Process Pattern

```text
bash
 └── base64 -d
      └── bash
           └── payload commands
```

### Behavioral Interpretation

The payload remains encoded until runtime.

The first shell initiates decoding.

The decoder reconstructs the payload.

A second shell executes the decoded content.

### Detection Opportunity

The strongest indicator is:

```text
bash
  ↓
base64
  ↓
bash
```

This process chain rarely occurs during normal administrative activity and directly indicates runtime decoding followed by execution.

### Detection Hypothesis

A shell launching a Base64 decoder that immediately results in another shell process may indicate encoded command execution.

---

## Variant 2 – Decoded Script Written to Disk

### Observed Process Pattern

```text
bash
 └── base64
      └── /tmp/decoded_payload.sh
              ↓
           chmod +x
              ↓
         payload execution
```

### Behavioral Interpretation

Unlike Variant 1, the payload is not executed immediately.

Instead:

1. Payload is decoded.
2. Payload is written to disk.
3. Execution permissions are granted.
4. Script is executed.

### Detection Opportunity

Multiple suspicious events occur in sequence:

```text
base64 decode
        ↓
script creation in /tmp
        ↓
chmod +x
        ↓
script execution
```

The combination is significantly stronger than any individual event.

### Detection Hypothesis

Creation of a script in a temporary directory immediately following Base64 decoding and subsequent execution may indicate decoded payload staging.

---

## Variant 3 – Python Decoder Execution

### Observed Process Pattern

```text
bash
 └── python3
      └── bash
           └── payload commands
```

### Behavioral Interpretation

Python acts as the decoding and execution mechanism.

The decoded content is handed to a shell for execution.

### Detection Opportunity

The strongest indicator is:

```text
python
   ↓
bash
```

particularly when Python was launched from an interactive shell and immediately spawns another interpreter.

### Detection Hypothesis

Python spawning a shell shortly after decoding or reconstructing content may indicate encoded payload execution.

---

## Variant 4 – Multi-Stage Decode and Execute

### Observed Process Pattern

```text
bash
 └── base64
      └── base64
           └── bash
                └── payload commands
```

### Behavioral Interpretation

The attacker increases obfuscation by adding additional decoding stages.

The operational objective remains unchanged.

### Detection Opportunity

The strongest signal becomes:

```text
base64
    ↓
base64
    ↓
bash
```

The presence of multiple decoding operations before execution significantly increases suspicion.

### Detection Hypothesis

Multiple sequential decoding processes culminating in shell execution may indicate layered payload obfuscation.

---

# Cross-Variant Behavioral Correlation

When comparing all variants, several common elements emerge.

## Common Element 1 – Payload Reconstruction

Observed methods:

* Base64 decoding
* Multiple Base64 decoding operations
* Python reconstruction
* Script generation

### Detection Value

High

Every variant reconstructed concealed content before execution.

---

## Common Element 2 – Interpreter Handoff

Observed patterns:

```text
decoder
   ↓
bash
```

Examples:

```text
base64 → bash
python → bash
base64 → base64 → bash
```

### Detection Value

Very High

The transition from reconstruction process to command interpreter is consistent across all variants.

---

## Common Element 3 – Temporary Script Staging

Observed in Variant 2 and Variant 3.

Examples:

```text
/tmp/payload.sh
/tmp/python_payload.sh
```

### Detection Value

Medium to High

Temporary script creation followed by execution is frequently observed in attacker tradecraft.

---

## Common Element 4 – Immediate Post-Execution Discovery Activity

Observed commands:

```bash
whoami
id
hostname
uname -a
ps aux
```

### Detection Value

Medium

These commands individually are common.

However, their appearance immediately after a decode-and-execute chain strengthens confidence.

---

# Derived Detection Logic

The investigation supports the following generalized detection logic.

## Logic 1 – Decode Followed by Shell Execution

```text
Decoder Process
       ↓
Shell Interpreter
```

Examples:

```text
base64 → bash
python → bash
```

Detection Confidence:

High

---

## Logic 2 – Multiple Decoding Stages Followed by Execution

```text
base64
    ↓
base64
    ↓
bash
```

Detection Confidence:

High

---

## Logic 3 – Decoded Script Written to Temporary Directory

```text
base64
    ↓
script creation
    ↓
chmod
    ↓
execution
```

Detection Confidence:

High

---

## Logic 4 – Decoded Payload Immediately Performs Discovery

```text
decode
    ↓
execution
    ↓
whoami
id
hostname
uname
ps
```

Detection Confidence:

Medium

---

# Detection Anchors

The following telemetry artifacts represent the strongest Sigma rule candidates.

## Process Relationships

```text
bash → base64 → bash
bash → python → bash
bash → base64 → base64 → bash
```

---

## Command Line Indicators

Examples:

```text
base64 -d
base64 --decode
python decoder execution
chmod +x
```

---

## File System Indicators

Examples:

```text
/tmp/*.sh
/tmp/payload.sh
/tmp/python_payload.sh
```

---

## Behavioral Sequences

Examples:

```text
decode
  ↓
execute
  ↓
host discovery
```

```text
decode
  ↓
write script
  ↓
chmod
  ↓
execute
```

---

# Sigma Engineering Takeaways

The simulations demonstrate that the most resilient detection strategy is not based on identifying specific payload commands.

Commands such as:

```text
whoami
id
hostname
uname
```

are common administrative actions and produce excessive false positives when detected independently.

Instead, Sigma rules should focus on:

1. Decoder-to-interpreter relationships.
2. Multi-stage decoding chains.
3. Temporary script staging after decoding.
4. Python-to-shell execution patterns.
5. Correlation between payload reconstruction and subsequent execution.

These behaviors remained stable across all simulation variants and therefore provide the strongest foundation for reliable detection engineering.

---

# Conclusion

The simulations revealed a consistent behavioral pattern regardless of the encoding mechanism employed.

The core detection pattern can be summarized as:

```text
Encoded Content
       ↓
Payload Reconstruction
       ↓
Interpreter Execution
       ↓
Discovery Activity
```

The most reliable detection opportunities are the process relationships and execution chains that connect decoding activity to shell execution. These relationships remain visible even when payload content, encoding method, or execution implementation changes.

