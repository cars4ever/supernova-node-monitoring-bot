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
