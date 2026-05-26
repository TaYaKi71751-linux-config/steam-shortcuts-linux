import path from 'path';
import fs from 'fs';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getExitNodes } from '../util/Tailscale';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { execSync } from 'child_process';


export async function __main__ () {
const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'tailscale'
);
	RemoveShortcutStartsWith({ AppName: '[Tailscale]' });

	const tags = ['Tailscale'];
	const outFiles = fs.readdirSync(outPath)
		.filter((filename) => ['logout.out','up.out', 'down.out', 'install.out'].includes(filename))
		.sort();
	const names: Record<string, string> = {
		'logout.out': 'Logout',
		'up.out': 'Up',
		'down.out': 'Down',
		'install.out': 'Install'
	};
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[Tailscale] ' + names[filename];
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: '%command%', tags });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
		if (filename.startsWith('up')) {
			let exitNodes:any;
			try {
				exitNodes = getExitNodes();
			} catch (e) {
				continue;
			}

			const shortcuts = [{ name: ' Without Exit-Nodes',	LaunchOptions: 'export TAILSCALE_EXIT_NODE= && %command%' },
				...(
					exitNodes
						.map(([DNSName, TailscaleIPs]:any) => ({ name: ` With Custom Exit-Node ${DNSName} `, LaunchOptions: `export TAILSCALE_EXIT_NODE=${TailscaleIPs[0]} && %command%` }))
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
