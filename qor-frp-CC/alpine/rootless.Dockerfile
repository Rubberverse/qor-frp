ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=edge

# ==================================================== #
# Base image
# ==================================================== #
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

# ==================================================== #
# Builder
# ==================================================== #
FROM alpine-base AS alpine-builder

WORKDIR /usr/app

ARG TARGETOS
ARG TARGETARCH

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    GIT_REPOSITORY=https://github.com/fatedier/frp.git \
    GIT_BRANCH="" \
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
    && export PATH="${PATH}":/usr/local/go/bin:/usr/app/go/bin \
    && mkdir -p "${GOPATH}" \
    && cd "${GOPATH}" \
    && git config --global --add safe.directory '*' \
    && git clone --branch "${GIT_BRANCH}" "${GIT_REPOSITORY}" \
    && cd frp \
    && git init \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/app/go/bin/frps-${TARGETARCH} -trimpath -ldflags '-w -s' ./cmd/frps \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/app/go/bin/frpc-${TARGETARCH} -trimpath -ldflags '-w -s' ./cmd/frpc \
    && file /usr/app/go/bin/frps-"${TARGETARCH}" \
    && file /usr/app/go/bin/frpc-"${TARGETARCH}" \
    && apk del --rdepends \
        build-deps \
    && rm -rf /app/go/cache /tmp /usr/local/go /usr/app/go/frp

# ==================================================== #
# Runner
# ==================================================== #
FROM alpine-base AS alpine-runner

WORKDIR /app

ARG CLIENT_VARIANT
ARG FRP_TYPE
ARG GOSU
ARG TARGETARCH

ENV GOSU=$GOSU \
    FRP_TYPE=$FRP_TYPE \
    CLIENT_VARIANT=$CLIENT_VARIANT

COPY --from=alpine-builder --chmod=0755 /usr/app/go/bin/${CLIENT_VARIANT}-${TARGETARCH} /app/bin/${CLIENT_VARIANT}

USER ${CONT_USER}

ENTRYPOINT /app/scripts/docker-entrypoint.sh
