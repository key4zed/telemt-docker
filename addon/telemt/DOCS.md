# Telemt MTProxy Add-on

A Home Assistant add-on for running a fast MTProto proxy server (MTProxy) written in Rust.

## Features

- **Secure by default**: Runs as non-root user where possible.
- **Easy configuration**: Set up via the add‑on UI.
- **Metrics & API**: Optional Prometheus‑style metrics and REST API.
- **Multi‑arch**: Supports `amd64` and `arm64`.

## Configuration

### Required

- **Secret** – A 32‑character hex string (16 bytes). Generate one with:
  ```bash
  openssl rand -hex 16
  ```

### Optional

- **Port** – The port Telemt will listen on (default: `443`).
- **Enable metrics** – Expose Prometheus metrics on port `9090` (default: `true`).
- **Enable API** – Expose a REST API on port `9091` (default: `true`).
- **Log level** – Rust log level (`info`, `debug`, `warn`, `error`, `trace`).
- **Network mode** – `host` (share host network) or `bridge` (Docker‑managed ports).

## Network notes

- When using **host** mode, the add‑on binds directly to the host’s network stack. Port mapping in the add‑on UI is ignored.
- When using **bridge** mode, you can map container ports to host ports via the `ports` section in `config.yaml`.

## Privileged ports

If you choose a port below 1024 (e.g., 443) and the add‑on fails with `Permission denied`, you may need to run the container as `root`. This add‑on uses the upstream `whn0thacked/telemt-docker` image, which by default runs as `nonroot`. To bind to privileged ports, the add‑on automatically adds the `NET_BIND_SERVICE` capability.

## Volumes

The add‑on stores its configuration in `/config/telemt.toml` inside the container. This file is generated from the UI options and persists across restarts.

## Logs

Logs are available in the add‑on’s **Log** tab. You can adjust verbosity with the `log_level` option.

## Integration with Home Assistant

A companion custom component (`telemt`) is available to expose Telemt as entities (switch, sensors) inside Home Assistant.

## References

- [Telemt upstream](https://github.com/telemt/telemt)
- [Docker image](https://hub.docker.com/r/whn0thacked/telemt-docker)
- [MTProxy ad tag bot](https://t.me/mtproxybot)