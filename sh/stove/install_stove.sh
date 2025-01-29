#!/bin/bash

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}
auto_path wineserver
auto_path winetricks

WINEPREFIX="${HOME}/Games/stove"

mkdir -p "${HOME}/STOVE"
cd "${HOME}/STOVE"
rm STOVESetup.exe
curl -LsSf https://sgs-live-dl.game.playstove.com/game/lcs/STOVESetup.exe?launcherfilename=STOVESetup.exe -o "${HOME}/STOVE/STOVESetup.exe"


__EXE_NAME__="STOVESetup.exe"

__GAME_NAME__="stove"
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

find $HOME -name 'wineserver' -type f -exec export PATH=${PATH}:{} \;
find $HOME -name 'winetricks' -type f -exec {} win11 \;

curl -LsSf https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/3f167fcb-7f23-419d-951b-ce9ae3dcaa2d/MicrosoftEdgeWebView2RuntimeInstallerX86.exe -o "${HOME}/STOVE/WebView2.exe"

__EXE_PATH__="${HOME}/STOVE/WebView2.exe"

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

