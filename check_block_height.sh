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
