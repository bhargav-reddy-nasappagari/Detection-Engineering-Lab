#!/bin/bash

echo "[*] Starting Enumeration Simulation"

sleep 2

whoami
sleep 1

id
sleep 1

hostname
sleep 1

uname -a
sleep 2

groups
sleep 1

getent passwd
sleep 2

sudo -l
sleep 2

w
sleep 1

who
sleep 2

ip a
sleep 2

ip route
sleep 2

ss -tulnp
sleep 2

ps aux
sleep 2

systemctl list-units --type=service
sleep 2

systemctl list-timers
sleep 2

which auditctl
sleep 1

which tcpdump
sleep 1

find / -perm -4000 2>/dev/null
sleep 2

find /home -name "*.sh" 2>/dev/null
sleep 2

find / -name "*.conf" 2>/dev/null
sleep 2

find / -name "*.key" 2>/dev/null
sleep 2

journalctl -n 20
sleep 2

ls /var/log

echo "[*] Enumeration Simulation Complete"
