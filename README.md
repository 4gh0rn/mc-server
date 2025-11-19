# Minecraft Server

A Docker-based Minecraft server setup that allows you to run a Minecraft server in a containerized environment with easy configuration and persistence.

## Table of Contents

- [Description](#description)
- [Repository Contents](#repository-contents)
- [Quickstart](#quickstart)
- [Usage](#usage)
- [Configuration](#configuration)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Description

This repository contains all necessary files to set up and run a Minecraft server using Docker and Docker Compose. The project provides:

- **Dockerfile**: A custom Docker image that installs Java and sets up a Minecraft server from scratch (no pre-built Minecraft images)
- **compose.yml**: Service configuration for easy deployment and management
- **README.md**: Complete documentation for the project

The purpose of this repository is to provide a simple, maintainable, and configurable way to run a Minecraft server in a containerized environment. All server data is persisted using Docker volumes, ensuring that your world, player data, and configurations survive container restarts.

## Repository Contents

- **Dockerfile**: Custom Docker image definition that installs OpenJDK 17 and sets up the Minecraft server
- **compose.yml**: Docker Compose configuration defining the `mc-server` service with volumes, ports, and environment variables
- **start.sh**: Bash script that handles server initialization, configuration, and startup
- **.env.example**: Example environment configuration file (copy to `.env` and customize)
- **.github/workflows/deploy.yml**: GitHub Actions workflow for automated deployment to a VM
- **.gitignore**: Git ignore file to exclude irrelevant files like server data, logs, and sensitive information
- **README.md**: This documentation file

## Quickstart

### Prerequisites

- Docker installed on your system
- Docker Compose installed on your system
- At least 2GB of free RAM available
- Port 8888 available on your host machine

### Quick Start Guide

1. **Clone or download this repository**

2. **Create a `.env` file from the example**:
   ```bash
   cp .env.example .env
   ```

3. **Edit the `.env` file and set `EULA=true`** (required to run the server):
   ```bash
   # Edit .env file and change:
   EULA=true
   ```

4. **Start the server**:
   ```bash
   docker compose up -d
   ```

5. **Check server status**:
   ```bash
   docker compose logs -f mc-server
   ```

6. **Connect to your server**:
   - Server address: `localhost:8888` (or your server's IP address)
   - The server will be accessible once it has finished initializing

7. **Stop the server**:
   ```bash
   docker compose down
   ```

## Usage

### Starting the Server

To start the Minecraft server, use Docker Compose:

```bash
docker compose up -d
```

The `-d` flag runs the container in detached mode (in the background).

### Stopping the Server

To stop the server gracefully:

```bash
docker compose down
```

This will stop and remove the container, but your data will be preserved in the Docker volume.

### Viewing Logs

To view the server logs in real-time:

```bash
docker compose logs -f mc-server
```

Press `Ctrl+C` to exit the log view.

### Accessing the Server Console

To access the Minecraft server console directly:

```bash
docker compose exec mc-server /bin/bash
```

Or attach to the running container:

```bash
docker attach mc-server
```

Press `Ctrl+P` then `Ctrl+Q` to detach without stopping the container.

## Configuration

### Environment Variables

All configuration is done through environment variables. You can set these in the `compose.yml` file or by creating a `.env` file in the project root.

#### Available Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MINECRAFT_VERSION` | `latest` | Minecraft server version to use |
| `MINECRAFT_PORT` | `8888` | Port on which the server listens |
| `SERVER_NAME` | `Minecraft Server` | Name of the server |
| `MAX_PLAYERS` | `20` | Maximum number of players |
| `DIFFICULTY` | `easy` | Game difficulty (peaceful, easy, normal, hard) |
| `GAMEMODE` | `survival` | Default game mode (survival, creative, adventure, spectator) |
| `EULA` | `false` | Must be set to `true` to accept the Minecraft EULA |
| `MEMORY_MIN` | `1G` | Minimum Java heap size |
| `MEMORY_MAX` | `2G` | Maximum Java heap size |

### Modifying Configuration

#### Using Environment Variables in compose.yml

Edit the `compose.yml` file and modify the environment section:

```yaml
environment:
  - SERVER_NAME=My Awesome Server
  - MAX_PLAYERS=50
  - DIFFICULTY=normal
  - GAMEMODE=creative
  - EULA=true
```

#### Using a .env File

The recommended way to configure the server is using a `.env` file:

1. **Copy the example file**:
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file** with your desired settings:
   ```env
   SERVER_NAME=My Awesome Server
   MAX_PLAYERS=50
   DIFFICULTY=normal
   GAMEMODE=creative
   EULA=true
   MEMORY_MIN=2G
   MEMORY_MAX=4G
   ```

3. **Docker Compose will automatically read the `.env` file** when you run `docker compose up`. The `compose.yml` file already references these variables using the `${VAR:-default}` syntax, so your `.env` values will be used automatically.

**Note**: The `.env` file is already in `.gitignore`, so it won't be committed to the repository. This keeps your configuration private and secure.

#### Modifying Server Properties

After the first start, the server will generate a `server.properties` file in the Docker volume. To modify it:

1. Find the volume location:
   ```bash
   docker volume inspect mc-server_minecraft-data
   ```

2. Edit the `server.properties` file in the volume, or

3. Stop the server, modify the file, and restart:
   ```bash
   docker compose down
   # Edit the file in the volume
   docker compose up -d
   ```

### Changing the Server Port

To change the port from the default 8888:

1. Update `MINECRAFT_PORT` in `compose.yml` or `.env`
2. Update the port mapping in `compose.yml`:
   ```yaml
   ports:
     - "YOUR_PORT:YOUR_PORT"
   ```
3. Rebuild and restart:
   ```bash
   docker compose down
   docker compose up -d --build
   ```

### Adjusting Memory Allocation

To change the amount of memory allocated to the server:

Set the `MEMORY_MIN` and `MEMORY_MAX` environment variables:

```yaml
environment:
  - MEMORY_MIN=2G
  - MEMORY_MAX=4G
```

Or in a `.env` file:

```env
MEMORY_MIN=2G
MEMORY_MAX=4G
```

## Testing

### Testing Server Connectivity

You can test if your server is running and accessible using the `mcstatus` Python library:

1. Install mcstatus:
   ```bash
   pip install mcstatus
   ```

2. Test the connection:
   ```python
   from mcstatus import JavaServer
   
   server = JavaServer.lookup("localhost:8888")
   status = server.status()
   print(f"Server is online with {status.players.online} players")
   ```

Or use the command line:

```bash
mcstatus localhost:8888 status
```

### Testing from Minecraft Client

1. Start your Minecraft Java Edition client
2. Click "Multiplayer"
3. Click "Add Server"
4. Enter your server address: `localhost:8888` (or your server's IP)
5. Click "Done" and connect

### Verifying Data Persistence

1. Start the server and create a world or make changes
2. Stop the server: `docker compose down`
3. Start the server again: `docker compose up -d`
4. Verify that your world and changes are still present

## Troubleshooting

### Server Won't Start

- **Check EULA**: Make sure `EULA=true` is set in your environment variables
- **Check logs**: `docker compose logs mc-server`
- **Check port availability**: Ensure port 8888 is not already in use
- **Check memory**: Ensure you have enough RAM available

### Can't Connect to Server

- **Check firewall**: Ensure port 8888 is open in your firewall
- **Check server status**: `docker compose ps`
- **Check logs**: `docker compose logs mc-server` for any errors
- **Wait for initialization**: The server may take a few minutes to fully start

### Server Crashes

- **Check memory allocation**: Increase `MEMORY_MAX` if you see out-of-memory errors
- **Check logs**: Review logs for specific error messages
- **Verify Java version**: The server requires Java 17 or higher

### Data Not Persisting

- **Check volumes**: Verify the volume is mounted correctly: `docker volume ls`
- **Check permissions**: Ensure Docker has proper permissions to write to the volume

## CI/CD Deployment

This repository includes a GitHub Actions workflow (`.github/workflows/deploy.yml`) for automated deployment using a **self-hosted runner** on your VM.

### Setup Self-Hosted Runner

1. **Install GitHub Actions Runner on your VM**:
   ```bash
   # Create a folder for the runner
   mkdir actions-runner && cd actions-runner
   
   # Download the latest runner package (Linux x64)
   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
   
   # Extract the installer
   tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
   ```

2. **Configure the runner**:
   ```bash
   # Get the registration token from GitHub:
   # Settings > Actions > Runners > New self-hosted runner
   # Copy the token and run:
   ./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_TOKEN
   ```
   - When asked for runner name, use: `mc-server-production`
   - When asked for labels, press Enter (default is fine)
   - When asked for work folder, press Enter (default is fine)

3. **Install and start the runner as a service**:
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   sudo ./svc.sh status
   ```

4. **Ensure Docker access**:
   ```bash
   # Add the runner user to docker group (if needed)
   sudo usermod -aG docker $USER
   # Or if running as a service:
   sudo usermod -aG docker svc_actions-runner
   ```

5. **Configure GitHub Secrets & Variables** (see tables below for details).

#### Required GitHub Secrets (Settings ▸ Secrets and variables ▸ Actions ▸ Secrets)

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `VM_HOST` | IP address or hostname of your deployment VM | `192.168.1.100` or `minecraft.example.com` |
| `VM_USERNAME` | User that runs the self-hosted runner (e.g., `ubuntu`) | `ubuntu` |
| `VM_PORT` | SSH port (optional, defaults to 22) | `22` |
| `VM_SSH_KEY` | Private SSH key used for initial runner registration (only needed if you still use SSH elsewhere) | `-----BEGIN OPENSSH PRIVATE KEY-----...` |

*If you no longer need SSH (because the runner runs on the VM), you can skip `VM_SSH_KEY`.*

#### Optional GitHub Variables (Settings ▸ Secrets and variables ▸ Actions ▸ Variables)

| Variable Name | Default | Description | Example |
|---------------|---------|-------------|---------|
| `MINECRAFT_VERSION` | `latest` | Minecraft server version | `1.21.1` |
| `MINECRAFT_PORT` | `8888` | Port the server listens on | `25565` |
| `SERVER_NAME` | `Minecraft Server` | Name shown in the server list | `My Awesome Server` |
| `MAX_PLAYERS` | `20` | Maximum concurrent players | `50` |
| `DIFFICULTY` | `easy` | Game difficulty | `peaceful`, `easy`, `normal`, `hard` |
| `GAMEMODE` | `survival` | Default player mode | `survival`, `creative`, `adventure`, `spectator` |
| `MEMORY_MIN` | `1G` | Minimum Java heap | `2G` |
| `MEMORY_MAX` | `2G` | Maximum Java heap | `4G` |

#### Security Best Practices

- ✅ Keep runners up to date and rotate tokens periodically
- ✅ Restrict runner to this repository only
- ✅ Use separate runners (or tags) per environment if needed
- ✅ Monitor runner logs and disable the service when not in use

### How it works

The workflow runs directly on your VM using the self-hosted runner:
- **No SSH needed**: The runner executes directly on the VM
- **Direct access**: Full access to Docker and filesystem
- **Code Deployment**: Automatically clones/updates the repository in `~/mc-server`
- **Environment Setup**: Creates `.env` file from GitHub variables (or uses defaults)
- **Container Deployment**: Builds and deploys Docker containers using `docker compose`
- **Cleanup**: Removes `.env` file and old Docker images after deployment

### Manual Deployment

You can trigger the deployment manually:
1. Go to the "Actions" tab in your GitHub repository
2. Select "Deploy Minecraft Server" workflow
3. Click "Run workflow" and select the branch

### Advantages of Self-Hosted Runner

- ✅ **No SSH keys needed** - Runner runs directly on the VM
- ✅ **Simpler setup** - No SSH configuration required
- ✅ **Better performance** - Direct access to resources
- ✅ **More secure** - No SSH keys to manage
- ✅ **Free** - No GitHub Actions minutes consumed

## Additional Notes

- The server data is stored in a Docker volume named `minecraft-data`
- The container will automatically restart if it crashes (unless manually stopped)
- All server logs are available through `docker compose logs`
- The server.properties file is generated on first start and can be modified afterward

