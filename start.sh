#!/bin/bash

# Set the terminal type to xterm-256color
export TERM=xterm-256color

# Configure zsh for color support
echo "alias ls='ls --color=auto'" >> ~/.zshrc
echo "alias grep='grep --color=auto'" >> ~/.zshrc
echo "export CLICOLOR=1" >> ~/.zshrc
echo "export LSCOLORS='ExFxCxDxBxegedabagacad'" >> ~/.zshrc
echo "export GREP_COLOR='1;32'" >> ~/.zshrc

# Start cloudflared tunnel in the background with a random domain
cloudflared tunnel --url http://localhost:5000 --no-autoupdate &
# Wait a few seconds to allow the tunnel to start (optional)
sleep 3

# Set password for root user
echo "root:password" | chpasswd

# Create the user '0xAhmadYousuf' if it does not exist and set its password
if ! id -u 0xAhmadYousuf >/dev/null 2>&1; then
    useradd -m 0xAhmadYousuf
fi
echo "0xAhmadYousuf:password" | chpasswd

# Ensure 0xAhmadYousuf's home directory exists (useradd should already create it)
mkdir -p /home/0xAhmadYousuf

# Copy all files from the current directory (where this script is located)
# to /home/0xAhmadYousuf (adjust the source path if needed)
cp -r ./* /home/0xAhmadYousuf/

# Change ownership of the files to user 0xAhmadYousuf
chown -R 0xAhmadYousuf:0xAhmadYousuf /home/0xAhmadYousuf

# Ensure app.py is executable
chmod +x /home/0xAhmadYousuf/app.py

# Switch to user 0xAhmadYousuf and run the Flask application
cd /home/0xAhmadYousuf
su - 0xAhmadYousuf -c "python3 app.py"
