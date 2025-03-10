## 🦆 Rubberverse Container Images

![Image Tag](https://img.shields.io/github/v/tag/Rubberverse/qor-frp) ![Frp Version](https://img.shields.io/badge/frp-v0.61.2-brown) ![License](https://img.shields.io/github/license/Rubberverse/qor-frp)

📦 **Currently supported tags**: `latest-frps`, `latest-frpc`, `frps-latest_tag_from_above`, `frpc-latst_tag_from_above`

♻️ **Update Policy**: On every new frp relese. Not building against `master` branch. Rolling release, only latest versions will be supported.

🛡️ **Update Policy**: Every 14 days.

### Version Tag information

| 🐳 Image(s) | 📁 Tag(s) | 📓 Description | 💻 Architecture |
|----------|--------|-------------|---------------|
| `ghcr.io/rubberverse/qor-frp:latest-frpc` | `latest-frpc`, `frpc-$VERSION` | Runs as `frp_uclient` user, no extra privileges or fancy switching systems are used. | x86_64 |
| `ghcr.io/rubberverse/qor-frp:latest-frps` | `latest-frps`, `frps-$VERSION` | Runs as `frp_uclient` user, no extra privileges or fancy switching systems are used. | x86_64 |

❓ `$VERSION`: Replace with latest fast reverse proxy version ex. `frps-v0.61.1`

Rootfull images were made more as a practice, they won't be supported. Only rootless images will be updated and pushed from now on.

### Environmental Variables

| Env | Description | Value |
|-----|-------------|---------|
| ❗ `CONFIG_PATH` | Points to frp where the configuration is located inside of the container. Depending on version, it will either point to `frps.toml` or `frpc.toml` | `/app/configs/frpc.toml` |
| `EXTRA_ARGUMENTS` | Allows to specify extra launch parameters to frp server or client | `empty by default` |
| `TZ` | Set timezone of the container, for clearer logging. | `Europe/Warsaw` |

❗ - Required

### Usage

This container supports no interactive commands. You can however enable frpc or frps API and steer it that way.
