### **Supernova Bot Monitoring Setup Overview**

The **Supernova Bot Monitoring Setup** is designed to monitor the health and performance of your **Supernova node** and key system metrics, and then automatically send alerts to a **Matrix room** when issues arise. The bot uses various scripts to track different aspects of the node's status and sends timely updates to keep everyone informed.

### **What Does It Monitor?**

1. **Node Block Progress**:
   - The bot continuously checks if the **Supernova node** is processing new blocks.
   - If the node gets stuck (i.e., the current block height does not increase), the bot will send a **warning** message to alert you that the node is stuck.
   - Once the node recovers and starts progressing again, it will send a **recovery** message.

2. **System Resource Usage**:
   - **Memory Usage**: The bot monitors memory consumption. If memory usage exceeds a predefined threshold (90%), an alert will be sent. This helps prevent issues related to memory exhaustion.
   - **CPU Load**: The bot also keeps track of the system’s CPU load. Alerts will be triggered if the CPU load exceeds specific thresholds for both 1-minute and 5-minute averages.
   - **Disk Usage**: The bot monitors disk space usage and will send an alert if the disk space exceeds 90%. This prevents the node from running out of disk space, which can disrupt operations.

3. **Network Connectivity**:
   - The bot pings a known DNS server (`8.8.8.8` - Google DNS) to ensure that the server has internet connectivity. If it fails to connect, it will send an alert indicating a possible network issue.

4. **Node Connection**:
   - The bot checks the availability of the node’s RPC port (`26657`). If the RPC port is unresponsive, an alert will be sent, indicating the node might be offline or not communicating properly.

### **Messages You Will Receive**

The bot will relay the following types of messages to your **Matrix room**:

1. **Node Status Alerts**:
   - **⚠️ Warning: Node seems to be stuck at block `<block height>`** – Sent when the node stops processing new blocks.
   - **✅ Node has recovered and is progressing. Current block: `<block height>`** – Sent when the node resumes block processing after being stuck.

2. **System Alerts**:
   - **⚠️ Memory usage is above 90%** – Sent if memory usage crosses the 90% threshold.
   - **⚠️ High CPU load detected: 1 minute average** – Sent when the 1-minute CPU load average exceeds the threshold (default: > 4).
   - **⚠️ Disk usage is above 90%** – Sent when disk usage exceeds 90%.
   - **⚠️ Network connectivity issue: Unable to reach DNS server 8.8.8.8** – Sent when the server cannot connect to the internet.

3. **Node Connection Alerts**:
   - **⚠️ Supernova node is not responding on port 26657** – Sent when the node's RPC connection becomes unresponsive.
   - **⚠️ Supernova node connection is offline** – Sent when there is an issue with the node connection itself.

---

### **How It Helps**

This bot setup provides comprehensive monitoring of the node and system resources. It ensures the node is functioning optimally, sends real-time alerts for issues, and helps you address potential failures before they impact the node's functionality. By relaying specific messages for each type of problem, it allows you to respond quickly and effectively.

Feel free to ask questions if you need any clarifications on the setup!

---

This explanation will keep your group informed and up-to-date on what the bot monitoring system does and which alerts to expect.


It looks like the files you provided are mostly in line with what we had discussed earlier. I'll now redo the manual to match your exact setup, making sure everything is correct and clearly explained for others to follow, with clear placeholders where users need to input their own data.

---


# **Supernova Node Monitoring Bot Setup**

This guide outlines how to set up a monitoring system for a Supernova node using Monit and a Matrix bot. This setup provides alerts on the node’s status, memory usage, disk usage, CPU load, and network connectivity.

## **Requirements**
- Python 3
- Monit
- `jq` for JSON parsing
- `bc` for numerical operations
- `aiohttp`, `matrix-nio` Python libraries
- Access to a Matrix account

---

## **1. Install Required Packages**

Install necessary packages and dependencies:

```bash
# Update the package list
sudo apt-get update

# Install required packages
sudo apt-get install jq bc monit python3 python3-venv python3-pip

# Install the required Python libraries in a virtual environment
python3 -m venv /path/to/your/venv  # Create a virtual environment
source /path/to/your/venv/bin/activate  # Activate the virtual environment
pip install aiohttp matrix-nio
```

The virtual environment (`venv`) ensures that your bot’s Python dependencies are isolated from the rest of your system. You can exit the environment by running `deactivate` and re-enter it with `source /path/to/your/venv/bin/activate`.

---

## **2. Configure Monit**

Monit is used to monitor the node status and system resources. You can find the configuration file at `/etc/monit/monitrc`. Below is a sample configuration:

```bash
set daemon  600            # check services at 600 seconds intervals (10 minutes)
set logfile syslog facility log_daemon

set eventqueue
    basedir /var/lib/monit/events  # store Monit events
    slots 100                      # limit queue size

set httpd port 2812
    use address 0.0.0.0  # Set to your server’s IP if needed
    allow admin:monit    # Username: admin, Password: monit for accessing the web interface
    allow 0.0.0.0/0      # Allow access from any IP range (you can restrict this for security)

# Monitor the Supernova process (without restarting it automatically)
check process supernova with pidfile /var/run/supernova.pid
  if failed port 26657 protocol http then exec "/path/to/your/venv/bin/python3 /root/matrix-bot/supernova_bot.py '⚠️ Supernova node is not responding on port 26657'"

# Monitor system memory usage
check system my_server_memory
  if memory usage > 90% then exec "/root/matrix-bot/supernova_alert.sh '⚠️ Memory usage is above 90%'"

# Monitor Supernova block height
check program supernova_block_progress with path "/root/matrix-bot/check_block_height.sh"
  if status != 0 then exec "/root/matrix-bot/supernova_alert.sh '⚠️ Supernova node stuck at block for more than 5 minutes'"

# Monitor Disk Usage
check filesystem rootfs with path /
  if space usage > 90% then exec "/root/matrix-bot/supernova_alert.sh '⚠️ Disk usage is above 90%'"

# Monitor CPU Load
check system my_server_cpu
  if loadavg (1min) > 4 then exec "/root/matrix-bot/supernova_alert.sh '⚠️ High CPU load detected: 1 minute average'"

# Monitor Network Connectivity
check host google_dns with address 8.8.8.8
  if failed icmp type echo count 3 with timeout 3 seconds then exec "/root/matrix-bot/supernova_alert.sh '⚠️ Network connectivity issue: Unable to reach DNS server 8.8.8.8'"
```

Replace `/path/to/your/venv` with the actual path to your virtual environment.

---

## **3. Supernova Node Service**

To manage the Supernova node, create a systemd service (`/etc/systemd/system/supernova.service`) like the following:

```bash
[Unit]
Description=Supernova Node
After=network.target

[Service]
Type=simple
WorkingDirectory=/usr/local/bin
User=root
Group=root
SuccessExitStatus=SIGKILL 9
ExecStart=/usr/local/bin/supernovad start
ExecStop=/usr/bin/pkill -9 supernovad
ExecStartPost=/bin/bash -c 'echo $MAINPID > /var/run/supernova.pid'
Restart=no  # Prevent Monit from automatically restarting it
RestartSec=10
LimitNOFILE=50000

[Install]
WantedBy=multi-user.target
```

---

## **4. Monitoring and Alert Scripts**

### **4.1 Block Height Check Script**

This script (`/root/matrix-bot/check_block_height.sh`) monitors the block height to detect if the node is stuck:

```bash
#!/bin/bash

# Ensure jq is installed for processing JSON responses
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it using 'sudo apt-get install jq'."
    exit 1
fi

# Attempt to get the current block height from your node
echo "Attempting to get the block height from node..."
current_block=$(curl -s http://localhost:26657/status | jq -r '.result.sync_info.latest_block_height')

# Check if curl failed to connect to the node (i.e., node is down)
if [ -z "$current_block" ] || [ "$current_block" == "null" ]; then
    echo "Node is down or not responding."
    /root/matrix-bot/venv/bin/python3 /root/matrix-bot/supernova_bot.py "⚠️ Node is down or not responding!"
    exit 0
fi

# Debug: Print the current block height
echo "Current block height: $current_block"

# Ensure the last_block file exists before attempting to read it
if [ ! -f /root/matrix-bot/last_block_height.txt ]; then
    echo "0" > /root/matrix-bot/last_block_height.txt
fi

# Get the last recorded block height (previous block height)
last_block=$(cat /root/matrix-bot/last_block_height.txt)

# Debug: Print the last block height
echo "Last block height: $last_block"

# Record the current block height for future comparison
echo "$current_block" > /root/matrix-bot/last_block_height.txt

# Compare block heights to see if the node is stuck
if [ "$current_block" -le "$last_block" ]; then
    echo "Node is stuck. Current block: $current_block, Last block: $last_block"

    # Send a message to the Matrix room if the node is stuck
    /root/matrix-bot/venv/bin/python3 /root/matrix-bot/supernova_bot.py "⚠️ Warning: Node seems to be stuck at block $current_block"
    
    echo "FAILED" > /root/matrix-bot/node_status.txt
else
    echo "Block height is progressing. Current block: $current_block, Last block: $last_block"
    echo "OK" > /root/matrix-bot/node_status.txt
fi

exit 0
```

### **4.2 Supernova Alert Script**

This script (`/root/matrix-bot/supernova_alert.sh`) monitors memory, disk usage, CPU load, and network connectivity:

```bash
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
cpu_load=$(uptime | awk -F 'load average:' '{ print $2 }' | cut -d, -f1

 | sed 's/ //g')
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
```

### **4.3 Matrix Bot Script**

The Matrix bot script (`/root/matrix-bot/supernova_bot.py`) sends messages to a Matrix room:

```python
import asyncio
from nio import AsyncClient

async def send_message(message):
    # Create the AsyncClient session
    client = AsyncClient("https://matrix.org", "@username:matrix.org")  # Replace with your Matrix username
    try:
        # Log in to Matrix with the password
        response = await client.login("your-password")  # Replace with your password

        # Send the message to the specified room
        await client.room_send(
            room_id="!your-room-id:matrix.org",  # Replace with your room ID
            message_type="m.room.message",
            content={
                "msgtype": "m.text",
                "body": message,  # Pass the dynamic message from the shell script
            }
        )
    finally:
        # Ensure the client session is properly closed
        await client.close()

async def main():
    # Retrieve the message passed to this script and send it
    import sys
    message = sys.argv[1]  # Get the dynamic message from command-line arguments
    await send_message(message)

# Run the main function
if __name__ == "__main__":
    asyncio.run(main())
```

---

## **5. Starting Monit**

Once everything is configured, start the Monit service:

```bash
sudo systemctl restart monit
```

You can access the Monit web interface at `http://your-server-ip:2812/`. Replace `your-server-ip` with the actual IP.

---

By following this guide, you will have a complete Supernova node monitoring setup. This system will actively monitor the node’s health, memory, disk usage, CPU load, and network connectivity, and notify you through Matrix if something goes wrong.

--- 

Make sure to replace placeholders like `@username`, `your-password`, and `your-room-id` with your actual values. Let me know if anything else needs adjustments!
