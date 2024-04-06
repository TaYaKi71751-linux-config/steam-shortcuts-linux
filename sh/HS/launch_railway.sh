#!/bin/bash

__GAME_NAME__="Railway"
__LAUNCHER_PACKAGE__="moe.launcher.the-honkers-railway-launcher"
__LAUNCHER_NAME__="honkers-railway-launcher"

function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}

auto_path node
mkdir -p $HOME/${__GAME_NAME__}

pkill -9 flatpak

/usr/bin/flatpak override --user --filesystem=$HOME/${__GAME_NAME__} ${__LAUNCHER_PACKAGE__}
node << EOF
const { readFileSync, writeFileSync } = require("fs");
const CONFIG_FILE_PATH = \`\${process.env.HOME}/.var/app/${__LAUNCHER_PACKAGE__}/data/${__LAUNCHER_NAME__}/config.json\`;
let config = JSON.parse(readFileSync(CONFIG_FILE_PATH));
try{config.launcher.temp = \`\${process.env.HOME}/${__GAME_NAME__}\`;} catch(e){console.error(e);}
try{config.game.path.global = \`\${process.env.HOME}/${__GAME_NAME__}/Global\`;}catch(e){console.error(e);}
try{config.game.path.china = \`\${process.env.HOME}/${__GAME_NAME__}/China\`;}catch(e){console.error(e);}
try{config.game.wine.prefix = \`\${process.env.HOME}/${__GAME_NAME__}/prefix\`;}catch(e){console.error(e);}
try{config.game.wine.builds = \`\${process.env.HOME}/${__GAME_NAME__}/runners\`;}catch(e){console.error(e);}
try{config.game.dxvk.builds = \`\${process.env.HOME}/${__GAME_NAME__}/dxvks\`;}catch(e){console.error(e);}
try{config.game.enhancements.fps_unlocker.path = \`\${process.env.HOME}/${__GAME_NAME__}/fps-unlocker\`;}catch(e){console.error(e);}
try{config.components.path = \`\${process.env.HOME}/${__GAME_NAME__}/components\`;}catch(e){console.error(e);}
writeFileSync(CONFIG_FILE_PATH, JSON.stringify(config, null, 2));
EOF

/usr/bin/flatpak run --file-forwarding ${__LAUNCHER_PACKAGE__}
