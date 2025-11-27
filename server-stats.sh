#!/bin/bash

echo "===== Server Performance Stats ====="

# Total CPU usage (using vmstat to get idle and calculating usage)
cpu_idle=$(vmstat 1 2 | tail -1 | awk '{print $15}')
cpu_usage=$((100 - cpu_idle))
echo "Total CPU Usage: $cpu_usage%"

# Total memory usage (free and used + percentage)
mem_total=$(free -m | awk '/^Mem:/ {print $2}')
mem_used=$(free -m | awk '/^Mem:/ {print $3}')
mem_free=$(free -m | awk '/^Mem:/ {print $4}')
mem_used_percent=$((mem_used * 100 / mem_total))
echo "Memory Usage: Used: ${mem_used}MB / Free: ${mem_free}MB (Used: ${mem_used_percent}%)"

# Total disk usage (root partition)
disk_used=$(df -h / | awk 'NR==2 {print $3}')
disk_avail=$(df -h / | awk 'NR==2 {print $4}')
disk_used_percent=$(df -h / | awk 'NR==2 {print $5}')
echo "Disk Usage (root): Used: $disk_used / Available: $disk_avail ($disk_used_percent)"

# Top 5 processes by CPU usage
echo "Top 5 Processes by CPU usage:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

# Top 5 processes by Memory usage
echo "Top 5 Processes by Memory usage:"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6

# Stretch goals:
# OS version
os_version=$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')
echo "OS Version: $os_version"

# Uptime
uptime_str=$(uptime -p)
echo "Uptime: $uptime_str"

# Load average
load_avg=$(uptime | awk -F 'load average:' '{ print $2 }' | sed 's/^ //')
echo "Load Average (1, 5, 15 min):$load_avg"

# Logged in users count
users_logged_in=$(who | wc -l)
echo "Logged in Users: $users_logged_in"

# Failed login attempts in last 24 hours (requires sudo to read auth.log or secure log)
if [ -f /var/log/auth.log ]; then
  failed_logins=$(sudo grep "Failed password" /var/log/auth.log | grep "$(date --date='1 day ago' +'%b %e')" | wc -l)
elif [ -f /var/log/secure ]; then
  failed_logins=$(sudo grep "Failed password" /var/log/secure | grep "$(date --date='1 day ago' +'%b %e')" | wc -l)
else
  failed_logins="N/A"
fi
echo "Failed Login Attempts (last 24h): $failed_logins"
