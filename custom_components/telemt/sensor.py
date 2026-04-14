"""Sensor platform for Telemt."""
from __future__ import annotations

import logging
from typing import Any

from homeassistant.components.sensor import SensorEntity
from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddEntitiesCallback

from .const import (
    DOMAIN,
    ATTR_CONNECTIONS,
    ATTR_UPTIME,
    ATTR_TRAFFIC_IN,
    ATTR_TRAFFIC_OUT,
)

_LOGGER = logging.getLogger(__name__)

SENSOR_TYPES = {
    "connections": ("Connections", "connections", "mdi:account-group"),
    "uptime": ("Uptime", "s", "mdi:timer"),
    "traffic_in": ("Traffic In", "MB", "mdi:download"),
    "traffic_out": ("Traffic Out", "MB", "mdi:upload"),
}


async def async_setup_entry(
    hass: HomeAssistant,
    entry: ConfigEntry,
    async_add_entities: AddEntitiesCallback,
) -> None:
    """Set up Telemt sensors based on a config entry."""
    sensors = []
    for key, (name, unit, icon) in SENSOR_TYPES.items():
        sensors.append(TelemtSensor(entry, key, name, unit, icon))
    async_add_entities(sensors)


class TelemtSensor(SensorEntity):
    """Representation of a Telemt sensor."""

    def __init__(
        self,
        entry: ConfigEntry,
        sensor_type: str,
        name: str,
        unit: str,
        icon: str,
    ) -> None:
        """Initialize the sensor."""
        self._entry = entry
        self._sensor_type = sensor_type
        self._attr_name = f"Telemt {name}"
        self._attr_unique_id = f"{entry.entry_id}-sensor-{sensor_type}"
        self._attr_native_unit_of_measurement = unit
        self._attr_icon = icon
        self._attr_native_value = None

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
        """Update sensor state."""
        # TODO: Poll Telemt API for metrics
        # Placeholder values
        if self._sensor_type == "connections":
            self._attr_native_value = 0
        elif self._sensor_type == "uptime":
            self._attr_native_value = 3600
        elif self._sensor_type == "traffic_in":
            self._attr_native_value = 12.5
        elif self._sensor_type == "traffic_out":
            self._attr_native_value = 8.2