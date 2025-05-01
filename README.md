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

### Usage

1. Mount a configuration file to `/app/configs/frpc.toml`, replace with `frps.toml` if using the server variant.
2. Add an extra launch parameter: `--config /app/configs/frpc.toml`, replace with `frps.toml` if using the server variant. ex. `Exec=--config /app/configs/frpc.toml`
3. Run the container

That's all.
