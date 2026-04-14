# syntax=docker/dockerfile:1.7

ARG TELEMT_VERSION=3.3.31

FROM --platform=$TARGETPLATFORM alpine:latest AS fetch

ARG TELEMT_VERSION
ARG TARGETARCH

RUN apk add --no-cache ca-certificates curl upx \
    && update-ca-certificates

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64)   ARCH=x86_64  ;; \
      arm64)   ARCH=aarch64 ;; \
      *) echo "unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    \
    BASE_URL="https://github.com/telemt/telemt/releases/download/${TELEMT_VERSION}"; \
    TARBALL="telemt-${ARCH}-linux-musl.tar.gz"; \
    \
    echo "=== Downloading ${TARBALL} ==="; \
    curl -fsSL -o "/tmp/${TARBALL}"        "${BASE_URL}/${TARBALL}"; \
    curl -fsSL -o "/tmp/${TARBALL}.sha256"  "${BASE_URL}/${TARBALL}.sha256"; \
    \
    echo "=== Verifying checksum ==="; \
    cd /tmp && sha256sum -c "${TARBALL}.sha256"; \
    \
    echo "=== Extracting ==="; \
    mkdir -p /out; \
    tar -xzf "/tmp/${TARBALL}" -C /out; \
    chmod 755 /out/telemt; \
    \
    echo "=== Verifying static linkage ==="; \
    if readelf -lW /out/telemt 2>/dev/null | grep -q "Requesting program interpreter"; then \
      echo "ERROR: telemt is dynamically linked -> cannot run in distroless/static"; \
      exit 1; \
    fi

RUN set -eux; \
    echo "=== Before UPX ===" && ls -lh /out/telemt; \
    upx --ultra-brute --preserve-build-id /out/telemt; \
    echo "=== After UPX ===" && ls -lh /out/telemt; \
    echo "=== Integrity check ===" && upx -t /out/telemt

FROM gcr.io/distroless/static:nonroot AS runtime

STOPSIGNAL SIGINT

COPY --from=fetch /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=fetch /out/telemt /usr/local/bin/telemt

WORKDIR /tmp

EXPOSE 443/tcp 9090/tcp

USER nonroot:nonroot
ENTRYPOINT ["/usr/local/bin/telemt"]
CMD ["/etc/telemt/telemt.toml"]
