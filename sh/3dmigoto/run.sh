#!/bin/bash

mkdir -p "$HOME/Games/genshin-impact/prefix/drive_c/"
__GI_PATH__="$(find / -name 'GenshinImpact.exe' -type f | tail -n 1)"
echo $__GI_PATH__
ln -sf "$(dirname "$__GI_PATH__")" "$HOME/Games/genshin-impact/prefix/drive_c/"
__3DMIGOTO_PATH__="$(find $HOME/ -name '3DMigoto Loader.exe' | tail -n 1)"
echo $__3DMIGOTO_PATH__
ln -sf "$(dirname "$__3DMIGOTO_PATH__")" "$HOME/Games/genshin-impact/prefix/drive_c/"

GI_CONF_PATHS="$(find $HOME/.var/app/net.lutris.Lutris/data/lutris/games/ -name 'genshin-impact-*.yml')"

echo ${GI_CONF_PATHS}
while IFS= read -r GI_CONF_PATH
do
 echo $GI_CONF_PATH
echo "game:" > $GI_CONF_PATH
echo "  exe: $HOME/Games/genshin-impact/prefix/drive_c/GenshinImpact.bat" >> $GI_CONF_PATH
echo "  prefix: $HOME/Games/genshin-impact/prefix/" >> $GI_CONF_PATH
echo "wine:" >> $GI_CONF_PATH
echo "  battleye: false" >> $GI_CONF_PATH
echo "  dxvk_nvapi: false" >> $GI_CONF_PATH
echo "  eac: false" >> $GI_CONF_PATH
echo "  fsr: false" >> $GI_CONF_PATH
echo "  vkd3d: false" >> $GI_CONF_PATH
done < <(printf '%s\n' "${GI_CONF_PATHS}")

export BATCH_PATH="${HOME}/Games/genshin-impact/prefix/drive_c/GenshinImpact.bat"

echo "cd C:\\3dmigoto" > $BATCH_PATH
echo "start \"\" \"3DMigoto Loader.exe\"" >> $BATCH_PATH
echo "cd C:\\Genshin Impact" >> $BATCH_PATH
echo "start \"\" GenshinImpact.exe" >> $BATCH_PATH


flatpak run "net.lutris.Lutris" "lutris:genshin-impact-standard"
