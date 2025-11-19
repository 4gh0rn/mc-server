FROM ubuntu:22.04

# Set environment variables with defaults
ENV MINECRAFT_VERSION=latest
ENV MINECRAFT_PORT=8888
ENV SERVER_NAME="Minecraft Server"
ENV MAX_PLAYERS=20
ENV DIFFICULTY=easy
ENV GAMEMODE=survival
ENV EULA=false
ENV MEMORY_MIN=1G
ENV MEMORY_MAX=2G

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jdk \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create minecraft server directory
WORKDIR /minecraft

# Copy and set permissions for the start script
COPY start.sh /minecraft/start.sh
RUN chmod +x /minecraft/start.sh

# Expose Minecraft port (default 8888)
EXPOSE 8888

# Set the startup command
CMD ["/minecraft/start.sh"]

