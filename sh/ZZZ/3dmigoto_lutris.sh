#!/bin/bash

__EXE_NAME__="ZenlessZoneZero.exe"

__GAME_NAME__="zenless-zone-zero"
__EXE_PATH__="$(find ${HOME} -name "${__EXE_NAME__}" -type f | tail -n 1)"
echo $__EXE_PATH__
mkdir -p "$HOME/Games/${__GAME_NAME__}/drive_c/"
ln -sf "$(dirname "$__EXE_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"
__D3DX_PATHS__="$(find $HOME/ -name 'd3dx.ini')"


while IFS= read -r __D3DX_PATH__
do
	if ( cat $__D3DX_PATH__ | grep ${__EXE_NAME__} );then
		export __3DMIGOTO_PATH__="$(dirname "$__D3DX_PATH__")/3DMigoto Loader.exe"
	fi
done < <(printf '%s\n' "$__D3DX_PATHS__")
echo $__3DMIGOTO_PATH__
ln -sf "$(dirname "$__3DMIGOTO_PATH__")" "$HOME/Games/${__GAME_NAME__}/drive_c/"

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
 rm $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME}-*.yml
fi

if ( ls /usr/bin/obs-gamecapture );then
mkdir -p $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
cp /usr/bin/obs-gamecapture $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-0.yml << EOF
game:
  exe: $HOME/Games/${__GAME_NAME__}/drive_c/launch.bat
  prefix: $HOME/Games/${__GAME_NAME__}/
game_slug: ${__GAME_NAME__}
name: ${__GAME_NAME__}
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
    prefix_command: ${HOME}/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
slug: ${__GAME_NAME__}
version: Installer
wine:
  battleye: false
  dxvk_nvapi: false
  eac: false
  fsr: false
  vkd3d: false
system:
  prefix_command: ${HOME}/.var/app/net.lutris.Lutris/data/lutris/runners/wine/obs-gamecapture
EOF
else
cat > $HOME/.var/app/net.lutris.Lutris/data/lutris/games/${__GAME_NAME__}-0.yml << EOF
game:
  exe: $HOME/Games/${__GAME_NAME__}/drive_c/launch.bat
  prefix: $HOME/Games/${__GAME_NAME__}/
game_slug: ${__GAME_NAME__}
name: ${__GAME_NAME__}
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
slug: ${__GAME_NAME__}
version: Installer
wine:
  battleye: false
  dxvk_nvapi: false
  eac: false
  fsr: false
  vkd3d: false
EOF
fi
export BATCH_PATH="${HOME}/Games/${__GAME_NAME__}/drive_c/launch.bat"

echo "cd C:\\$(dirname "${__3DMIGOTO_PATH__}" | rev | cut -d '/' -f1 | rev)" > $BATCH_PATH
echo "start \"\" \"3DMigoto Loader.exe\"" >> $BATCH_PATH
echo "cd C:\\$(dirname "${__EXE_PATH__}" | rev | cut -d '/' -f1 | rev)" >> $BATCH_PATH
echo "start \"\" ${__EXE_NAME__}" >> $BATCH_PATH
flatpak run net.lutris.Lutris "lutris:rungameid/${__GAME_ID__}"
