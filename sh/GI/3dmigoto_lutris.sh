#!/bin/bash

__GAME_NAME__="genshin-impact"
__GI_PATH__="$(find / -name 'GenshinImpact.exe' -type f | tail -n 1)"
echo $__GI_PATH__
ln -sf "$(dirname "$__GI_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"
__3DMIGOTO_PATH__="$(find $HOME/ -name '3DMigoto Loader.exe' | tail -n 1)"
echo $__3DMIGOTO_PATH__
ln -sf "$(dirname "$__3DMIGOTO_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"

GI_CONF_PATHS="$(find $HOME/.var/app/net.lutris.Lutris/data/lutris/games/ -name 'genshin-impact-*.yml')"
GI_CONF_PATHS="$(find $HOME/.var/app/net.lutris.Lutris/data/lutris/games/ -name "${__GAME_NAME__}-*.yml")"

echo ${GI_CONF_PATHS}
while IFS= read -r GI_CONF_PATH
do
 echo $GI_CONF_PATH
echo "game:" > $GI_CONF_PATH
echo "  exe: $HOME/Games/genshin-impact/drive_c/GenshinImpact.bat" >> $GI_CONF_PATH
echo "  prefix: $HOME/Games/genshin-impact/" >> $GI_CONF_PATH
echo "  exe: $HOME/Games/${__GAME_NAME__}/drive_c/GenshinImpact.bat" >> $GI_CONF_PATH
echo "  prefix: $HOME/Games/${__GAME_NAME__}/" >> $GI_CONF_PATH
echo "wine:" >> $GI_CONF_PATH
echo "  battleye: false" >> $GI_CONF_PATH
echo "  dxvk_nvapi: false" >> $GI_CONF_PATH
echo "  eac: false" >> $GI_CONF_PATH
echo "  fsr: false" >> $GI_CONF_PATH
echo "  vkd3d: false" >> $GI_CONF_PATH
done < <(printf '%s\n' "${GI_CONF_PATHS}")

export BATCH_PATH="${HOME}/Games/${__GAME_NAME__}/drive_c/GenshinImpact.bat"

echo "cd C:\\$(dirname "${__3DMIGOTO_PATH__}" | rev | cut -d '/' -f1 | rev)" > $BATCH_PATH
echo "start \"\" \"3DMigoto Loader.exe\"" >> $BATCH_PATH
echo "cd C:\\$(dirname "${__GI_PATH__}" | rev | cut -d '/' -f1 | rev)" >> $BATCH_PATH
echo "start \"\" GenshinImpact.exe" >> $BATCH_PATH


flatpak run "net.lutris.Lutris" "lutris:genshin-impact-standard"
