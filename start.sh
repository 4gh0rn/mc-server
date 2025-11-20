#!/bin/bash
set -e

# Download Paper server if server.jar does not exist
if [ ! -f server.jar ]; then
    echo "Downloading Paper server..."
    # Use Paper API to get latest build for version (default: 1.20.1)
    PAPER_VERSION="${PAPER_VERSION:-1.20.1}"
    
    # Get latest build number for the version
    BUILD_API="https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds"
    LATEST_BUILD=$(curl -s "${BUILD_API}" | grep -o '"build":[0-9]*' | tail -1 | grep -o '[0-9]*')
    
    if [ -z "${LATEST_BUILD}" ]; then
        echo "Error: Could not fetch latest Paper build. Using fallback build 100."
        LATEST_BUILD=100
    fi
    
    # Download Paper jar
    DOWNLOAD_URL="https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds/${LATEST_BUILD}/downloads/paper-${PAPER_VERSION}-${LATEST_BUILD}.jar"
    echo "Downloading Paper ${PAPER_VERSION} build ${LATEST_BUILD}..."
    curl -L -o server.jar "${DOWNLOAD_URL}"
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

