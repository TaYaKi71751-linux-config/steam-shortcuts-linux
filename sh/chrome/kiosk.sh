#!/bin/bash

/usr/bin/flatpak "run" "--branch=stable" "--arch=x86_64" "--command=/app/bin/edge" "--file-forwarding" "com.microsoft.Edge" "@@u" "@@"  --window-size=1024,640 --force-device-scale-factor=1.25 --device-scale-factor=1.25 --kiosk "${PAGE_URL}"
