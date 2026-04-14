"""The Telemt integration."""
from __future__ import annotations

import logging

from homeassistant.config_entries import ConfigEntry
from homeassistant.const import Platform
from homeassistant.core import HomeAssistant

from .const import DOMAIN

_LOGGER = logging.getLogger(__name__)

PLATFORMS: list[Platform] = [Platform.SWITCH, Platform.SENSOR, Platform.BINARY_SENSOR]


async def async_setup_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    """Set up Telemt from a config entry."""
    hass.data.setdefault(DOMAIN, {})
    hass.data[DOMAIN][entry.entry_id] = entry.data

    # Forward to platforms
    await hass.config_entries.async_forward_entry_setups(entry, PLATFORMS)

    # Register services
    await _setup_services(hass, entry)

    return True


async def async_unload_entry(hass: HomeAssistant, entry: ConfigEntry) -> bool:
    """Unload a config entry."""
    unload_ok = await hass.config_entries.async_unload_platforms(entry, PLATFORMS)
    if unload_ok:
        hass.data[DOMAIN].pop(entry.entry_id)
    return unload_ok


async def _setup_services(hass: HomeAssistant, entry: ConfigEntry) -> None:
    """Set up services for Telemt."""

    async def handle_restart(call):
        """Handle restart service."""
        _LOGGER.info("Restarting Telemt")
        # TODO: Implement API call

    async def handle_reload_config(call):
        """Handle reload config service."""
        _LOGGER.info("Reloading Telemt config")
        # TODO: Implement API call

    async def handle_generate_secret(call):
        """Handle generate secret service."""
        _LOGGER.info("Generating new secret")
        # TODO: Implement secret generation

    hass.services.async_register(DOMAIN, "restart", handle_restart)
    hass.services.async_register(DOMAIN, "reload_config", handle_reload_config)
    hass.services.async_register(DOMAIN, "generate_secret", handle_generate_secret)