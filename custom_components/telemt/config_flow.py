"""Config flow for Telemt integration."""
from __future__ import annotations

import logging
from typing import Any

import aiohttp
import voluptuous as vol

from homeassistant import config_entries
from homeassistant.const import CONF_HOST, CONF_PORT
from homeassistant.data_entry_flow import FlowResult
import homeassistant.helpers.config_validation as cv

from .const import (
    DOMAIN,
    DEFAULT_PORT,
    DEFAULT_METRICS_PORT,
    DEFAULT_API_PORT,
    CONF_SECRET,
    CONF_METRICS_PORT,
    CONF_API_PORT,
)

_LOGGER = logging.getLogger(__name__)

STEP_USER_DATA_SCHEMA = vol.Schema(
    {
        vol.Required(CONF_HOST, default="localhost"): cv.string,
        vol.Required(CONF_PORT, default=DEFAULT_PORT): cv.port,
        vol.Required(CONF_SECRET): cv.string,
        vol.Optional(CONF_METRICS_PORT, default=DEFAULT_METRICS_PORT): cv.port,
        vol.Optional(CONF_API_PORT, default=DEFAULT_API_PORT): cv.port,
    }
)


class TelemtConfigFlow(config_entries.ConfigFlow, domain=DOMAIN):
    """Handle a config flow for Telemt."""

    VERSION = 1

    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> FlowResult:
        """Handle the initial step."""
        errors: dict[str, str] = {}

        if user_input is not None:
            # Validate secret format
            secret = user_input[CONF_SECRET]
            if not (len(secret) == 32 and all(c in "0123456789abcdefABCDEF" for c in secret)):
                errors[CONF_SECRET] = "invalid_secret_format"
            else:
                # Try to connect to Telemt API
                try:
                    await self._test_connection(user_input)
                except aiohttp.ClientError:
                    errors["base"] = "cannot_connect"
                except Exception:  # pylint: disable=broad-except
                    _LOGGER.exception("Unexpected exception")
                    errors["base"] = "unknown"
                else:
                    return self.async_create_entry(
                        title=f"Telemt {user_input[CONF_HOST]}:{user_input[CONF_PORT]}",
                        data=user_input,
                    )

        return self.async_show_form(
            step_id="user",
            data_schema=STEP_USER_DATA_SCHEMA,
            errors=errors,
        )

    async def _test_connection(self, config: dict[str, Any]) -> None:
        """Test connection to Telemt API."""
        host = config[CONF_HOST]
        port = config[CONF_API_PORT]
        url = f"http://{host}:{port}/api/v1/status"
        async with aiohttp.ClientSession() as session:
            async with session.get(url, timeout=10) as response:
                response.raise_for_status()
                # Expect JSON response
                await response.json()