## Rubberverse Container Images

![frp version](https://img.shields.io/badge/frp_version-v0.58.1-darkblue)

This repository contains ready-to-use container images for frp client & server built using [GitHub actions]()

Binaries themselves are built against [fatedier/frp](https://github.com/fatedier/frp) latest stable release tag using `go build` and it makes use of [tianon/gosu](https://github.com/tianon/gosu), specifically [Rubberverse/qor-gosu](https://github.com/Rubberverse/qor-gosu) build of it.

## Tag information

| Image(s) | Tag(s) | Description | Architectures |
|----------|--------|-------------|---------------|
| qor-frpc | frpc-alpine, frps-version | Alpine Linux image used as a base | x86_64, x86, ARM64 |
| qor-frps | frps-alpine, frps-version | Alpine Linux image used as a base | x86_64, x86, ARM64 |
| qor-frp-binary | latest | Stores all binaries created during cross-compilation phase | x86_64, x86, ARM64, ARMv7, ARMv6, ARMv5, PPC64LE, MIPS64LE, RISCV64, S390X |

❔ Only ARM and AMD64, i386 images are available, if you want to try out the other architectures then use COPY on a blank base with the binary, example Dockerfile can be found below

```Dockerfile
FROM ghcr.io/rubberverse/qor-frp-binary:latest AS qor-frp-binary

FROM docker.io/library/alpine:v3.20 AS qor-frp
WORKDIR /app

COPY --from=qor-frp-binary /app/bin/frpc-"${TARGETARCH}" /app/bin/frpc
# or
COPY --from=qor-frp-binary /app/bin/frps-"${TARGETARCH}" /app/bin/frps

(do rest)
```

## Environmental Variables

| Env | Description | Value |
|-----|-------------|---------|
| `CONFIG_PATH` | Points to frp where the configuration is located inside of the container, required | `` |
| `EXTRA_ARGUMENTS` | Allows to specify extra launch parameters to frp server or client | `` |
