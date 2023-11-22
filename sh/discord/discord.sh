#!/bin/bash

/usr/bin/flatpak "run" "--branch=stable" "--command=/app/bin/discord" "--file-forwarding" "com.discordapp.Discord" "@@u" "@@"
