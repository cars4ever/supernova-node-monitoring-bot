#!/bin/bash

# Ensure jq and bc are installed for processing JSON responses and basic calculations
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it using 'sudo apt-get install jq'."
    exit 1
fi

if ! command -v bc &> /dev/null; then
    echo "bc is not installed. Please install it using 'sudo apt-get install bc'."
    exit 1
fi

# Memory usage monitoring
memory_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
memory_used=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
memory_usage=$(echo "scale=2; ($memory_total - $memory_used)/$memory_total*100" | bc)
echo "Memory usage: $memory_usage%"

if (( $(echo "$memory_usage > 90" | bc -l) )); then
    /root/matrix-bot/venv/bin/python3 /root/matrix-bot/supernova_bot.py "⚠️ Memory usage is above 90%: $memory_usage%"
else
    echo "Memory usage is below 90%, no alert sent."
fi

# Disk usage monitoring
disk_usage=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
echo "Disk usage: $disk_usage%"
if [ "$disk_usage" -gt 90 ]; then
    /root/matrix-bot/venv/bin/python3 /root/matrix-bot/supernova_bot.py "⚠️ Disk usage is above 90%: $disk_usage%"
else
    echo "Disk usage is below 90%, no alert sent."
fi

# CPU load monitoring
cpu_load=$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/ //g')
echo "CPU load (1 min average): $cpu_load"
if (( $(echo "$cpu_load > 4.0" | bc -l) )); then
    /root/matrix-bot/venv/bin/python3 /root/matrix-bot/supernova_bot.py "⚠️ High CPU load detected: 1 minute average is $cpu_load"
else
    echo "CPU load is below 4, no alert sent."
fi

# Network connectivity monitoring
ping -c 1 8.8.8.8 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    /root/matrix-bot/venv/bin/python3 /root/matrix-bot/supernova_bot.py "⚠️ Network connectivity issue: Unable to reach DNS server 8.8.8.8"
else
    echo "Network connectivity is OK"
fi
