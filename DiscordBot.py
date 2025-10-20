import discord
from discord.ext import commands
import http.server
import socketserver
import threading
import os
import json
from datetime import datetime
import asyncio
import websockets
import aiohttp

# -------------------------------
# Configuration
# -------------------------------
PORT_HTTP = 8081
PORT_WS = 8765
msgs = {}
msgs_lock = threading.Lock()
ws_clients = set()  # connected WebSocket clients

token = os.getenv("DISCORD_TOKEN")
api_key = os.getenv("HTTP_API_KEY")  # optional HTTP POST security

if not token:
    raise ValueError("Missing DISCORD_TOKEN environment variable.")




async def send_webhook(channel, username, message, avatar_url=None):
    try:
        webhooks = await channel.webhooks()
        webhook = None

        # Find a usable webhook (one with a valid token)
        for wh in webhooks:
            if wh.token:  # only valid ones have a token
                webhook = wh
                break

        # If none found, create a new one
        if not webhook:
            webhook = await channel.create_webhook(name="CC Webhook")

        # Try to send the message
        await webhook.send(
            content=message,
            username=username or "Bot",
            avatar_url=avatar_url
        )

    except discord.errors.NotFound:
        # Webhook deleted or invalid, create a fresh one and retry
        webhook = await channel.create_webhook(name="CC Webhook")
        await webhook.send(
            content=message,
            username=username or "Bot",
            avatar_url=avatar_url
        )

    except Exception as e:
        print(f"⚠️ Failed to send webhook in #{channel}: {e}")



# -------------------------------
# WebSocket Server
# -------------------------------
async def ws_handler(websocket, path):
    ws_clients.add(websocket)
    try:
        # Optionally: send a small summary, not full history
        with msgs_lock:
            summary = {channel: messages[-5:] for channel, messages in msgs.items()}  # last 5 per channel
            await websocket.send(json.dumps(summary))
        
        async for _ in websocket:  # keep connection alive
            pass
    finally:
        ws_clients.remove(websocket)



def start_ws():
    # Create a new event loop for this thread
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

    async def ws_main():
        async with websockets.serve(
            ws_handler,
            "0.0.0.0",
            PORT_WS,
            ping_interval=None,   # disables ping pings
            ping_timeout=None     # disables automatic disconnect
        ):
            print(f"🌐 WebSocket server listening on port {PORT_WS}")
            await asyncio.Future()  # run forever

    # Run the async coroutine in the loop
    loop.run_until_complete(ws_main())




async def broadcast_ws(msg):
    if ws_clients:
        msg_json = json.dumps(msg)
        await asyncio.gather(*(ws.send(msg_json) for ws in ws_clients))


# -------------------------------
# HTTP Server
# -------------------------------
class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        """Return all messages grouped by channel."""
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()

        with msgs_lock:
            sorted_data = {
                channel: sorted(messages, key=lambda m: m["timestamp"])
                for channel, messages in msgs.items()
            }

        try:
            self.wfile.write(json.dumps(sorted_data, indent=2).encode("utf-8"))
        except ConnectionAbortedError:
            # client disconnected early
            pass

    def do_POST(self):
        """Send a message to Discord from HTTP POST."""
        content_length = int(self.headers.get("Content-Length", 0))
        raw_data = self.rfile.read(content_length)

        try:
            data = json.loads(raw_data)
        except Exception as e:
            self.send_error(400, f"Invalid JSON: {e}")
            return

        # Optional API key check
        if api_key and self.headers.get("Authorization") != api_key:
            self.send_error(403, "Invalid or missing API key")
            return

        channel_name = data.get("channel")
        message_text = data.get("message")
        custom_user = data.get("username")

        if not channel_name or not message_text:
            self.send_error(400, "Missing 'channel' or 'message'")
            return

        full_text = f"**{custom_user}:** {message_text}" if custom_user else message_text

        async def send_to_discord():
            channel = discord.utils.get(client.get_all_channels(), name=channel_name)
            if not channel:
                print(f"⚠️ Channel '{channel_name}' not found.")
                return
            await send_webhook(channel, custom_user or "Bot", message_text)
            print(f"🌐 Sent message to #{channel_name}: {full_text}")

            # Add to local history and broadcast via WebSocket
            msg_data = {
                "username": custom_user if custom_user else str(client.user),
                "message": message_text,
                "timestamp": datetime.utcnow().timestamp(),
                "channel": channel_name
            }
            with msgs_lock:
                msgs.setdefault(channel_name, []).append(msg_data)
            await broadcast_ws(msg_data)

        client.loop.create_task(send_to_discord())

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status": "sent"}')


def start_http():
    with socketserver.TCPServer(("", PORT_HTTP), MyHandler) as httpd:
        print(f"🌐 HTTP server listening on port {PORT_HTTP}")
        httpd.serve_forever()


# -------------------------------
# Discord Bot
# -------------------------------
intents = discord.Intents.default()
intents.message_content = True
intents.guilds = True
intents.guild_messages = True

client = commands.Bot(command_prefix="?", intents=intents)


@client.event
async def on_ready():
    print("✅ Bot is now ready for use!")
    print("📜 Fetching message history...")

    for guild in client.guilds:
        for channel in guild.text_channels:
            try:
                async for message in channel.history(limit=100):
                    #if message.author == client.user:
                    #    continue

                    msg_data = {
                        "username": str(message.author),
                        "message": str(message.content),
                        "timestamp": message.created_at.timestamp(),
                        "channel": str(channel)
                    }

                    with msgs_lock:
                        msgs.setdefault(str(channel), []).append(msg_data)

                print(f"Loaded history for #{channel.name}")
            except Exception as e:
                print(f"⚠️ Could not read #{channel}: {e}")

    print("📦 Finished loading message history!")


@client.event
async def on_message(message):

    username = str(message.author)
    user_message = str(message.content)
    channel_name = str(message.channel)

    if user_message.strip():
        msg_data = {
            "username": username,
            "message": user_message,
            "timestamp": message.created_at.timestamp(),
            "channel": channel_name
        }

        with msgs_lock:
            msgs.setdefault(channel_name, []).append(msg_data)

        # Broadcast via WebSocket
        asyncio.run_coroutine_threadsafe(broadcast_ws(msg_data), client.loop)

        print(f"[{channel_name}] {username}: {user_message}")

    await client.process_commands(message)


@client.command()
async def hello(ctx):
    await ctx.send("Hello!")


# -------------------------------
# Start servers
# -------------------------------
threading.Thread(target=start_http, daemon=True).start()
threading.Thread(target=start_ws, daemon=True).start()

client.run(token)
