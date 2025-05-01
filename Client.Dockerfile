ARG     IMAGE_REPOSITORY=public.ecr.aws/docker/library/alpine
ARG     IMAGE_ALPINE_VERSION=edge

FROM    $IMAGE_REPOSITORY:$IMAGE_ALPINE_VERSION AS alpine-builder

ARG     TARGETOS
ARG     TARGETARCH
ARG     ALPINE_REPO_URL=https://dl-cdn.alpinelinux.org/alpine
ARG     ALPINE_REPO_VERSION=edge
ARG     GIT_REPOSITORY=https://github.com/fatedier/frp.git
ARG     GIT_BRANCH=master
ARG     GIT_WORKTREE=/app/worktree
ARG     GOCACHE=/app/go/cache
ARG     CGO_ENABLED=0
ENV     PATH="/usr/local/go/bin:/usr/app/go/bin:${PATH}"

COPY --chmod=0505 /scripts/install-go.sh /app/helper/install-go.sh

WORKDIR /usr/src/frp

RUN apk update \
    && apk upgrade \
    && apk add --virtual build-deps --repository=${ALPINE_REPO_URL}/${ALPINE_REPO_VERSION}/main \
        jq \
        git \
        tar \
        curl \
    && /app/helper/install-go.sh \
    && git clone --branch "${GIT_BRANCH}" "${GIT_REPOSITORY}" . \
    && GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/bin/frpc-${TARGETARCH} -trimpath -ldflags '-w -s' /usr/src/frp/cmd/frpc \
    && apk del --rdepends \
        build-deps \
    && rm -rf \
        /usr/src/frp \
        /app/worktree \
        /app/go/cache \
        /usr/local/go \
        /var/cache/apk

FROM    scratch AS frp-runner

ARG     TARGETARCH

COPY    --from=alpine-builder /app/bin/frpc-${TARGETARCH} /app/bin/frpc

WORKDIR /app
USER    1001:1001

ENTRYPOINT ["/app/bin/frpc"]
