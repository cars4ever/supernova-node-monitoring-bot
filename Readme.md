Supernova Node Monitoring Bot

This repository contains scripts and configuration files for monitoring a Supernova node using Monit and a Matrix bot for alerts.
Features:

    Monitors Supernova node block height.
    Alerts on issues such as high memory usage, disk space usage, and CPU load.
    Sends alerts to a Matrix room if the node becomes unresponsive or stuck.

Installation Guide
1. Clone the Repository

bash

git clone https://github.com/your-username/supernova-node-monitoring-bot.git
cd supernova-node-monitoring-bot

2. Set Up the Virtual Environment

It’s recommended to set up the bot in a virtual environment to isolate dependencies:

bash

python3 -m venv venv
source venv/bin/activate

3. Install Dependencies

Install all necessary Python packages using the requirements.txt file:

bash

pip install -r requirements.txt

4. Configure Monit

Update your monitrc configuration file to match your environment:

bash

sudo nano /etc/monit/monitrc

Make sure you have the following settings for monitoring:

    Supernova node
    CPU load
    Disk usage
    Memory usage
    Network connectivity

5. Run the Bot

Once everything is set up, you can start the monitoring process using Monit.
