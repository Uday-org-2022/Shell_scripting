#!/bin/bash

# Get CPU usage (user + system) as a percentage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

# Get Memory usage percentage
mem_usage=$(free | grep Mem | awk '{printf("%.2f"), $3/$2 * 100}')

# Convert to integers for comparison
cpu_int=${cpu_usage%.*}
mem_int=${mem_usage%.*}

echo "CPU usage: $cpu_usage%"
echo "Memory usage: $mem_usage%"

# Conditions
if [ "$cpu_int" -gt 90 ]; then
    echo "High CPU usage detected!"
elif [ "$mem_int" -gt 50 ]; then
    echo "Moderate Memory usage detected!"
else
    echo "System usage is normal."
fi
