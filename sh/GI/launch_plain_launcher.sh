#!/bin/bash

mkdir -p ${HOME}/AAGL/
cd ${HOME}/AAGL

__GAME_NAME__="genshin-impact"

mkdir -p "$HOME/Games/${__GAME_NAME__}/drive_c/"
mkdir -p "${HOME}/AAGL/Genshin Impact game"

rm -rf "${HOME}/Games/${__GAME_NAME__}/drive_c/Program Files/HoYoPlay/games/Genshin Impact game"
ln -sf "${HOME}/AAGL/Genshin Impact game" "${HOME}/Games/${__GAME_NAME__}/drive_c/Program Files/HoYoPlay/games/"

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

if ( ls $HOME/.var/app/net.lutris.Lutris/data/lutris/games/genshin-impact-*.yml );then
 rm $HOME/.var/app/net.lutris.Lutris/data/lutris/games/genshin-impact-*.yml
fi

if ( ls /usr/bin/obs-gamecapture );then
cp /usr/bin/obs-gamecapture $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-0.yml << EOF
game:
  exe: $HOME/Games/${__GAME_NAME__}/drive_c/Program Files/HoYoPlay/launcher.exe
  prefix: $HOME/Games/${__GAME_NAME__}/
game_slug: ${__GAME_NAME__}
name: ${__GAME_NAME__}
script:
  game:
    exe: $HOME/Games/${__GAME_NAME__}/drive_c/Program Files/HoYoPlay/launcher.exe
    prefix: $HOME/Games/${__GAME_NAME__}/
  wine:
    d3d_extras: false
    dxvk: false
    battleye: false
    dxvk_nvapi: false
    esync: false
    eac: false
    fsr: false
    fsync: false
    vkd3d: false
  system:
    prefix_command: ${HOME}/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
slug: ${__GAME_NAME__}
version: Installer
wine:
  d3d_extras: false
  dxvk: false
  battleye: false
  dxvk_nvapi: false
  esync: false
  eac: false
  fsr: false
  fsync: false
  vkd3d: false
system:
  prefix_command: ${HOME}/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
EOF
else
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-0.yml << EOF
game:
  exe: $HOME/Games/${__GAME_NAME__}/drive_c/Program Files/HoYoPlay/launcher.exe
  prefix: $HOME/Games/${__GAME_NAME__}/
game_slug: ${__GAME_NAME__}
name: ${__GAME_NAME__}
script:
  game:
    exe: $HOME/Games/${__GAME_NAME__}/drive_c/Program Files/HoYoPlay/launcher.exe
    prefix: $HOME/Games/${__GAME_NAME__}/
  wine:
    d3d_extras: false
    dxvk: false
    battleye: false
    dxvk_nvapi: false
    esync: false
    eac: false
    fsr: false
    fsync: false
    vkd3d: false
slug: ${__GAME_NAME__}
version: Installer
wine:
  d3d_extras: false
  dxvk: false
  battleye: false
  dxvk_nvapi: false
  esync: false
  eac: false
  fsr: false
  fsync: false
  vkd3d: false
EOF
fi

flatpak run net.lutris.Lutris "lutris:rungameid/${__GAME_ID__}"
