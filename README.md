### Revised README.md File

Here is a polished version of your **README.md** file for GitHub, including the updated instructions for securing the Monit monitoring page with an SSH tunnel and detailing steps for Windows users to set up port forwarding:

---

# **Supernova Node Monitoring Bot Setup**

This repository contains scripts and configurations to monitor a Supernova node and key system metrics, sending alerts to a Matrix room when issues arise.

## **Features**

- Monitors block height progression of the Supernova node to detect if it gets stuck.
- Monitors key system metrics:
  - **Memory usage**
  - **Disk usage**
  - **CPU load**
  - **Network connectivity**
- Sends real-time alerts to a Matrix room when issues are detected.
  
## **Setup Instructions**

### **1. Clone the repository**

```bash
git clone https://github.com/your-repo/supernova-node-monitoring.git
cd supernova-node-monitoring
```

### **2. Install Dependencies**

Make sure Python and the necessary packages are installed:

```bash
pip install -r requirements.txt
```

### **3. Configure the Monitoring Scripts**

Update the necessary files with your details:

- **Matrix bot credentials** in `supernova_bot.py`.
- **Node-specific settings** in `check_block_height.sh` and `supernova_alert.sh`.

### **4. Configure Monit**

Monit is used to monitor the Supernova node and system resources. Edit the `monitrc` configuration file to reflect your setup:

```bash
nano /etc/monit/monitrc
```

Make sure the Monit HTTP interface is set to only allow local access:

```bash
set httpd port 2812
    use address 127.0.0.1  # Restrict access to localhost or trusted IP
    allow admin:monit      # Set a strong password
    allow localhost        # Only allow local access
```

### **5. Start Monit**

After configuring Monit, restart the service:

```bash
sudo systemctl restart monit
```

You can verify the Monit status by running:

```bash
sudo monit status
```

## **Accessing the Monit Web Interface via SSH Tunnel**

### **Option 1: SSH Tunnel with PuTTY on Windows**

1. Download and install [PuTTY](https://www.putty.org/).
2. Open PuTTY and set up a new SSH session to your VPS:
   - **Host Name**: `your_vps_ip`
   - **Port**: `22`
3. In the **Tunnels** section, set up local port forwarding:
   - **Source Port**: `2812`
   - **Destination**: `127.0.0.1:2812`
4. Save the session and connect. Now, you can access the Monit web interface by visiting `http://127.0.0.1:2812` in your local browser.

### **Option 2: Using Plink on Windows (Command Line)**

1. Open Command Prompt and run:

```bash
plink -ssh -N -L 2812:127.0.0.1:2812 your_username@your_vps_ip
```

This will create the SSH tunnel, and you can access the web interface at `http://127.0.0.1:2812`.

### **Option 3: SSH Tunnel on Linux/Mac**

For Linux or Mac users, you can simply run:

```bash
ssh -L 2812:127.0.0.1:2812 your_username@your_vps_ip
```

Once connected, open `http://127.0.0.1:2812` in your browser to access the Monit UI.

---

## **Bot Monitoring Alerts**

The bot sends the following types of alerts to the Matrix room:

### **Node Status Alerts**
- **⚠️ Node is stuck at block `<block height>`** — Sent when the node stops processing new blocks.
- **✅ Node is progressing. Current block: `<block height>`** — Sent when the node resumes block processing.

### **System Resource Alerts**
- **⚠️ Memory usage above 90%**
- **⚠️ High CPU load detected**
- **⚠️ Disk usage above 90%**
- **⚠️ Network connectivity issue**

### **Node Connection Alerts**
- **⚠️ Node is not responding on port 26657**
- **⚠️ Node connection is offline**

---

## **Security Considerations**

- Ensure that the Monit web interface is only accessible through an SSH tunnel by restricting it to **localhost** in the Monit configuration.
- Keep the system up to date and apply strong passwords to the Monit web interface.
- Do not open unnecessary ports to the public; monitor traffic and firewall rules to reduce vulnerabilities.

---

## **Contributing**

Feel free to submit pull requests or report issues. Contributions are welcome!

## **License**

This project is licensed under the MIT License.

---

### Monit Configuration (`monitrc`)

Here’s the configuration section for securing the Monit web interface:

```bash
# Enable Monit's HTTP Interface
set httpd port 2812
    use address 127.0.0.1  # Restrict access to localhost
    allow admin:monit      # Set a strong password
    allow localhost        # Only allow local access
```

This setup ensures that the Monit page is only accessible via an SSH tunnel. **Do not** open the 2812 port to the public.

---

### **How to Share this Repository in the Group**
Once everything is set up, share the repository link in your Matrix group along with a short message explaining the purpose of the repository and the installation steps. Here's an example message:

---

Hey everyone! 👋

I’ve set up a monitoring bot for our **Supernova node** to track its performance and resource usage. The bot will send alerts in this Matrix room if any issues arise. You can find the full setup instructions here: [GitHub Repository Link]

The bot monitors:
- Block height progression
- Memory, CPU, and disk usage
- Network connectivity
- Node connection status
