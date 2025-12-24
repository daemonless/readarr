# readarr

Book and audiobook collection manager for Usenet and BitTorrent users.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PUID` | User ID for the application process | `1000` |
| `PGID` | Group ID for the application process | `1000` |
| `TZ` | Timezone for the container | `UTC` |
| `S6_LOG_ENABLE` | Enable/Disable file logging | `1` |
| `S6_LOG_MAX_SIZE` | Max size per log file (bytes) | `1048576` |
| `S6_LOG_MAX_FILES` | Number of rotated log files to keep | `10` |

## Logging

This image uses `s6-log` for internal log rotation.
- **System Logs**: Captured from console and stored at `/config/logs/daemonless/readarr/`.
- **Application Logs**: Managed by the app and typically found in `/config/logs/`.
- **Podman Logs**: Output is mirrored to the console, so `podman logs` still works.

## Quick Start

```bash
podman run -d --name readarr \
  -p 8787:8787 \
  --annotation 'org.freebsd.jail.allow.mlock=true' \
  -e PUID=1000 -e PGID=1000 \
  -v /path/to/config:/config \
  -v /path/to/books:/books \
  -v /path/to/downloads:/downloads \
  ghcr.io/daemonless/readarr:latest
```

Access at: http://localhost:8787

## podman-compose

```yaml
services:
  readarr:
    image: ghcr.io/daemonless/readarr:latest
    container_name: readarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - /data/config/readarr:/config
      - /data/media/books:/books
      - /data/downloads:/downloads
    ports:
      - 8787:8787
    annotations:
      org.freebsd.jail.allow.mlock: "true"
    restart: unless-stopped
```

## Tags

| Tag | Source | Description |
|-----|--------|-------------|
| `:latest` | [Upstream Releases](https://readarr.servarr.com/) | Latest upstream release |
| `:pkg` | `net-p2p/readarr` | FreeBSD quarterly packages |
| `:pkg-latest` | `net-p2p/readarr` | FreeBSD latest packages |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | 1000 | User ID for app |
| `PGID` | 1000 | Group ID for app |
| `TZ` | UTC | Timezone |

## Volumes

| Path | Description |
|------|-------------|
| `/config` | Configuration directory |
| `/books` | Book library |
| `/downloads` | Download directory |

## Ports

| Port | Description |
|------|-------------|
| 8787 | Web UI |

## Notes

- **User:** `bsd` (UID/GID set via PUID/PGID, default 1000)
- **Base:** Built on `ghcr.io/daemonless/base-image` (FreeBSD)

### Specific Requirements
- **.NET App:** Requires `--annotation 'org.freebsd.jail.allow.mlock=true'` (Requires [patched ocijail](https://github.com/daemonless/daemonless#ocijail-patch))

## Links

- [Website](https://readarr.com/)
- [FreshPorts](https://www.freshports.org/net-p2p/readarr/)
