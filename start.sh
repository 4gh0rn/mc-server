#!/bin/bash
set -e

MINECRAFT_VERSION="${MINECRAFT_VERSION:-1.21.10}"
VERSION_FILE=".minecraft_version"

# Download server.jar if needed
if [ ! -f server.jar ] || [ ! -f "${VERSION_FILE}" ] || [ "$(cat ${VERSION_FILE} 2>/dev/null)" != "${MINECRAFT_VERSION}" ]; then
    echo "Downloading Minecraft ${MINECRAFT_VERSION}..."
    
    # Hardcoded download URLs for common versions
    case "${MINECRAFT_VERSION}" in
        1.21.10)
            DOWNLOAD_URL="https://piston-data.mojang.com/v1/objects/95495a7f485eedd84ce928cef5e223b757d2f764/server.jar"
            ;;
        *)
            echo "ERROR: Version ${MINECRAFT_VERSION} not supported. Please add URL to start.sh"
            exit 1
            ;;
    esac
    
    curl -L -f -o server.jar "${DOWNLOAD_URL}" || exit 1
    echo "${MINECRAFT_VERSION}" > "${VERSION_FILE}"
    echo "Downloaded Minecraft ${MINECRAFT_VERSION}"
fi

# Accept EULA if set to true (must be before server.properties update)
if [ "${EULA}" = "true" ]; then
    echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
#$(date)
eula=true" > eula.txt
fi

cat > server.properties <<EOF
server-port=${MINECRAFT_PORT}
motd=${SERVER_NAME}
max-players=${MAX_PLAYERS}
difficulty=${DIFFICULTY}
gamemode=${GAMEMODE}
online-mode=${ONLINE_MODE:-false}
enable-command-block=${ENABLE_COMMAND_BLOCK:-true}
EOF

# Start the server
echo "Starting Minecraft server..."
java -Xms${MEMORY_MIN} -Xmx${MEMORY_MAX} -jar server.jar nogui

