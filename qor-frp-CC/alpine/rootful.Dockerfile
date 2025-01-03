ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=edge

FROM --platform=$TARGETPLATFORM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS alpine-base

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \

ARG CLIENT_VARIANT
ARG FRP_TYPE
ARG GOSU

ENV CONT_UID=1001 \
    CONT_USER=frp_uclient \
    CLIENT_VARIANT=$CLIENT_VARIANT \
    CONFIG_PATH=/app/configs/${CLIENT_VARIANT}.toml \
    GOSU=$GOSU \
    FRP_TYPE=$FRP_TYPE

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

FROM alpine-base AS alpine-builder

WORKDIR /usr/app/frp

ARG TARGETOS
ARG TARGETARCH
ARG GIT_BRANCH

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    GIT_REPOSITORY=https://github.com/fatedier/frp.git \
    CGO_ENABLED=0 \
    GOPATH=/app/go

RUN apk upgrade --no-cache \
    && apk add --no-cache --virtual build-deps --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        jq \
        git \
        tar \
        bash \
        curl \
    && apk add --no-cache --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        ca-certificates \
        openssl \
    && export \
        GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' ) \
    && curl -Lo golang.tar.gz \
        go.dev/dl/"${GO_VERSION}".linux-amd64.tar.gz \
    && tar -C /usr/local \
        -xzf golang.tar.gz \
    && rm \
        golang.tar.gz \
    && export \
        PATH="${PATH}":/usr/local/go/bin:/usr/app/go/bin \
    && mkdir -p \
        "${GOPATH}" \
    && git config \
        --global \
        --add safe.directory '*' \
    && git clone \
        --branch "${GIT_BRANCH}" "${GIT_REPOSITORY}" . \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/app/go/bin/frps-${TARGETARCH} -trimpath -ldflags '-w -s' /usr/app/frp/cmd/frps \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/app/go/bin/frpc-${TARGETARCH} -trimpath -ldflags '-w -s' /usr/app/frp/cmd/frpc \
    && apk del --rdepends \
        build-deps \
    && rm -rf \
        /tmp \
        /app/go/cache \
        /usr/local/go \
        /usr/app/go/frp

FROM --platform=$TARGETPLATFORM docker.io/mrrubberducky/qor-gosu:alpine AS gosu-binary
FROM alpine-base AS alpine-runner

WORKDIR /app

ARG CLIENT_VARIANT
ARG FRP_TYPE
ARG GOSU
ARG TARGETARCH

ENV GOSU=$GOSU \
    FRP_TYPE=$FRP_TYPE \
    CLIENT_VARIANT=$CLIENT_VARIANT

COPY --from=gosu-binary --chmod=0755 /app/gosu /app/bin/gosu
COPY --from=alpine-builder --chmod=0755 /usr/app/go/bin/${CLIENT_VARIANT}-${TARGETARCH} /app/bin/${CLIENT_VARIANT}

ENTRYPOINT /app/scripts/docker-entrypoint.sh
