#!/bin/bash

while true
do
    curl -s http://127.0.0.1:8080/heartbeat?host=$(hostname) >/dev/null 2>&1
    sleep 30
done
