import eventlet
eventlet.monkey_patch()  # Ensure eventlet works properly

import re
import os
import platform
import threading
import subprocess
from termcolor import colored
from flask import Flask, render_template
from flask_socketio import SocketIO, emit

if platform.system().lower() == "windows":
    raise RuntimeError("This terminal is only supported on Unix/Linux systems.")

app = Flask(__name__)
app.debug = True  # Enable Flask debug mode

# Initialize SocketIO with eventlet async_mode
socketio = SocketIO(app, async_mode='eventlet')

# ANSI color codes for logging
GREEN = "\033[32m"   # Green for input logs and connection info
BLUE = "\033[34m"    # Blue for output logs and error messages
RESET = "\033[0m"    # Reset to default

@app.route("/")
def index():
    return render_template("index.html")

@socketio.on("connect")
def handle_connect():
    print(f"{GREEN}[DEBUG] Client connected{RESET}")

@socketio.on("disconnect")
def handle_disconnect():
    print(f"{BLUE}[DEBUG] Client disconnected{RESET}")

@socketio.on("input")
def handle_input(data):
    # Log input data in green
    print(f"{GREEN}[DEBUG INPUT] {data}{RESET}")
    try:
        os.write(master_fd, data.encode())
    except Exception as e:
        print(f"{BLUE}[DEBUG ERROR] Failed to write input: {e}{RESET}")

# def read_output():
#     while True:
#         try:
#             chunk = os.read(master_fd, 1024).decode()
#             if not chunk:
#                 break
#             # Log output data in blue
#             print(f"{BLUE}[DEBUG OUTPUT] {chunk}{RESET}")
            
#             # if chunk have @ and : and  # or $ then split and colorize red if root either make it green
#             socketio.emit("output", chunk)
#         except Exception as e:
#             print(f"{BLUE}[DEBUG ERROR] Reading from PTY failed: {e}{RESET}")
#             break

import re

# ANSI escape codes for colors
RED = "\u001b[31m"
GREEN = "\u001b[32m"
BLUE = "\u001b[34m"
RESET = "\u001b[0m"

def read_output():
    username_pattern = re.compile(r'(?P<user>\w+)@(?P<host>[\w\.-]+):(?P<path>[\w/]+)(?P<symbol>[#$])')
    
    while True:
        try:
            chunk = os.read(master_fd, 1024).decode()
            if not chunk:
                break
            
            # Search for the username@hostname:path# or $ pattern
            match = username_pattern.search(chunk)
            if match:
                user = match.group('user')
                host = match.group('host')
                path = match.group('path')
                symbol = match.group('symbol')
                
                # Determine color based on user
                user_color = RED if user == 'root' else GREEN
                
                # Construct the colored prompt
                colored_prompt = (
                    f"{user_color}{user}@{host}{RESET}:"
                    f"{BLUE}{path}{RESET}"
                    f"{symbol} "
                )
                
                # Replace the original prompt with the colored one
                chunk = username_pattern.sub(colored_prompt, chunk)
            
            # Emit the colorized output
            socketio.emit("output", chunk)
        except Exception as e:
            print(f"{BLUE}[DEBUG ERROR] Reading from PTY failed: {e}{RESET}")
            break



if __name__ == "__main__":
    import pty
    pid, master_fd = pty.fork()

    if pid == 0:
        print("[CHILD] Starting shell...")
        subprocess.run(["/bin/bash"])
    else:
        # Start thread to continuously read shell output and emit it via Socket.IO
        threading.Thread(target=read_output, daemon=True).start()
        print(f"{GREEN}[DEBUG] Starting Flask app in debug mode{RESET}")
        socketio.run(app, host="0.0.0.0", port=5000, debug=True)
