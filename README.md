# Project Zomboid Player Tracker (LiveView)

Small Phoenix LiveView app that shows:
- **Server name + address (host:port)**
- **Online player count**
- **Online player list** (via RCON)

You can use [my other repo](https://github.com/Mirkoffcito/pzomboid) to up the Project Zomboid dedicated server using **Docker** and [Playit.gg](https://playit.gg), which easily integrates with this setup.

## Demo

- [**Live Demo**](https://tfusa.medinag.com)

---

## Features

- Live updates (polls RCON periodically)
- LiveView Hook to show how much times has passed since the last update (“hace 3 minutos”, etc.)

---

## Configuration

This app reads server info and RCON settings from environment variables.

### Server info (displayed in the UI)

- `SERVER_NAME` - Your Project Zomboid server name
- `SERVER_HOST` - Your Project Zomboid IP address
- `SERVER_PORT` - Your Project Zomboid Port

### RCON connection

- `RCON_HOST` - your RCON container name in the **zomboid_net** network.
- `RCON_PORT` - 27015
- `RCON_PASSWORD` - your RCON password

### WEB INFO
- `WEB_HOST` - Your Domain
- `CF_TUNNEL_TOKEN` - Cloudflare tunnel's token
- `SECRET_KEY_BASE` - Phoenix secret key

---

## Development (Docker Compose)

I use my prduction running RCON container to do the development, so I use the same `.env` file as production. You could have a custom `.env.dev` with a non-production RCON connection.

To run the development server on `localhost:4000` you need to run:

1) `bin/setup` - Builds the container, installs elixir and node dependencies and creates the database (Postgres).
2) `bin/dev` - Ups the container

