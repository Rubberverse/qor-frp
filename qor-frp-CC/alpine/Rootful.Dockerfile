ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=edge

FROM --platform=$BUILDPLATFORM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS alpine-builder
WORKDIR /app

ARG TARGETOS
ARG TARGETARCH

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    GIT_REPOSITORY=https://github.com/fatedier/frp.git \
    GIT_BRANCH=v0.58.0 \
    CGO_ENABLED=0 \
    GOPATH=/app/go

RUN apk upgrade --no-cache \
    && apk add --no-cache --virtual build-deps --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        jq \
        git \
        tar \
        bash \
        curl \
        file \
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        ca-certificates \
        openssl \
    && export GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' ) \
    && curl -LO go.dev/dl/"${GO_VERSION}".linux-amd64.tar.gz \
    && tar -C /usr/local -xzf "${GO_VERSION}".linux-amd64.tar.gz \
    && rm "${GO_VERSION}".linux-amd64.tar.gz \
    && export PATH="${PATH}":/usr/local/go/bin:/app/go/bin \
    && mkdir -p "${GOPATH}" \
    && cd "${GOPATH}" \
    && git config --global --add safe.directory '*' \
    && git clone --branch "${GIT_BRANCH}" "${GIT_REPOSITORY}" \
    && cd frp \
    && git init \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/go/bin/frps-${TARGETARCH} -trimpath -ldflags '-w -s' ./cmd/frps \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/go/bin/frpc-${TARGETARCH} -trimpath -ldflags '-w -s' ./cmd/frpc \
    && file /app/go/bin/frps-"${TARGETARCH}" \
    && file /app/go/bin/frpc-"${TARGETARCH}" \
    && apk del --rdepends \
        build-deps \
    && rm -rf /app/go/cache /tmp /usr/local/go /app/go/frp

FROM --platform=${TARGETPLATFORM} docker.io/mrrubberducky/qor-gosu:alpine AS qor-gosu
FROM --platform=${TARGETPLATFORM} docker.io/library/alpine:edge AS qor-frpc
WORKDIR /app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
	CLIENT_VARIANT=frpc

ENV CONT_USER=frp_uclient \
    CONT_UID=1001 \
	CONFIG_PATH=/app/configs/${CLIENT_VARIANT}.toml

ARG TARGETARCH

COPY --from=qor-gosu --chmod=0755 /app/gosu /app/bin/gosu
COPY --from=alpine-builder --chmod=0755 /app/go/bin/${CLIENT_VARIANT}-${TARGETARCH} /app/bin/${CLIENT_VARIANT}

COPY --chmod=755 ../scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

RUN apk upgrade --no-cache \
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        ca-certificates \
        openssl \
    && update-ca-certificates \
    && adduser \
        --home "/app" \
        --shell "/bin/sh" \
        --uid "$CONT_UID"  \
        --disabled-password \
        --no-create-home \
        "$CONT_USER" \
    && mkdir -p /app/certs

ENTRYPOINT /app/scripts/docker-entrypoint.sh
