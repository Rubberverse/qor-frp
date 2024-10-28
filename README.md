## 🦆 Rubberverse Container Images

![frp version](https://img.shields.io/badge/frp_version-v0.61.0-darkblue)

📦 **Currently supported tags**: `v0.61.0-frpc`, `v0.61.0-frps`, `v0.61.0-frpc-unpriv`, `v0.61.0-frps-unpriv`, `latest-frpc`, `latest-frps` `latest-frpc-unpriv`, `latest-frps-unpriv`.

♻️ **Update Policy**: On every new frp relese. Not building against `master` branch. Rolling release, only latest versions will be supported.

🛡️ **Security Policy**: Everytime there's a fixed CVE on the horizon.

## Version Tag information

| 🐳 Image(s) | 📁 Tag(s) | 📓 Description | 💻 Architecture |
|----------|--------|-------------|---------------|
| `docker.io/mrrubberducky/qor-frp:latest-frpc-unpriv` | `latest-frpc-unpriv`, `frpc-$VERSION-unpriv` | Runs as `frp_uclient` user, no extra privileges or fancy switching systems are used. | x86_64 |
| `docker.io/mrrubberducky/qor-frp:latest-frps-unpriv` | `latest-frps-unpriv`, `frps-$VERSION-unpriv` | Runs as `frp_uclient` user, no extra privileges or fancy switching systems are used. | x86_64 |
| `docker.io/mrrubberducky/qor-frp:latest-frpc` | `latest-frpc`, `frpc-$VERSION` | Runs initially as root then forks off to `frp_uclient` user after fixing volume permissions and installing the certificate into container's root trust store. Makes use of `tianon/gosu` | x86_64 |
| `docker.io/mrrubberducky/qor-frp:latest-frps` | `latest-frps`, `frps-$VERSION` | Runs initially as root then forks off to `frp_uclient` user after fixing volume permissions and installing the certificate into container's root trust store. Makes use of `tianon/gosu` | x86_64 |

❓ `$VERSION`: Replace with latest fast reverse proxy version ex. `frps-v0.61.0-unpriv`

💁 Privileged images make use of [Rubberverse/qor-gosu](https://github.com/Rubberverse/qor-gosu), which is `tianon/gosu` compiled with latest Go version and against `master` branch. Done that way so security engines don't have an heart attack.

Rootfull images were made more as a practice, they won't be supported. Only rootless images will be updated from now on.

## Environmental Variables

| Env | Description | Value |
|-----|-------------|---------|
| ❗ `CONFIG_PATH` | Points to frp where the configuration is located inside of the container. Depending on version, it will either point to `frps.toml` or `frpc.toml` | `/app/configs/frpc.toml` |
| `EXTRA_ARGUMENTS` | Allows to specify extra launch parameters to frp server or client | `empty by default` |

❗ - Required

## 🔨 Usage

This container supports no interactive commands. You can however enable frpc or frps API and steer it that way.

1. Mount a configuration file for your frp variant to `/app/configs/`
2. If you're making use of certificates, mount them using secrets or however you're used to doing. [Example Quadlet Deployment](https://github.com/MrRubberDucky/rubberverse.xyz/blob/main/Quadlet/frpc/QOR-FRPC.container)
3. Run the image
4. Profie
