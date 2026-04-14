#!/usr/bin/env python3
import base64
import sys

# Simple 1x1 transparent PNG
icon_png = base64.b64decode(b"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
logo_png = base64.b64decode(b"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M/wHwAEBgIA5agATwAAAABJRU5ErkJggg==")

with open('icon.png', 'wb') as f:
    f.write(icon_png)
with open('logo.png', 'wb') as f:
    f.write(logo_png)

print("Icons created (placeholder)")