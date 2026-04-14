"""Constants for the Telemt integration."""

DOMAIN = "telemt"
DEFAULT_NAME = "Telemt MTProxy"
DEFAULT_PORT = 443
DEFAULT_METRICS_PORT = 9090
DEFAULT_API_PORT = 9091

CONF_SECRET = "secret"
CONF_PORT = "port"
CONF_METRICS_PORT = "metrics_port"
CONF_API_PORT = "api_port"
CONF_HOST = "host"

ATTR_CONNECTIONS = "connections"
ATTR_UPTIME = "uptime"
ATTR_TRAFFIC_IN = "traffic_in"
ATTR_TRAFFIC_OUT = "traffic_out"

SERVICE_RESTART = "restart"
SERVICE_RELOAD_CONFIG = "reload_config"
SERVICE_GENERATE_SECRET = "generate_secret"