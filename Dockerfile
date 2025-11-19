FROM ubuntu:22.04

# Set environment variables with defaults (override via docker compose/env files)
ENV MINECRAFT_VERSION=latest \
    MINECRAFT_PORT=8888 \
    SERVER_NAME="Minecraft Server" \
    MAX_PLAYERS=20 \
    DIFFICULTY=easy \
    GAMEMODE=survival \
    EULA=false \
    MEMORY_MIN=1G \
    MEMORY_MAX=2G \
    PLUGIN_URLS="https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar https://github.com/EngineHub/WorldEdit/releases/download/worldedit-bukkit-7.3.3/worldedit-bukkit-7.3.3.jar" \
    PLUGIN_FORCE_DOWNLOAD=false

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

