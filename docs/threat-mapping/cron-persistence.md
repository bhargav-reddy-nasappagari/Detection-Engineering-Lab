# Cron Persistence Threat Mapping

## Technique Overview
Cron jobs can be abused by attackers to establish persistence on Linux systems.
Attackers create scheduled tasks that execute malicious payloads at defined intervals.

## MITRE ATT&CK Mapping
- Tactic: Persistence
- Technique: Scheduled Task/Job
- Sub-technique: Cron (T1053.003)

## Adversary Goal
Maintain execution on the target system even after logout or reboot.

## Persistence Mechanism
The attacker modifies the crontab configuration to execute a shell script every minute.

## Simulated Attack Flow
1. Create malicious script
2. Add cron entry
3. Cron daemon executes script periodically
4. Payload writes output to log file
5. Persistence survives shell termination

## Telemetry Sources
- cron daemon logs
- process execution logs
- shell execution telemetry
- file modification telemetry

## Key Artifacts
- crontab entries
- spawned shell processes
- repeated execution intervals
- generated log files

## Detection Opportunities
- New cron entries
- Suspicious shell execution from cron
- User-writable scripts executed by cron
- High-frequency scheduled tasks

## Potential Impact
- Persistence
- Malware execution
- Beaconing
- Privilege escalation staging
