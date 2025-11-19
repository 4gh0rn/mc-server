#!/bin/bash
set -e

# Download Minecraft server if server.jar does not exist
if [ ! -f server.jar ]; then
    echo "Downloading Minecraft server..."
    wget -O server.jar https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar
fi

# Accept EULA if set to true
if [ "${EULA}" = "true" ]; then
    echo "eula=true" > eula.txt
fi

# Create server.properties if it does not exist
if [ ! -f server.properties ]; then
    echo "server-port=${MINECRAFT_PORT}" > server.properties
    echo "server-name=${SERVER_NAME}" >> server.properties
    echo "max-players=${MAX_PLAYERS}" >> server.properties
    echo "difficulty=${DIFFICULTY}" >> server.properties
    echo "gamemode=${GAMEMODE}" >> server.properties
    echo "online-mode=false" >> server.properties
    echo "enable-command-block=true" >> server.properties
fi

# Download plugins if requested
if [ -n "${PLUGIN_URLS}" ]; then
    mkdir -p plugins
    IFS=', ' read -r -a urls <<< "${PLUGIN_URLS}"
    for url in "${urls[@]}"; do
        if [ -z "${url}" ]; then
            continue
        fi
        filename=$(basename "${url}")
        destination="plugins/${filename}"
        if [ ! -f "${destination}" ] || [ "${PLUGIN_FORCE_DOWNLOAD}" = "true" ]; then
            echo "Downloading plugin ${filename}..."
            curl -L -o "${destination}" "${url}"
        else
            echo "Plugin ${filename} already present, skipping download."
        fi
    done
fi

# Start the server
echo "Starting Minecraft server..."
java -Xms${MEMORY_MIN} -Xmx${MEMORY_MAX} -jar server.jar nogui

