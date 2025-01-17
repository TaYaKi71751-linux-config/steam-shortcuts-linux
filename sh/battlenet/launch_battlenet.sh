#!/bin/bash

mkdir -p ${HOME}/BattleNet/
cd ${HOME}/BattleNet

__GAME_NAME__="battlenet"

mkdir -p "$HOME/Games/${__GAME_NAME__}/drive_c/"

# rm $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db
__GAME_ID__="$(sqlite3 $HOME/.var/app/net.lutris.Lutris/data/lutris/pga.db << EOF
SELECT id FROM games WHERE gameslug = '${__GAME_NAME__}';
EOF
)"

flatpak run net.lutris.Lutris "lutris:rungameid/${__GAME_ID__}"
