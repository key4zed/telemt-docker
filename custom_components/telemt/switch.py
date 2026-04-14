"""Switch platform for Telemt."""
from __future__ import annotations

import logging
from typing import Any

from homeassistant.components.switch import SwitchEntity
from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddEntitiesCallback

from .const import DOMAIN

_LOGGER = logging.getLogger(__name__)


async def async_setup_entry(
    hass: HomeAssistant,
    entry: ConfigEntry,
    async_add_entities: AddEntitiesCallback,
) -> None:
    """Set up Telemt switch based on a config entry."""
    async_add_entities([TelemtSwitch(entry)])


class TelemtSwitch(SwitchEntity):
    """Representation of a Telemt switch."""

    def __init__(self, entry: ConfigEntry) -> None:
        """Initialize the switch."""
        self._entry = entry
        self._attr_name = f"Telemt Proxy"
        self._attr_unique_id = f"{entry.entry_id}-switch"
        self._attr_is_on = False

    @property
    def device_info(self) -> dict[str, Any]:
        """Return device information."""
        return {
            "identifiers": {(DOMAIN, self._entry.entry_id)},
            "name": "Telemt MTProxy",
            "manufacturer": "Telemt",
            "model": "MTProxy",
        }

    async def async_turn_on(self, **kwargs: Any) -> None:
        """Turn the switch on."""
        # TODO: Implement API call to start Telemt
        self._attr_is_on = True
        self.async_write_ha_state()

    async def async_turn_off(self, **kwargs: Any) -> None:
        """Turn the switch off."""
        # TODO: Implement API call to stop Telemt
        self._attr_is_on = False
        self.async_write_ha_state()

    async def async_update(self) -> None:
        """Update switch state."""
        # TODO: Poll Telemt API for status
        pass