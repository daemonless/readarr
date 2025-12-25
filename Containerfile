ARG BASE_VERSION=15
FROM ghcr.io/daemonless/arr-base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG PACKAGES="readarr"
LABEL org.opencontainers.image.title="Readarr" \
    org.opencontainers.image.description="Readarr ebook management on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/readarr" \
    org.opencontainers.image.url="https://readarr.com/" \
    org.opencontainers.image.documentation="https://wiki.servarr.com/readarr" \
    org.opencontainers.image.licenses="GPL-3.0-only" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="8787" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.volumes="/books,/downloads" \
    org.freebsd.jail.allow.mlock="required" \
    io.daemonless.category="Media Management" \
    io.daemonless.upstream-mode="servarr" \
    io.daemonless.upstream-url="https://readarr.servarr.com/v1/update/develop/changes?os=bsd" \
    io.daemonless.packages="${PACKAGES}"

ARG READARR_BRANCH="develop"

# Install Readarr from FreeBSD packages
RUN pkg update && \
    pkg install -y ${PACKAGES}

# Download and install Readarr
RUN mkdir -p /usr/local/share/readarr && \
    READARR_VERSION=$(fetch -qo - "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/changes?os=bsd&runtime=netcore" | \
    grep -o '"version":"[^"]*"' | head -n 1 | cut -d '"' -f 4) && \
    fetch -qo - "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/updatefile?os=bsd&arch=x64&runtime=netcore" | \
    tar xzf - -C /usr/local/share/readarr --strip-components=1 && \
    rm -rf /usr/local/share/readarr/Readarr.Update && \
    chmod +x /usr/local/share/readarr/Readarr && \
    chmod -R o+rX /usr/local/share/readarr && \
    printf "UpdateMethod=docker\nBranch=${READARR_BRANCH}\nPackageVersion=%s\nPackageAuthor=[daemonless](https://github.com/daemonless/daemonless)\n" "$READARR_VERSION" > /usr/local/share/readarr/package_info && \
    mkdir -p /app && echo "$READARR_VERSION" > /app/version

# Create config directory
RUN mkdir -p /config && \
    chown -R bsd:bsd /usr/local/share/readarr /config

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/readarr/run /etc/cont-init.d/* 2>/dev/null || true

EXPOSE 8787
VOLUME /config


