# Supernova Node Monitoring Bot

This repository contains scripts and configuration files for monitoring a Supernova node using Monit and a Matrix bot for alerts.

### Features:
- Monitors Supernova node block height.
- Alerts on issues such as high memory usage, disk space usage, and CPU load.
- Sends alerts to a Matrix room if the node becomes unresponsive or stuck.

---

## Installation Guide

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/supernova-node-monitoring-bot.git
cd supernova-node-monitoring-bot
```

### 2. Set Up the Virtual Environment
It’s recommended to set up the bot in a virtual environment to isolate dependencies:
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
Install all necessary Python packages using the `requirements.txt` file:
```bash
pip install -r requirements.txt
```

### 4. Configure Monit
Update your Monit configuration file to match your environment:
```bash
sudo nano /etc/monit/monitrc
```

Make sure you have the following settings for monitoring:

```bash
set httpd port 2812
    use address 0.0.0.0
    allow admin:monit
    allow 0.0.0.0/0

check process supernova with pidfile /var/run/supernova.pid
  if failed port 26657 protocol http then exec "/root/matrix-bot/venv/bin/python3 /root/matrix-bot/supernova_bot.py '⚠️ Supernova node is not responding on port 26657'"

check system my_server_memory
  if memory usage > 90% then exec "/root/matrix-bot/supernova_alert.sh '⚠️ Memory usage is above 90%'"

check program supernova_block_progress with path "/root/matrix-bot/check_block_height.sh"
  if status != 0 then exec "/root/matrix-bot/supernova_alert.sh '⚠️ Supernova node stuck at block for more than 5 minutes'"

check host supernova_node with address 127.0.0.1
  if failed port 26657 protocol http then exec "/root/matrix-bot/supernova_alert.sh '⚠️ Supernova node connection is offline'"
```

### 5. Configure the Matrix Bot
- Set up the Matrix bot credentials in the `supernova_bot.py` file to send alerts to your Matrix room.
- Update the room ID and bot credentials in the Python script.

```python
client = AsyncClient("https://matrix.org", "@your-bot-username:matrix.org")
await client.login("your-bot-password")

await client.room_send(
    room_id="!your-matrix-room-id:matrix.org",
    message_type="m.room.message",
    content={
        "msgtype": "m.text",
        "body": message,
    }
)
```

### 6. Start Monitoring
To start monitoring your Supernova node and receive alerts, ensure Monit is started:
```bash
sudo service monit start
```

### 7. Additional Configuration
- Modify the scripts (`supernova_alert.sh`, `check_block_height.sh`, etc.) according to your server setup.
- Customize alerts, thresholds, and other settings based on your monitoring needs.

---

## Supernova Bot Monitoring Setup Overview

The **Supernova Bot Monitoring Setup** is designed to monitor the health and performance of your **Supernova node** and key system metrics, and then automatically send alerts to a **Matrix room** when issues arise. The bot uses various scripts to track different aspects of the node's status and sends timely updates to keep everyone informed.

### What Does It Monitor?

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

### Messages You Will Receive

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

## How It Helps

This bot setup provides comprehensive monitoring of the node and system resources. It ensures the node is functioning optimally, sends real-time alerts for issues, and helps you address potential failures before they impact the node's functionality. By relaying specific messages for each type of problem, it allows you to respond quickly and effectively.
