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

# Try to create symlink in /etc (may fail due to permissions)
ln -sf "$CONFIG_PATH" /etc/telemt.toml 2>/dev/null || bashio::log.warning "Could not create symlink in /etc, but continuing..."

bashio::log.info "Configuration written to $CONFIG_PATH"
bashio::log.info "Starting Telemt..."

# Export RUST_LOG if set
export RUST_LOG="$LOG_LEVEL"

# Try to run telemt with explicit config flag
if telemt --help 2>&1 | grep -q -- "--config"; then
    exec telemt --config "$CONFIG_PATH"
else
    # Fallback to positional argument
    exec telemt "$CONFIG_PATH"
fi