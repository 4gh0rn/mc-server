#!/usr/bin/env python3
"""
Quick helper to check the status of a Minecraft server using mcstatus.

Usage:
    python scripts/check_status.py --address <host> --port <port>
    # or shorthand
    python scripts/check_status.py host:port

If no arguments are supplied it defaults to localhost:8888.
"""
from __future__ import annotations

import argparse
import sys
from typing import Tuple

from mcstatus import JavaServer


def parse_address(value: str) -> Tuple[str, int]:
    if ":" in value:
        host, port = value.split(":", 1)
        try:
            return host, int(port)
        except ValueError as exc:
            raise argparse.ArgumentTypeError("Port must be an integer") from exc
    return value, 8888


def main() -> int:
    parser = argparse.ArgumentParser(description="Check Minecraft server status")
    parser.add_argument(
        "address",
        nargs="?",
        default="localhost:8888",
        help="Server address (host or host:port). Default: localhost:8888",
    )
    parser.add_argument(
        "--port",
        type=int,
        help="Port override (if not using host:port syntax).",
    )
    args = parser.parse_args()

    host, port = parse_address(args.address)
    if args.port is not None:
        port = args.port

    server = JavaServer(host, port)
    status = server.status()

    print(f"version: {status.version.name} (protocol {status.version.protocol})")
    print(f"motd: {status.description}")
    player_line = f"{status.players.online}/{status.players.max}"
    if status.players.sample:
        sample_names = ", ".join(player.name for player in status.players.sample)
        player_line += f" Players online: {sample_names}"
    else:
        player_line += " No players online"
    print(f"players: {player_line}")
    print(f"ping: {status.latency:.2f} ms")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

