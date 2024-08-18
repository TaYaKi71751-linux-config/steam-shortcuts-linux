#!/bin/bash

__GAME_NAME__="WutheringWaves"
__LAUNCHER_PACKAGE__="moe.launcher.wavey-launcher"
__LAUNCHER_NAME__="wavey-launcher"

mkdir -p "${HOME}/${__GAME_NAME__}/vcrun"
cd "${HOME}/${__GAME_NAME__}/vcrun"
rm *.exe

wget "https://download.microsoft.com/download/0/6/4/064F84EA-D1DB-4EAA-9A5C-CC2F0FF6A638/vc_redist.x64.exe"
wget "https://download.microsoft.com/download/0/6/4/064F84EA-D1DB-4EAA-9A5C-CC2F0FF6A638/vc_redist.x86.exe"


WINEPREFIX="${HOME}/${__GAME_NAME__}/prefix" wine "${HOME}/${__GAME_NAME__}/vc_redist.x86.exe"
WINEPREFIX="${HOME}/${__GAME_NAME__}/prefix" wine "${HOME}/${__GAME_NAME__}/vc_redist.x64.exe"
