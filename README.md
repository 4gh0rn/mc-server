# Minecraft Server

Minimal containerized Minecraft server setup with Docker, Docker Compose, and an optional self‑hosted GitHub Actions deployment.

---

## Table of Contents

1. [Files](#1-files)
2. [Quickstart (local)](#2-quickstart-local)
3. [Configuration](#3-configuration)
4. [Operations](#4-operations)
5. [Additional Notes](#5-additional-notes)

---

## 1. Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds Java 21 image and installs official Minecraft server |
| `compose.yml` | Defines `mc-server` service, ports, volume, and env vars |
| `start.sh` | Downloads server jar, updates `server.properties`, starts Java process |
| `.github/workflows/deploy.yml` | Self-hosted runner workflow |

---

## 2. Quickstart (local)

```bash
git clone git@github.com:4gh0rn/mc-server.git && cd mc-server
docker compose up -d
docker compose logs -f
docker compose down
```

Connect from Minecraft Java Edition to `<server-ip>:8888`.

---

## 3. Configuration

| Variable | Default | Notes |
|----------|---------|-------|
| `MINECRAFT_VERSION` | `1.21.10` | Official Minecraft server version (e.g., `1.21.10`, `1.20.1`) |
| `MINECRAFT_PORT` | `8888` | Update `ports` if you change this |
| `SERVER_NAME` | `DSO Minecraft Server` | MOTD |
| `MAX_PLAYERS` | `20` | Integer |
| `DIFFICULTY` | `easy` | `peaceful/easy/normal/hard` |
| `GAMEMODE` | `survival` | `survival/creative/adventure/spectator` |
| `EULA` | `true` | Must be `true` to run |
| `ONLINE_MODE` | `false` | Enable Mojang authentication (`true`/`false`) |
| `ENABLE_COMMAND_BLOCK` | `true` | Enable command blocks (`true`/`false`) |
| `MEMORY_MIN` | `1G` | JVM `-Xms` |
| `MEMORY_MAX` | `2G` | JVM `-Xmx` |

Use either `.env` (recommended) or edit the `environment:` block in `compose.yml`. The world, properties, and logs persist in the `minecraft-data` volume. Note that `server.properties` is updated on every container start to reflect current environment variable values.

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

### Quick Status Check

Check server status using `mcstatus`:

```bash
pip install mcstatus
mcstatus <host>:<port> status
```

---

## 5. Additional Notes

- Data lives in the `minecraft-data` Docker volume (world + configs persist across restarts).
- The server restarts automatically on container failure (`restart: unless-stopped`).
- Use `docker compose logs` or attach to the container for live console access.
- **Security**: The server runs with `online-mode=false` by default (no authentication). For production use, set `ONLINE_MODE=true` to enable Mojang authentication.

