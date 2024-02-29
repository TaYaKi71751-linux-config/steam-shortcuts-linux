#!/bin/bash

curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/uninstall.sh | sh
pkill -9 steam
pkill steam
