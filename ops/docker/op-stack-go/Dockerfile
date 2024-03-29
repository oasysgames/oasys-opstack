# All target images use this as base image, and add the final build results.
# It will default to the target platform.
ARG TARGET_BASE_IMAGE=debian:11.9-slim

# We may be cross-building for another platform. Specify which platform we need as builder.
FROM --platform=$BUILDPLATFORM golang:1.21.3-bullseye as builder

# automatically set by buildkit, can be changed with --platform flag
# Note: This args must not be placed above `FROM`.
#       GOOS and GOARCH will not be able to reference it.
ARG TARGETOS
ARG TARGETARCH

RUN apt update && apt install -y git jq bash ca-certificates

# We copy the go.mod/sum first, so the `go mod download` does not have to re-run if dependencies do not change.
COPY ./go.mod /app/go.mod
COPY ./go.sum /app/go.sum

WORKDIR /app

RUN echo "go mod cache: $(go env GOMODCACHE)"
RUN echo "go build cache: $(go env GOCACHE)"

# warm-up the cache
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build go mod download

# NOTE: the Dockerfile.dockerignore file effectively describes all dependencies
COPY . /app

# We avoid copying the full .git dir into the build for just some metadata.
# Instead, specify:
# --build-arg GIT_COMMIT=$(git rev-parse HEAD)
# --build-arg GIT_DATE=$(git show -s --format='%ct')
ARG GIT_COMMIT
ARG GIT_DATE

# separate docker-builds:
# - op-exporter
# - op-ufm
# - proxyd
# - any JS/TS/smart-contract builds

# Build the Go services, utilizing caches and share the many common packages.
# The "id" defaults to the value of "target", the cache will thus be reused during this build.
# "sharing" defaults to "shared", the cache will thus be available to other concurrent docker builds.
FROM --platform=$BUILDPLATFORM builder as cannon-builder
ARG CANNON_VERSION=v0.0.0
RUN --mount=type=cache,target=/root/.cache/go-build cd cannon && make cannon  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE VERSION="$CANNON_VERSION"

FROM --platform=$BUILDPLATFORM builder as op-program-builder
ARG OP_PROGRAM_VERSION=v0.0.0
# note: we only build the host, that's all the user needs. No Go MIPS cross-build in docker
RUN --mount=type=cache,target=/root/.cache/go-build cd op-program && make op-program-host  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE VERSION="$OP_PROGRAM_VERSION"

FROM --platform=$BUILDPLATFORM builder as op-heartbeat-builder
ARG OP_HEARTBEAT_VERSION=v0.0.0
RUN --mount=type=cache,target=/root/.cache/go-build cd op-heartbeat && make op-heartbeat  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE VERSION="$OP_HEARTBEAT_VERSION"

FROM --platform=$BUILDPLATFORM builder as op-wheel-builder
ARG OP_WHEEL_VERSION=v0.0.0
RUN --mount=type=cache,target=/root/.cache/go-build cd op-wheel && make op-wheel  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE  VERSION="$OP_WHEEL_VERSION"

FROM --platform=$BUILDPLATFORM builder as op-node-builder
ARG OP_NODE_VERSION=v0.0.0
RUN --mount=type=cache,target=/root/.cache/go-build cd op-node && make op-node  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE VERSION="$OP_NODE_VERSION"

FROM --platform=$BUILDPLATFORM builder as op-challenger-builder
ARG OP_CHALLENGER_VERSION=v0.0.0
RUN --mount=type=cache,target=/root/.cache/go-build cd op-challenger && make op-challenger  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE  VERSION="$OP_CHALLENGER_VERSION"

FROM --platform=$BUILDPLATFORM builder as op-batcher-builder
ARG OP_BATCHER_VERSION=v0.0.0
RUN --mount=type=cache,target=/root/.cache/go-build cd op-batcher && make op-batcher  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE  VERSION="$OP_BATCHER_VERSION"

FROM --platform=$BUILDPLATFORM builder as op-proposer-builder
ARG OP_PROPOSER_VERSION=v0.0.0
RUN --mount=type=cache,target=/root/.cache/go-build cd op-proposer && make op-proposer  \
    GOOS=$TARGETOS GOARCH=$TARGETARCH GITCOMMIT=$GIT_COMMIT GITDATE=$GIT_DATE  VERSION="$OP_PROPOSER_VERSION"

# Base layer for all services.
FROM --platform=$TARGETPLATFORM $TARGET_BASE_IMAGE as appbase
COPY --from=builder /etc/ssl /etc/ssl
COPY --from=builder /usr/share/ca-certificates /usr/share/ca-certificates

FROM --platform=$TARGETPLATFORM appbase as cannon-target
COPY --from=cannon-builder /app/cannon/bin/cannon /usr/local/bin/
CMD ["cannon"]

FROM --platform=$TARGETPLATFORM appbase as op-program-target
COPY --from=op-program-builder /app/op-program/bin/op-program /usr/local/bin/
CMD ["op-program"]

FROM --platform=$TARGETPLATFORM appbase as op-heartbeat-target
COPY --from=op-heartbeat-builder /app/op-heartbeat/bin/op-heartbeat /usr/local/bin/
CMD ["op-heartbeat"]

FROM --platform=$TARGETPLATFORM appbase as op-wheel-target
COPY --from=op-wheel-builder /app/op-wheel/bin/op-wheel /usr/local/bin/
CMD ["op-wheel"]

FROM --platform=$TARGETPLATFORM appbase as op-node-target
COPY --from=op-node-builder /app/op-node/bin/op-node /usr/local/bin/
CMD ["op-node"]

FROM --platform=$TARGETPLATFORM appbase as op-challenger-target
COPY --from=op-challenger-builder /app/op-challenger/bin/op-challenger /usr/local/bin/
# Make the bundled op-program the default cannon server
COPY --from=op-program-builder /app/op-program/bin/op-program /usr/local/bin/
ENV OP_CHALLENGER_CANNON_SERVER /usr/local/bin/op-program
# Make the bundled cannon the default cannon executable
COPY --from=cannon-builder /app/cannon/bin/cannon /usr/local/bin/
ENV OP_CHALLENGER_CANNON_BIN /usr/local/bin/cannon
CMD ["op-challenger"]

FROM --platform=$TARGETPLATFORM appbase as op-batcher-target
COPY --from=op-batcher-builder /app/op-batcher/bin/op-batcher /usr/local/bin/
CMD ["op-batcher"]

FROM --platform=$TARGETPLATFORM appbase as op-proposer-target
COPY --from=op-proposer-builder /app/op-proposer/bin/op-proposer /usr/local/bin/
CMD ["op-proposer"]

