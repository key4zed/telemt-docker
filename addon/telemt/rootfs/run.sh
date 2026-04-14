#!/usr/bin/env bashio

set -e

CONFIG_PATH=/config/telemt.toml

bashio::log.info "Generating Telemt configuration..."

# Ensure config directory exists
mkdir -p /config
chmod 755 /config

# Read options
SECRET=$(bashio::config 'secret')
PORT=$(bashio::config 'port')
ENABLE_METRICS=$(bashio::config 'enable_metrics')
ENABLE_API=$(bashio::config 'enable_api')
LOG_LEVEL=$(bashio::config 'log_level')
NETWORK_MODE=$(bashio::config 'network_mode')

# Validate secret
if [[ -z "$SECRET" ]]; then
    bashio::log.error "Secret is required! Please set a 32-character hex secret in addon configuration."
    exit 1
fi

if [[ ! "$SECRET" =~ ^[a-fA-F0-9]{32}$ ]]; then
    bashio::log.error "Invalid secret format. Must be 32 hex characters."
    exit 1
fi

# Generate telemt.toml
cat > "$CONFIG_PATH" <<EOF
secret = "$SECRET"
port = $PORT
log_level = "$LOG_LEVEL"

[metrics]
enabled = $ENABLE_METRICS
port = 9090

[api]
enabled = $ENABLE_API
port = 9091
EOF

bashio::log.info "Configuration written to $CONFIG_PATH"

# Debug: check permissions and user
bashio::log.info "Debug: running as user $(whoami)"
bashio::log.info "Debug: /etc permissions: $(ls -ld /etc)"
bashio::log.info "Debug: /etc/telemt.toml exists? $(ls -l /etc/telemt.toml 2>/dev/null || echo 'no')"

# Ensure /etc/telemt.toml exists and is writable
if [[ ! -e /etc/telemt.toml ]]; then
    bashio::log.info "Creating /etc/telemt.toml symlink..."
    ln -sf "$CONFIG_PATH" /etc/telemt.toml 2>/dev/null || {
        bashio::log.warning "Symlink failed, copying config to /etc/telemt.toml"
        cp "$CONFIG_PATH" /etc/telemt.toml 2>/dev/null || {
            bashio::log.error "Cannot write to /etc/telemt.toml, checking permissions..."
            touch /etc/telemt.toml 2>/dev/null && rm -f /etc/telemt.toml
        }
    }
fi

# Verify write access
if [[ -w /etc/telemt.toml ]]; then
    bashio::log.info "/etc/telemt.toml is writable"
else
    bashio::log.warning "/etc/telemt.toml is not writable, explicit config may fail"
fi

bashio::log.info "Starting Telemt..."

# Export RUST_LOG if set
export RUST_LOG="$LOG_LEVEL"

# Try to run telemt with explicit config flag
if telemt --help 2>&1 | grep -q -- "--config"; then
    exec telemt --config "$CONFIG_PATH"
else
    # Fallback to positional argument with data-path to influence explicit config location
    exec telemt --data-path /config "$CONFIG_PATH"
fi