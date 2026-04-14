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
bashio::log.info "Debug: /etc mount info: $(mount | grep ' /etc ' || echo 'not found')"

# Check if /etc is read-only
if grep -q ' /etc .*ro,' /proc/mounts 2>/dev/null; then
    bashio::log.warning "/etc is mounted read-only, attempting to remount rw..."
    mount -o remount,rw /etc 2>/dev/null || bashio::log.error "Remount failed"
fi

# Ensure /etc/telemt directory exists (telemt may try to create it)
if [[ ! -d /etc/telemt ]]; then
    bashio::log.info "Creating /etc/telemt directory..."
    mkdir -p /etc/telemt 2>/dev/null && chmod 777 /etc/telemt || bashio::log.warning "Cannot create /etc/telemt"
fi

# Ensure /etc/telemt.toml is a symlink to our config (force)
if [[ -L /etc/telemt.toml ]]; then
    bashio::log.info "/etc/telemt.toml is a symlink, removing..."
    rm -f /etc/telemt.toml
fi
ln -sf "$CONFIG_PATH" /etc/telemt.toml 2>/dev/null || {
    bashio::log.warning "Symlink failed, copying config to /etc/telemt.toml"
    cp "$CONFIG_PATH" /etc/telemt.toml 2>/dev/null || {
        bashio::log.error "Cannot write to /etc/telemt.toml, trying to create empty file with chmod..."
        touch /etc/telemt.toml 2>/dev/null && chmod 666 /etc/telemt.toml
    }
}

bashio::log.info "Created symlink /etc/telemt.toml -> $CONFIG_PATH"

# Verify write access
if [[ -w /etc/telemt.toml ]]; then
    bashio::log.info "/etc/telemt.toml is writable"
else
    bashio::log.warning "/etc/telemt.toml is not writable, explicit config may fail"
    # Attempt to change permissions
    chmod 666 /etc/telemt.toml 2>/dev/null || true
fi

bashio::log.info "Starting Telemt..."

# Export RUST_LOG if set
export RUST_LOG="$LOG_LEVEL"
# Attempt to disable explicit config creation via environment variables
export TELEMT_EXPLICIT_CONFIG=0
export TELEMT_NO_EXPLICIT_CONFIG=1

# Run telemt with data-path to influence explicit config location
exec telemt --data-path /config "$CONFIG_PATH"