#!/bin/bash

mkdir -p ${HOME}/BattleNet
cd ${HOME}/BattleNet

rm setup.exe
curl -LsSf "https://www.battle.net/download/getInstallerForGame?os=win&version=LIVE&gameProgram=BATTLENET_APP" -o setup.exe

__EXE_NAME__="setup.exe"

__GAME_NAME__="battlenet"
__EXE_PATH__="${PWD}/${__EXE_NAME__}"

echo $__EXE_PATH__

mkdir -p "$HOME/Games/${__GAME_NAME__}/drive_c/"

# rm $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db
sqlite3 $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db << EOF
DELETE FROM games WHERE slug = '${__GAME_NAME__}';
.save $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp
EOF
mv $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db

sqlite3 $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db << EOF
INSERT INTO games (
 name,
	slug,
	installer_slug,
	platform,
	runner,
	configpath,
	installed,
	lastplayed,
	installed_at,
	has_custom_banner,
	has_custom_icon,
	has_custom_coverart_big,
	playtime
) VALUES (
 '${__GAME_NAME__}',
 '${__GAME_NAME__}',
 '${__GAME_NAME__}',
	'Windows',
	'wine',
	'${__GAME_NAME__}-0',
	1,
	0,
	0,
	0,
	0,
	0,
	0.0
);
.save $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp
EOF
mv $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db.tmp $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db

__GAME_ID__="$(sqlite3 $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db << EOF
SELECT id FROM games WHERE slug = '${__GAME_NAME__}';
EOF
)"

if ( ls $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-*.yml );then
 rm $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-*.yml
fi

if ( ls /usr/bin/obs-gamecapture );then
cp /usr/bin/obs-gamecapture $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-0.yml << EOF
game:
  exe: ${__EXE_PATH__}
  prefix: $HOME/Games/${__GAME_NAME__}/
game_slug: ${__GAME_NAME__}
name: ${__GAME_NAME__}
script:
  game:
    exe: ${__EXE_PATH__}
    prefix: $HOME/Games/${__GAME_NAME__}/
  wine:
    battleye: true
    dxvk_nvapi: false
    eac: true
    fsr: false
    vkd3d: false
  system:
    prefix_command: ${HOME}/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
slug: ${__GAME_NAME__}
version: Installer
wine:
  battleye: true
  dxvk_nvapi: false
  dxvk: false
  eac: true
  fsr: false
  vkd3d: false
  version: wine-ge-8-26-x86_64
system:
  prefix_command: ${HOME}/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
EOF
else
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-0.yml << EOF
game:
  exe: ${__EXE_PATH__}
  prefix: $HOME/Games/${__GAME_NAME__}/
game_slug: ${__GAME_NAME__}
name: ${__GAME_NAME__}
script:
  game:
    exe: ${__EXE_PATH__}
    prefix: $HOME/Games/${__GAME_NAME__}/
  wine:
    battleye: true
    dxvk_nvapi: false
    eac: true
    fsr: false
    vkd3d: false
slug: ${__GAME_NAME__}
version: Installer
wine:
  battleye: true
  dxvk_nvapi: false
  dxvk: false
  eac: true
  fsr: false
  vkd3d: false
  version: wine-ge-8-26-x86_64
EOF
fi

flatpak run net.lutris.Lutris "lutris:rungameid/${__GAME_ID__}"

