#!/bin/bash

mkdir -p ${HOME}/NTE
cd ${HOME}/NTE

rm setup.exe
curl -LsSf "https://ntecdn2.perfectworld.com/clientRes/installer-Global/YH_Singapore_common_setup_1.0.6.0423_20260424.exe" -o setup.exe

__EXE_NAME__="setup.exe"

__GAME_NAME__="nte"
__EXE_PATH__="${PWD}/${__EXE_NAME__}"

echo $__EXE_PATH__

mkdir -p "$HOME/Games/${__GAME_NAME__}/pfx/drive_c/"

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
    dxvk_nvapi: true
    eac: true
    fsr: false
    vkd3d: true
slug: ${__GAME_NAME__}
version: Installer
wine:
  battleye: true
  dxvk_nvapi: true
  dxvk: false
  eac: true
  fsr: false
  vkd3d: true
  version: wine-ge-8-26-x86_64
EOF

flatpak run net.lutris.Lutris "lutris:rungameid/${__GAME_ID__}"

