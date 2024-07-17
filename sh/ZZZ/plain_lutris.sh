#!/bin/bash
__EXE_NAME__="ZenlessZoneZero.exe"
__GAME_NAME__="zenless-zone-zero"
__EXE_PATH__="$(find / -name "${__EXE_NAME__}" -type f | tail -n 1)"
echo $__EXE_PATH__
mkdir -p "$HOME/Games/${__GAME_NAME__}/drive_c/"
ln -sf "$(dirname "$__EXE_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"
__3DMIGOTO_PATH__="$(find $HOME/ -name '3DMigoto Loader.exe' | tail -n 1)"
echo $__3DMIGOTO_PATH__
ln -sf "$(dirname "$__3DMIGOTO_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"

# rm $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db
sqlite3 $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db << EOF
DELETE FROM games WHERE name = '${__GAME_NAME__}';
.save $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp
EOF
mv $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db

if ( ls $HOME/.var/app/net.lutris.Lutris/data/lutris/games/genshin-impact-*.yml );then
 rm $HOME/.var/app/net.lutris.Lutris/data/lutris/games/genshin-impact-*.yml
fi

if ( ls /usr/bin/obs-gamecapture );then
cp /usr/bin/obs-gamecapture $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/newgame.yml << EOF
name: ${__GAME_NAME__}
game_slug: ${__GAME_NAME__}
version: Installer
slug: ${__GAME_NAME__}
runner: wine
script:
  game:
    exe: $HOME/Games/${__GAME_NAME__}/drive_c/launch.bat
    prefix: $HOME/Games/${__GAME_NAME__}/
  wine:
    battleye: false
    dxvk_nvapi: false
    eac: false
    fsr: false
    vkd3d: false
  system:
    prefix_command: $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
EOF
else
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/newgame.yml << EOF
name: ${__GAME_NAME__}
game_slug: ${__GAME_NAME__}
version: Installer
slug: ${__GAME_NAME__}
runner: wine
script:
  game:
    exe: $HOME/Games/${__GAME_NAME__}/drive_c/launch.bat
    prefix: $HOME/Games/${__GAME_NAME__}/
  wine:
    battleye: false
    dxvk_nvapi: false
    eac: false
    fsr: false
    vkd3d: false
  system:
    prefix_command: /home/deck/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
EOF
fi
export BATCH_PATH="${HOME}/Games/${__GAME_NAME__}/drive_c/launch.bat"

echo "cd C:\\$(dirname "${__EXE_PATH__}" | rev | cut -d '/' -f1 | rev)" > $BATCH_PATH
echo "start \"\" ${__EXE_NAME__}" >> $BATCH_PATH
flatpak run net.lutris.Lutris -i $HOME/.var/app/net.lutris.Lutris/data/lutris/games/newgame.yml

