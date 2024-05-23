#!/bin/bash

mkdir -p ${HOME}/WutheringWaves
cd ${HOME}/WutheringWaves

mkdir -p "${HOME}/WutheringWaves/Wuthering Waves Game"

mkdir -p "$HOME/WutheringWaves/prefix/drive_c/Wuthering Waves/"
ln -sf "${HOME}/WutheringWaves/Wuthering Waves Game" "$HOME/WutheringWaves/prefix/drive_c/Wuthering Waves/"


__GAME_NAME__="wuthering-waves"
__EXE_PATH__="$(find "${HOME}/WutheringWaves/" -name 'Wuthering Waves.exe' -type f | tail -n 1)"
echo $__EXE_PATH__

# rm $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db
sqlite3 $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db << EOF
DELETE FROM games WHERE name = '${__GAME_NAME__}';
.save $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp
EOF
mv $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db

if ( ls $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-*.yml );then
 rm $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-*.yml
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
    exe: ${__EXE_PATH__}
    prefix: $HOME/WutheringWaves/prefix
  wine:
    battleye: false
    dxvk_nvapi: false
    eac: true
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
    exe: ${__EXE_PATH__}
    prefix: $HOME/WutheringWaves/prefix
  wine:
    battleye: false
    dxvk_nvapi: false
    eac: true
    fsr: false
    vkd3d: false
EOF
fi

flatpak run net.lutris.Lutris -i $HOME/.var/app/net.lutris.Lutris/data/lutris/games/newgame.yml

