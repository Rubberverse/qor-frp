ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_ALPINE_VERSION=edge

FROM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS alpine-builder

WORKDIR /usr/app/frp

ARG TARGETOS
ARG TARGETARCH
ARG GIT_BRANCH
ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    GIT_REPOSITORY=https://github.com/fatedier/frp.git \
    CGO_ENABLED=0 \
    GOPATH=/app/go

RUN apk update \ 
    && apk upgrade \
    && apk add --virtual build-deps --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        jq \
        git \
        tar \
        curl \
    # Grab latest Go version
    && export GO_VERSION=$(curl https://go.dev/dl/?mode=json | jq -r '.[0].version' ) \
    # Download it using curl
    && curl -Lo golang.tar.gz go.dev/dl/"${GO_VERSION}".linux-amd64.tar.gz \
    # Extract it, then remove the leftover tar.gz file
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz \
    # Export path so we don't need to constantly reference it during build
    && export PATH="${PATH}":/usr/local/go/bin:/usr/app/go/bin \
    && mkdir -p "${GOPATH}" \
    # This is to work over Go build failing due to Git being 'untrusted' or whatever
    && git config --global --add safe.directory '*' \
    # Clone fatedier/frp repository to current directory
    && git clone --branch "${GIT_BRANCH}" "${GIT_REPOSITORY}" . \
    # Build binaries for frpc and frps
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/app/go/bin/frps-${TARGETARCH} -trimpath -ldflags '-w -s' /usr/app/frp/cmd/frps \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/app/go/bin/frpc-${TARGETARCH} -trimpath -ldflags '-w -s' /usr/app/frp/cmd/frpc \
    # Remove build deps aftertwards and remove leftover folders
    && apk del --rdepends \
        build-deps \
    && rm -rf \
        /tmp \
        /app/go/cache \
        /usr/local/go \
        /usr/app/go/frp \
        /var/cache/apk

FROM $IMAGE_REPOSITORY/alpine:$IMAGE_ALPINE_VERSION AS alpine-runner
LABEL org.opencontainers.image.source https://github.com/Rubberverse/qor-frp
WORKDIR /app

ARG ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine \
    ALPINE_REPO_VERSION=edge \
    CONT_UID=1001
ARG CLIENT_VARIANT
ARG FRP_TYPE
ARG TARGETARCH

ENV EXTRA_ARGUMENTS
ENV CONT_USER=frp_uclient \
    CLIENT_VARIANT=$CLIENT_VARIANT \
    CONFIG_PATH=/app/configs/${CLIENT_VARIANT}.toml \
    FRP_TYPE=$FRP_TYPE \
    CLIENT_VARIANT=${CLIENT_VARIANT} \
    TZ="Europe/Warsaw"

RUN apk update \
    && apk upgrade \
    && apk add --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        ca-certificates \
        openssl \
        tzdata \
    && addgroup \
        --system \
        --gid ${CONT_UID} \
        ${CONT_USER} \
    && adduser \
        --home "/app" \
        --shell "/bin/false" \
        --uid ${CONT_UID}  \
        --ingroup ${CONT_USER} \
        --disabled-password \
        --no-create-home \
        ${CONT_USER} \
    && rm -rf /var/cache/apt

COPY --from=alpine-builder --chmod=0755 /usr/app/go/bin/${CLIENT_VARIANT}-${TARGETARCH} /app/bin/${CLIENT_VARIANT}
COPY --chmod=755 ../scripts/docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

USER ${CONT_USER}
ENTRYPOINT /app/scripts/docker-entrypoint.sh
