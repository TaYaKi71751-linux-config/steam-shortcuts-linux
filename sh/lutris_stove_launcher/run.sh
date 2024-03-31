#!/bin/bash

GI_CONF_PATHS="$(find $HOME/.var/app/net.lutris.Lutris/data/lutris/games/ -name 'stove-launcher-*.yml')"

echo ${GI_CONF_PATHS}
while IFS= read -r GI_CONF_PATH
do
 echo $GI_CONF_PATH
echo "game:" > $GI_CONF_PATH
echo "  exe: $HOME/Games/stove-launcher/drive_c/Program Files (x86)/Smilegate/STOVE/STOVE.exe" >> $GI_CONF_PATH
echo "  prefix: $HOME/Games/genshin-impact/prefix/" >> $GI_CONF_PATH
echo "wine:" >> $GI_CONF_PATH
echo "  battleye: false" >> $GI_CONF_PATH
echo "  dxvk_nvapi: false" >> $GI_CONF_PATH
echo "  eac: false" >> $GI_CONF_PATH
echo "  fsr: false" >> $GI_CONF_PATH
echo "  vkd3d: false" >> $GI_CONF_PATH
done < <(printf '%s\n' "${GI_CONF_PATHS}")

flatpak run "net.lutris.Lutris" "lutris:stove-launcher"
