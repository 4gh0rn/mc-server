FROM eclipse-temurin:21-jdk

# Set environment variables with defaults (override via docker compose/env files)
ENV MINECRAFT_VERSION=1.21.10 \
    MINECRAFT_PORT=8888 \
    SERVER_NAME="DSO Minecraft Server" \
    MAX_PLAYERS=20 \
    DIFFICULTY=easy \
    GAMEMODE=survival \
    EULA=true \
    ONLINE_MODE=false \
    ENABLE_COMMAND_BLOCK=true \
    MEMORY_MIN=1G \
    MEMORY_MAX=2G

# Install curl (needed for server download)
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Create minecraft server directory
WORKDIR /minecraft

# Copy and set permissions for the start script
COPY start.sh /minecraft/start.sh
RUN chmod +x /minecraft/start.sh

# Expose Minecraft port (default 8888)
EXPOSE 8888

# Set the startup command
CMD ["/minecraft/start.sh"]

