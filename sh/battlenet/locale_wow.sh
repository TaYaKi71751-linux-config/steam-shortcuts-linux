#!/bin/bash

__GAME_NAME__="battlenet"

CONFIG_WTF="$(cat "$HOME/Games/${__GAME_NAME__}/drive_c/Program Files (x86)/World of Warcraft/_retail_/WTF/Config.wtf")"
echo "" | tee "$HOME/Games/${__GAME_NAME__}/drive_c/Program Files (x86)/World of Warcraft/_retail_/WTF/Config.wtf"
while IFS= read -r LINE
do
	if (echo "$LINE" | grep textLocale);then
		echo "SET textLocale \"${LOCALE}\"" >> "${HOME}/Games/${__GAME_NAME__}/drive_c/Program Files (x86)/World of Warcraft/_retail_/WTF/Config.wtf"
	fi
done < <(printf '%s\n' "${CONFIG_WTF}")
