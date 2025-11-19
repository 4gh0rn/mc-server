# Minecraft Server

Minimal containerized Minecraft server setup with Docker, Docker Compose, and an optional self‑hosted GitHub Actions deployment.

---

## 1. Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds OpenJDK‑17 image and installs the official server jar |
| `compose.yml` | Defines `mc-server` service, ports, volume, and env vars |
| `start.sh` | Downloads server jar, writes `server.properties`, starts Java process |
| `.env.example` | Template for local configuration |
| `.github/workflows/deploy.yml` | Self-hosted runner workflow |

---

## 2. Quickstart (local)

```bash
git clone <repo> && cd mc-server
cp .env.example .env      # set EULA=true and adjust settings
docker compose up -d      # start server on port 8888
docker compose logs -f    # follow logs
docker compose down       # stop
```

Connect from Minecraft Java Edition to `localhost:8888` (or the host IP).

---

## 3. Configuration

| Variable | Default | Notes |
|----------|---------|-------|
| `MINECRAFT_VERSION` | `latest` | Mojang server jar version |
| `MINECRAFT_PORT` | `8888` | Update `ports` if you change this |
| `SERVER_NAME` | `Minecraft Server` | MOTD |
| `MAX_PLAYERS` | `20` | Integer |
| `DIFFICULTY` | `easy` | `peaceful/easy/normal/hard` |
| `GAMEMODE` | `survival` | `survival/creative/adventure/spectator` |
| `EULA` | `false` | Must be `true` to run |
| `MEMORY_MIN` | `1G` | JVM `-Xms` |
| `MEMORY_MAX` | `2G` | JVM `-Xmx` |

Use either `.env` (recommended) or edit the `environment:` block in `compose.yml`. The world, properties, and logs persist in the `minecraft-data` volume.

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

---

## 5. CI/CD (self-hosted runner)

1. Install a GitHub Actions runner on the VM where the server should live:
   ```bash
   mkdir actions-runner && cd actions-runner
   curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
   tar xzf runner.tar.gz
   ./config.sh --url https://github.com/<user>/<repo> --token <token>
   sudo ./svc.sh install && sudo ./svc.sh start
   sudo usermod -aG docker svc_actions-runner
   ```
2. (Optional) add repository variables if you want to override defaults:
   `MINECRAFT_VERSION`, `MINECRAFT_PORT`, `SERVER_NAME`, `MAX_PLAYERS`, `DIFFICULTY`, `GAMEMODE`, `MEMORY_MIN`, `MEMORY_MAX`.
3. Push to `main` (or trigger `workflow_dispatch`). The workflow pulls the repo inside `~/mc-server`, runs `docker compose up -d --build`, and passes env vars directly to Compose—no `.env` file is written.

Benefits: no SSH keys, direct access to Docker, fast redeploys.

---

## 6. Additional Notes

- Data lives in the `minecraft-data` Docker volume (world + configs persist across restarts).
- The server restarts automatically on container failure (`restart: unless-stopped`).
- Use `docker compose logs` or attach to the container for live console access.

