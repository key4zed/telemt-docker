#!/usr/bin/env bashio

set -e

CONFIG_PATH=/run/telemt/config.toml

bashio::log.info "Generating Telemt configuration..."

# Ensure /run/telemt directory exists (tmpfs should be mounted)
if [[ ! -d /run/telemt ]]; then
    bashio::log.info "Creating /run/telemt directory..."
    mkdir -p /run/telemt 2>/dev/null || bashio::log.warning "Cannot create /run/telemt"
fi

# Ensure it's writable
chmod 1777 /run/telemt 2>/dev/null || true

# Create /etc/telemt directory (tmpfs on /etc should allow writing)
if [[ ! -d /etc/telemt ]]; then
    bashio::log.info "Creating /etc/telemt directory..."
    mkdir -p /etc/telemt 2>/dev/null || bashio::log.warning "Cannot create /etc/telemt"
fi

# Create symlink /etc/telemt.toml -> /run/telemt/config.toml to satisfy telemt's explicit config
bashio::log.info "Creating symlink /etc/telemt.toml -> $CONFIG_PATH"
ln -sf "$CONFIG_PATH" /etc/telemt.toml 2>/dev/null || bashio::log.warning "Cannot create symlink"

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

# Generate config.toml
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
bashio::log.info "Debug: /run/telemt permissions: $(ls -ld /run/telemt)"
bashio::log.info "Debug: /run/telemt/config.toml permissions: $(ls -l /run/telemt/config.toml 2>/dev/null || echo 'no')"

# Ensure config is readable (read-only for safety)
chmod 644 "$CONFIG_PATH" 2>/dev/null || true

bashio::log.info "Starting Telemt..."

# Export RUST_LOG if set
export RUST_LOG="$LOG_LEVEL"
# Attempt to disable explicit config creation via environment variables
export TELEMT_EXPLICIT_CONFIG=0
export TELEMT_NO_EXPLICIT_CONFIG=1

# Run telemt with the configuration file path (as per official Docker image)
exec telemt "$CONFIG_PATH"