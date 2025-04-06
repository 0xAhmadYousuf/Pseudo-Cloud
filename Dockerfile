# syntax=docker/dockerfile:1.4
FROM ubuntu:20.04

WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3 python3-pip curl git zsh sudo dpkg \
    net-tools vim htop && apt-get clean

# Install Oh My Zsh (ignore error if interactive install fails)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# Configure Zsh for colored output
RUN echo "alias ls='ls --color=auto'" >> /etc/zsh/zshrc && \
    echo "alias grep='grep --color=auto'" >> /etc/zsh/zshrc && \
    echo "export CLICOLOR=1" >> /etc/zsh/zshrc && \
    echo "export LSCOLORS='ExFxCxDxBxegedabagacad'" >> /etc/zsh/zshrc && \
    echo "export GREP_COLOR='1;32'" >> /etc/zsh/zshrc && \
    echo "export TERM=xterm-256color" >> /etc/zsh/zshrc

# Set environment variables for user credentials
ARG USER_NAME
ARG USER_PASSWORD
ARG ALLOW_ROOT

# Provide default values if not supplied
ENV USER_NAME=${USER_NAME:-0xAhmadYousuf}
ENV USER_PASSWORD=${USER_PASSWORD:-password}
ENV ALLOW_ROOT=${ALLOW_ROOT:-false}

# Create a non-root user if ALLOW_ROOT is false
RUN if [ "$ALLOW_ROOT" != "true" ]; then \
    useradd -m -s /bin/zsh "$USER_NAME" && \
    echo "$USER_NAME:$USER_PASSWORD" | chpasswd && \
    echo 'export TERM=xterm-256color' >> /home/$USER_NAME/.bashrc && \
    chown $USER_NAME:$USER_NAME /home/$USER_NAME/.bashrc ; \
    fi

# Set the terminal type
ENV TERM=xterm-256color

# Install cloudflared
COPY CF/cloudflared-linux-amd64.deb /tmp/
RUN dpkg -i /tmp/cloudflared-linux-amd64.deb || apt-get install -yf

# Install Python dependencies
COPY requirements.txt /app/
RUN pip3 install -r requirements.txt

# Copy application files
COPY app.py /app/
COPY templates /app/templates
COPY start.sh /app/
RUN chmod +x /app/start.sh

# Expose Flask port
EXPOSE 5000

# Set Zsh as the default shell
SHELL ["/bin/zsh", "-c"]

# Conditionally switch to the non-root user
ARG FINAL_USER
USER ${FINAL_USER}

# Start the application
CMD ["./start.sh"]
