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
