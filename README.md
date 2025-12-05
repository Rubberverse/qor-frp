## 🦆 Rubberverse Container Images

![Image Tag](https://img.shields.io/github/v/tag/Rubberverse/qor-frp) ![License](https://img.shields.io/github/license/Rubberverse/qor-frp)

This is a very simple Dockerfile that builds frp using `go build` and then just moves it into a `scratch` image. No shells, no fancy thingamajigas, just a singular binary inside the final image and that's it.

## Features

- Uses scratch image for runner, meaning there's no shell or any extra utilities
- Rootless, supports any UID:GID combination as long as you fix up the directory and file permissions
- Low file-size, frps image only weights 20.5MB while frpc one, 16.2MB
- Ready for cross-compilation, no hard dependencies
- Only read and execute permissions on main binaries

### Image Tags

| Image                                   | Description                      | Arch   |
|-----------------------------------------|----------------------------------|--------|
| `ghcr.io/rubberverse/qor-frp:frpc-$tag` | Runs the client component of frp | x86_64 |
| `ghcr.io/rubberverse/qor-frp:frps-$tag` | Runs the server component of frp | x86_64 |

Current up-to-date **stable** tags: `frpc-v0.65.0`, `frps-v0.65.0`

Current up-to-date **dev** tags: `frpc-33ab7ee`, `frps-33ab7ee` (based on `new` branch)

### Usage

1. Mount a configuration file to `/app/configs/frpc.toml`, replace with `frps.toml` if using the server variant.
2. Add an extra launch parameter: `--config /app/configs/frpc.toml`, replace with `frps.toml` if using the server variant. ex. `Exec=--config /app/configs/frpc.toml`
3. Run the container

## Quadlets

**Rootful** quadlet (executed via root user instead of unprivileged) implies: 
- `container_user` user with `UID:GID` of `1002`
- MACVLAN networking with 10.20.xx.xx for DMZ
- Own home directory
- No user shell
- Certificates added via `podman secret create` before-hand
- Exposing Caddy tcp/udp socket directly to frp process to eliminate latency, hence why the `ReverseProxy` mount.
- frps listens on port 51820 (quic)

```bash
[Unit]
Description=FRP - Reverse Proxy written in Go

[Install]
WantedBy=default.target

[Service]
Restart=on-failure
PrivateMounts=yes
PrivateTmp=yes
PrivateDevices=no
ProtectSystem=strict
ProtectProc=invisible
ProtectKernelModules=yes
ProtectClock=yes
LockPersonality=true
MemoryDenyWriteExecute=true
AllowDevices=/dev/null /dev/fuse
ReadWritePaths=/run /etc/containers /usr/local/share/containers /home/container_user/Configs/frpc
ReadOnlyPaths=/etc /var /usr /bin /sbin
InaccessiblePaths=/boot /root /opt /home/ducky /home/overseer
KeyringMode=private
UMask=0077
SystemCallFilter=~@debug @reboot @cpu-emulation @obsolete @clock @swap
CapabilityBoundingSet=~CAP_SYS_BOOT CAP_NET_BROADCAST CAP_SYSLOG CAP_SYS_TIME CAP_SYS_PACCT CAP_AUDIT_CONTROL CAP_AUDIT_READ CAP_AUDIT_WRITE CAP_NET_BROADCAST CAP_BPF CAP_SYS_TTY_CONFIG

[Container]
Image=ghcr.io/rubberverse/qor-frp:frpc-test
ContainerName=qor-frpc
Exec=--config /app/configs/frpc.toml
# Secrets
Secret=FRP_CLIENT_CERT,type=mount,target=/app/certs/client.crt,mode=0555
Secret=FRP_CLIENT_PKEY,type=mount,target=/app/certs/client.key,mode=0555
Secret=FRP_CLIENT_CA,type=mount,target=/app/certs/ca.crt,mode=0555
# Volumes
Volume=/home/container_user/Configs/frpc/frpc.toml:/app/configs/frpc.toml:ro,Z
Volume=/home/container_user/ReverseProxy:/run/tmp:z
# User
UserNS=auto:size=1002
# Labels
ReadOnly=true
AutoUpdate=registry
NoNewPrivileges=true
# Network
Network=macvlan_dmz
IP=10.20.1.19
```

**Rootless** quadlet, implies:
- User who runs it has a shell, unless workaround is used
- Pasta networking (may introduce latency)
- Certificates added via `podman secret create` before-hand
- Exposing Caddy tcp/udp socket directly to frp process to eliminate latency, hence why the `ReverseProxy` mount.
- frps listens on port 51820 (quic)

```
[Unit]
Description=FRP - Reverse Proxy written in Go

[Install]
WantedBy=default.target

[Service]
Restart=on-failure

[Container]
Image=ghcr.io/rubberverse/qor-frp:frpc-test
ContainerName=qor-frpc
Exec=--config /app/configs/frpc.toml
# Secrets
Secret=FRP_CLIENT_CERT,type=mount,target=/app/certs/client.crt,mode=0555
Secret=FRP_CLIENT_PKEY,type=mount,target=/app/certs/client.key,mode=0555
Secret=FRP_CLIENT_CA,type=mount,target=/app/certs/ca.crt,mode=0555
# Volumes
Volume=/home/container_user/Configs/frpc/frpc.toml:/app/configs/frpc.toml:ro,Z
Volume=/home/container_user/ReverseProxy:/run/tmp:z
# User
UserNS=auto:size=1002
# Labels
ReadOnly=true
AutoUpdate=registry
NoNewPrivileges=true
# Network
Network=pasta
PublishPort=51820/udp
```
