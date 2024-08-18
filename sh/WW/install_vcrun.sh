#!/bin/bash

__GAME_NAME__="WutheringWaves"
__LAUNCHER_PACKAGE__="moe.launcher.wavey-launcher"
__LAUNCHER_NAME__="wavey-launcher"

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}

auto_path wine

mkdir -p "${HOME}/${__GAME_NAME__}/vcrun"
cd "${HOME}/${__GAME_NAME__}/vcrun"
rm *.exe

wget "https://download.microsoft.com/download/0/6/4/064F84EA-D1DB-4EAA-9A5C-CC2F0FF6A638/vc_redist.x64.exe"
wget "https://download.microsoft.com/download/0/6/4/064F84EA-D1DB-4EAA-9A5C-CC2F0FF6A638/vc_redist.x86.exe"


WINEPREFIX="${HOME}/${__GAME_NAME__}/prefix" wine "${HOME}/${__GAME_NAME__}/vcrun/vc_redist.x86.exe"
WINEPREFIX="${HOME}/${__GAME_NAME__}/prefix" wine "${HOME}/${__GAME_NAME__}/vcrun/vc_redist.x64.exe"
