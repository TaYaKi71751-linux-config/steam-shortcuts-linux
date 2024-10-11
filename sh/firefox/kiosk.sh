#!/bin/bash

/usr/bin/flatpak "run" "--branch=stable" "--file-forwarding" "org.mozilla.firefox" "@@u" "@@"  --window-size=1024,640 --force-device-scale-factor=1.25 --device-scale-factor=1.25 --new-window --kiosk "${PAGE_URL}"
