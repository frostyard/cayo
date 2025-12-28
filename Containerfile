# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/frostyard/debian-bootc-core:latest

COPY system_files /

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_ID=${BUILD_ID}
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=cache,dst=/var/lib/apt \
    --mount=type=cache,dst=/var/lib/dpkg/updates \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build && \
    /ctx/shared/build-initramfs && \
    /ctx/shared/finalize

# DEBUGGING
# RUN apt update -y && apt install -y whois
# RUN usermod -p "$(echo "changeme" | mkpasswd -s)" root

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
RUN nbc lint --local
