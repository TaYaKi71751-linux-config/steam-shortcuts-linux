import { execSync } from 'child_process';
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';
import fs from 'fs';

export async function __main__ () {
	// Flatpak
	{
		let tags = ['Minecraft'];

		const outPath = path.join(`${process.env.PWD}`,'out','minecraft');
		const outFiles = fs.readdirSync(outPath);
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = '[Minecraft]' + (function () {
				switch (filename) {
					case 'install_modrinth.out':
						tags = ['Install', 'Minecraft'];
					return 'Install Modrinth';
					case 'install_prism.out':
						tags = ['Install', 'Minecraft'];
					return 'Install Prism Launcher';
					case 'launch_modrinth.out':
						tags = ['Minecraft'];
					return 'Modrinth Launcher';
					case 'launch_prism.out':
						tags = ['Minecraft'];
					return 'Prism Launcher';
					case 'install_bedrock':
						tags = ['Minecraft'];
					return 'Install Bedrock Launcher';
					case 'launch_bedrock':
						tags = ['Minecraft'];
					return 'Bedrock Launcher';
				}
			})();
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: '%command%', tags });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
