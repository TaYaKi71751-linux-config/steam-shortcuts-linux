import path from 'path';
import fs from 'fs';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getExitNodes } from '../util/Tailscale';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { execSync } from 'child_process';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'tailscale'
);

export async function __main__ () {
	RemoveShortcutStartsWith({ AppName: '[Tailscale]' });

	const tags = ['Tailscale'];
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[Tailscale] ' + (function () {
			switch (filename) {
			case 'up.out': return 'Up';
			case 'down.out': return 'Down';
			case 'install.out': return 'Install';
			}
		})();
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
		if (filename.startsWith('up')) {
			const exitNodes = getExitNodes();

			const shortcuts = [{ name: ' Without Exit-Nodes',	LaunchOptions: 'export TAILSCALE_EXIT_NODE= && %command%' },
				...(
					exitNodes
						.map(([DNSName, TailscaleIPs]) => ({ name: ` With Custom Exit-Node ${DNSName} `, LaunchOptions: `export TAILSCALE_EXIT_NODE=${TailscaleIPs[0]} && %command%` }))
				)
			];
			for (let k = 0; k < shortcuts?.length; k++) {
				const { name, LaunchOptions } = shortcuts[k];
				const appid = getShortcutAppID({ AppName: AppName + name, exe });
				AddShortcut({ appid, AppName: AppName + name, exe, StartDir, LaunchOptions, tags });
				for (let l = 0; l < tags?.length; l++) {
					const tag = tags[l];
					if (!tag) continue;
					await AddToCats(appid, tag);
				}
			}
			const down = execSync('bash sh/tailscale/down.sh').toString();
			console.log(`${down}`);
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
