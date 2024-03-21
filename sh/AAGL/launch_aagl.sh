#!/bin/bash
function auto_path() {
	TARGET_PATHS="$(find / -name "$1" -type f)"
	echo $TARGET_PATHS
	while IFS= read -r line
	do
		export PATH=${PATH}:$(dirname ${line})
	done < <(printf '%s\n' "$TARGET_PATHS")
}

auto_path node

pkill -9 flatpak

/usr/bin/flatpak override --user --filesystem=$HOME/AAGL moe.launcher.an-anime-game-launcher
node << EOF
const { readFileSync, writeFileSync } = require("fs");
const CONFIG_FILE_PATH = \`\${process.env.HOME}/.var/app/moe.launcher.an-anime-game-launcher/data/anime-game-launcher/config.json\`;
let config = JSON.parse(readFileSync(CONFIG_FILE_PATH));
config.launcher.temp = \`\${process.env.HOME}/AAGL\`;
config.game.path.global = \`\${process.env.HOME}/AAGL/Genshin Impact\`;
config.game.path.china = \`\${process.env.HOME}/AAGL/YuanShen\`;
config.game.wine.prefix = \`\${process.env.HOME}/AAGL/prefix\`;
config.game.wine.builds = \`\${process.env.HOME}/AAGL/runners\`;
config.dxvk.builds = \`\${process.env.HOME}/AAGL/dxvks\`;
config.enhancements.fps_unlocker.path = \`\${process.env.HOME}/AAGL/fps-unlocker\`;
config.components.path = \`\${process.env.HOME}/AAGL/components\`;
writeFileSync(CONFIG_FILE_PATH, JSON.stringify(config, null, 2));
EOF

/usr/bin/flatpak run --file-forwarding moe.launcher.an-anime-game-launcher 
