#!/bin/bash

while true
do
    echo "$(date) - systemd persistence heartbeat" >> /tmp/systemd-heartbeat.log
    sleep 60
done
