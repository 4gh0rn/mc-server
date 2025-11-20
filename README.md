# Minecraft Server

Minimal containerized Minecraft server setup with Docker, Docker Compose, and an optional self‑hosted GitHub Actions deployment.

---

## Table of Contents

1. [Files](#1-files)
2. [Quickstart (local)](#2-quickstart-local)
3. [Configuration](#3-configuration)
4. [Operations](#4-operations)
5. [CI/CD (self-hosted runner)](#5-cicd-self-hosted-runner)
6. [Additional Notes](#6-additional-notes)

---

## 1. Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds OpenJDK‑17 image and installs Paper server (plugin-compatible) |
| `compose.yml` | Defines `mc-server` service, ports, volume, and env vars |
| `start.sh` | Downloads server jar, writes `server.properties`, starts Java process |
| `.env.example` | Template for local configuration |
| `.github/workflows/deploy.yml` | Self-hosted runner workflow |

---

## 2. Quickstart (local)

```bash
git clone git@github.com:4gh0rn/mc-server.git && cd mc-server
cp .env.example .env
docker compose up -d
docker compose logs -f
docker compose down
```

Connect from Minecraft Java Edition to `<server-ip>:8888`.

---

## 3. Configuration

| Variable | Default | Notes |
|----------|---------|-------|
| `PAPER_VERSION` | `1.20.1` | Paper server version (e.g., `1.20.1`, `1.21.1`) |
| `MINECRAFT_PORT` | `8888` | Update `ports` if you change this |
| `SERVER_NAME` | `Minecraft Server` | MOTD |
| `MAX_PLAYERS` | `20` | Integer |
| `DIFFICULTY` | `easy` | `peaceful/easy/normal/hard` |
| `GAMEMODE` | `survival` | `survival/creative/adventure/spectator` |
| `EULA` | `false` | Must be `true` to run |
| `MEMORY_MIN` | `1G` | JVM `-Xms` |
| `MEMORY_MAX` | `2G` | JVM `-Xmx` |
| `PLUGIN_URLS` | EssentialsX + WorldEdit | Space/comma separated `.jar` URLs downloaded into `plugins/` |
| `PLUGIN_FORCE_DOWNLOAD` | `false` | Set `true` to overwrite existing plugin jars on each start |

Use either `.env` (recommended) or edit the `environment:` block in `compose.yml`. The world, properties, and logs persist in the `minecraft-data` volume.

By default the container downloads EssentialsX and WorldEdit to demonstrate plugin usage. Override `PLUGIN_URLS` to provide your own plugin list.

---

## 4. Operations

| Action | Command |
|--------|---------|
| Start | `docker compose up -d` |
| Stop | `docker compose down` |
| Logs | `docker compose logs -f mc-server` |
| Console | `docker compose exec mc-server /bin/bash` (run `screen -r` / `java` console as needed) |
| Check volume | `docker volume inspect mc-server_minecraft-data` |

Troubleshooting: verify `EULA=true`, check logs, ensure port 8888 is free, and confirm Docker has enough RAM.

### Quick Status Script

Use this helper to quickly verify that the server is online and see version/MOTD/players (e.g., in CI or after a deploy). Setup once per workstation:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python scripts/check_status.py <host>:<port>
```

Sample output:

```
version: Java 1.19.4 (protocol 762)
motd: A Minecraft Server
players: 0/20 No players online
ping: 64.75 ms
```

---

## 5. CI/CD (self-hosted runner)

1. Install a GitHub Actions runner on the VM where the server should live.
2. (Optional) add repository variables if you want to override defaults:
   `PAPER_VERSION`, `MINECRAFT_PORT`, `SERVER_NAME`, `MAX_PLAYERS`, `DIFFICULTY`, `GAMEMODE`, `MEMORY_MIN`, `MEMORY_MAX`.
3. Push to `main` (or trigger `workflow_dispatch`). The workflow pulls the repo inside `~/mc-server`, runs `docker compose up -d --build`, and passes env vars directly to Compose—no `.env` file is written.

Benefits: no SSH keys, direct access to Docker, fast redeploys.

---

## 6. Additional Notes

- Data lives in the `minecraft-data` Docker volume (world + configs persist across restarts).
- The server restarts automatically on container failure (`restart: unless-stopped`).
- Use `docker compose logs` or attach to the container for live console access.

