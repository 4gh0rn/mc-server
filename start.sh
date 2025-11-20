#!/bin/bash
set -e

# Download/Update Paper server
PAPER_VERSION="${PAPER_VERSION:-1.21.10}"
echo "Checking Paper version: ${PAPER_VERSION}"

# Get latest build number for the version
BUILD_API="https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds"
LATEST_BUILD=$(curl -s "${BUILD_API}" | grep -o '"build":[0-9]*' | tail -1 | grep -o '[0-9]*')

if [ -z "${LATEST_BUILD}" ]; then
    echo "Error: Could not fetch latest Paper build. Using fallback build 100."
    LATEST_BUILD=100
fi

# Check if we need to download/update server.jar
NEED_DOWNLOAD=false
VERSION_FILE=".paper_version"

if [ ! -f server.jar ]; then
    echo "server.jar not found, will download..."
    NEED_DOWNLOAD=true
elif [ ! -f "${VERSION_FILE}" ] || [ "$(cat ${VERSION_FILE} 2>/dev/null)" != "${PAPER_VERSION}-${LATEST_BUILD}" ]; then
    echo "Paper version mismatch or version file missing, will update..."
    NEED_DOWNLOAD=true
fi

if [ "${NEED_DOWNLOAD}" = "true" ]; then
    echo "Downloading Paper ${PAPER_VERSION} build ${LATEST_BUILD}..."
    DOWNLOAD_URL="https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds/${LATEST_BUILD}/downloads/paper-${PAPER_VERSION}-${LATEST_BUILD}.jar"
    if curl -L -f -o server.jar "${DOWNLOAD_URL}"; then
        echo "${PAPER_VERSION}-${LATEST_BUILD}" > "${VERSION_FILE}"
        echo "Successfully downloaded Paper ${PAPER_VERSION} build ${LATEST_BUILD}"
    else
        echo "ERROR: Failed to download Paper server"
        exit 1
    fi
else
    echo "Paper ${PAPER_VERSION} build ${LATEST_BUILD} is already up to date"
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
echo "Checking for plugins to download..."
echo "PLUGIN_URLS: ${PLUGIN_URLS}"
if [ -n "${PLUGIN_URLS}" ]; then
    echo "Creating plugins directory..."
    mkdir -p plugins
    IFS=',' read -r -a urls <<< "${PLUGIN_URLS}"
    echo "Found ${#urls[@]} plugin URL(s) to process"
    for url in "${urls[@]}"; do
        if [ -z "${url}" ]; then
            continue
        fi
        filename=$(basename "${url}")
        destination="plugins/${filename}"
        if [ ! -f "${destination}" ] || [ "${PLUGIN_FORCE_DOWNLOAD}" = "true" ]; then
            echo "Downloading plugin ${filename} from ${url}..."
            if curl -L -f -o "${destination}" "${url}"; then
                echo "Successfully downloaded ${filename}"
            else
                echo "ERROR: Failed to download ${filename} from ${url}"
            fi
        else
            echo "Plugin ${filename} already present, skipping download."
        fi
    done
    echo "Plugin download process completed. Plugins in plugins/:"
    ls -la plugins/ 2>/dev/null || echo "No plugins directory found"
else
    echo "No PLUGIN_URLS set, skipping plugin download"
fi

# Start the server
echo "Starting Minecraft server..."
java -Xms${MEMORY_MIN} -Xmx${MEMORY_MAX} -jar server.jar nogui

