#!/bin/bash

__GAME_NAME__="genshin-impact"
__GI_PATH__="$(find / -name 'GenshinImpact.exe' -type f | tail -n 1)"
echo $__GI_PATH__
mkdir -p "$HOME/Games/${__GAME_NAME__}/drive_c/"
ln -sf "$(dirname "$__GI_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"
__3DMIGOTO_PATH__="$(find $HOME/ -name '3DMigoto Loader.exe' | tail -n 1)"
echo $__3DMIGOTO_PATH__
ln -sf "$(dirname "$__3DMIGOTO_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"
if ( ls $HOME/.var/app/net.lutris.Lutris/data/lutris/games/genshin-impact-*.yml );then
 rm $HOME/.var/app/net.lutris.Lutris/data/lutris/games/genshin-impact-*.yml
fi
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/newgame.yml << EOF
name: ${__GAME_NAME__}
game_slug: ${__GAME_NAME__}
version: Installer
slug: ${__GAME_NAME__}
runner: wine
script:
  game:
    exe: $HOME/Games/${__GAME_NAME__}/drive_c/GenshinImpact.bat
    prefix: $HOME/Games/${__GAME_NAME__}/
  wine:
    battleye: false
    dxvk_nvapi: false
    eac: false
    fsr: false
    vkd3d: false
EOF
export BATCH_PATH="${HOME}/Games/${__GAME_NAME__}/drive_c/GenshinImpact.bat"

echo "cd C:\\$(dirname "${__GI_PATH__}" | rev | cut -d '/' -f1 | rev)" > $BATCH_PATH
echo "start \"\" GenshinImpact.exe" >> $BATCH_PATH
flatpak run net.lutris.Lutris -i $HOME/.var/app/net.lutris.Lutris/data/lutris/games/newgame.yml

