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

auto_path winetricks
auto_path wine

WINEPREFIX="${HOME}/${__GAME_NAME__}/prefix" winetricks -q vcrun2019
