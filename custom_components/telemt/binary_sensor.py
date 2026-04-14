"""Binary sensor platform for Telemt."""
from __future__ import annotations

import logging
from typing import Any

from homeassistant.components.binary_sensor import BinarySensorEntity
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
    """Set up Telemt binary sensor based on a config entry."""
    async_add_entities([TelemtBinarySensor(entry)])


class TelemtBinarySensor(BinarySensorEntity):
    """Representation of a Telemt binary sensor (status)."""

    def __init__(self, entry: ConfigEntry) -> None:
        """Initialize the binary sensor."""
        self._entry = entry
        self._attr_name = "Telemt Status"
        self._attr_unique_id = f"{entry.entry_id}-binary-sensor"
        self._attr_is_on = False
        self._attr_device_class = "connectivity"

    @property
    def device_info(self) -> dict[str, Any]:
        """Return device information."""
        return {
            "identifiers": {(DOMAIN, self._entry.entry_id)},
            "name": "Telemt MTProxy",
            "manufacturer": "Telemt",
            "model": "MTProxy",
        }

    async def async_update(self) -> None:
        """Update binary sensor state."""
        # TODO: Poll Telemt API for status
        # Placeholder: assume it's on if we can reach API
        self._attr_is_on = True