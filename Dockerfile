FROM ubuntu:22.04

# Set environment variables with defaults
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION:-latest}
ENV MINECRAFT_PORT=${MINECRAFT_PORT:-8888}
ENV SERVER_NAME=${SERVER_NAME:-Minecraft Server}
ENV MAX_PLAYERS=${MAX_PLAYERS:-20}
ENV DIFFICULTY=${DIFFICULTY:-easy}
ENV GAMEMODE=${GAMEMODE:-survival}
ENV EULA=${EULA:-false}
ENV MEMORY_MIN=${MEMORY_MIN:-1G}
ENV MEMORY_MAX=${MEMORY_MAX:-2G}

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

