## Rubberverse Container Images

![frp version](https://img.shields.io/badge/frp_version-v0.60.0-darkblue)

**Currently supported tags**: `v0.60.0-frpc`, `v0.60.0-frps`, `latest-frpc` and `latest-frps`.

**Update Policy**: On every new frp relese. Not building against `master` branch. Rolling release, only latest versions will be supported.

**Security Policy**: Everytime there's a fixed CVE on the horizon.

This repository contains ready-to-use container images for frp client & server built using [GitHub actions](https://github.com/Rubberverse/qor-frp/blob/main/.github/workflows/publish.yml)

We are making use of our own built tianon/gosu binary which can be found in following [GitHub repository](https://github.com/Rubberverse/qor-gosu), which is just built against latest Go version.

[alpine/Dockerfile]() | [scripts/docker-entrypoint.sh]()

---

## Tag information

| Image(s) | Tag(s) | Description | Architectures |
|----------|--------|-------------|---------------|
| qor-frp | latest-frpc, frpc-`VERSION` | Alpine Linux image used as a base | x86_64 |
| qor-frp | latest-frps, frps-`VERSION` | Alpine Linux image used as a base | x86_64 |

---

## Image versionning

Image version will always reflect current version of frpc or frps, ex. frpc-v0.51.0

## Environmental Variables

| Env | Description | Value |
|-----|-------------|---------|
| **[REQ]** `CONFIG_PATH` | Points to frp where the configuration is located inside of the container ex. /app/configs/frps.toml | `empty by default` |
| **[OPT]** `EXTRA_ARGUMENTS` | Allows to specify extra launch parameters to frp server or client | `empty by default` |

## User-owned directiories

These directories will always have their permissions repaired, in order to avoid conflicts with files not being owned by correct user. **You should still ensure that the files are executable beforehand on your host.**

- `/app`

## Self-signed certificate trusting

You can mount your self-signed certificates in `/app/certs`. As long as you have one named `/app/certs/cert.pem`, it will copy it and trust it in the root store for the container.

It should eliminate some problems with Go libraries in itself refusing to trust a self-signed certificate.

## Usage

This container supports no interactive commands. You can however enable frpc or frps API and steer it that way.

1. Mount a frpc or frps configuration file depending on what tag you've choosen to `/app/configs`
2. Change `CONFIG_PATH` environmental variable so it points to your `frpc.toml` or `frps.toml` - **needs to be full path ex.** `CONFIG_PATH=/app/configs/frps.toml`
3. Run the image
4. ???
5. Profit

## Deployment Methods

// todo

