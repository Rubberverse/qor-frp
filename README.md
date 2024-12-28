## 🦆 Rubberverse Container Images

![frp version](https://img.shields.io/badge/frp_version-v0.61.1-darkblue)

📦 **Currently supported tags**: `latest-frps`, `latest-frpc`, `v0.61.1-frps`, `v0.61.1-frpc`

♻️ **Update Policy**: On every new frp relese. Not building against `master` branch. Rolling release, only latest versions will be supported.

🛡️ **Security Policy**: Everytime there's a fixed CVE on the horizon.

## Version Tag information

| 🐳 Image(s) | 📁 Tag(s) | 📓 Description | 💻 Architecture |
|----------|--------|-------------|---------------|
| `ghcr.io/rubberverse/qor-frp:latest-frpc` | `latest-frpc`, `frpc-$VERSION` | Runs as `frp_uclient` user, no extra privileges or fancy switching systems are used. | x86_64 |
| `ghcr.io/rubberverse/qor-frp:latest-frps` | `latest-frps`, `frps-$VERSION` | Runs as `frp_uclient` user, no extra privileges or fancy switching systems are used. | x86_64 |

❓ `$VERSION`: Replace with latest fast reverse proxy version ex. `frps-v0.61.1`

Rootfull images were made more as a practice, they won't be supported. Only rootless images will be updated and pushed from now on.

## Environmental Variables

| Env | Description | Value |
|-----|-------------|---------|
| ❗ `CONFIG_PATH` | Points to frp where the configuration is located inside of the container. Depending on version, it will either point to `frps.toml` or `frpc.toml` | `/app/configs/frpc.toml` |
| `EXTRA_ARGUMENTS` | Allows to specify extra launch parameters to frp server or client | `empty by default` |
| `TZ` | Set timezone of the container, for clearer logging. | `Europe/Warsaw` |

❗ - Required

## 🔨 Usage

This container supports no interactive commands. You can however enable frpc or frps API and steer it that way.

1. Mount a configuration file for your frp variant to `/app/configs/`
2. If you're making use of certificates, mount them using secrets or however you're used to doing. [Example Quadlet Deployment](https://github.com/MrRubberDucky/rubberverse.xyz/blob/main/Quadlet/frpc/QOR-FRPC.container) - Yes, please ensure that the files are executable by the container user and that the permissions match...
3. Run the image
4. Profit
