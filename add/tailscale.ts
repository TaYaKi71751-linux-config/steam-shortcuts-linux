import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getExitNodes } from '../util/Tailscale';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'tailscale'
);

const outFiles = fs.readdirSync(outPath);
outFiles
	.forEach((filename) => {
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[Tailscale] ' + (function () {
			switch (filename) {
			case 'up.out': return 'Up';
			case 'down.out': return 'Down';
			}
		})();
		AddShortcut({ AppName, exe, StartDir });
		if (filename.startsWith('up')) {
			const exitNodes = getExitNodes();
			[{ name: ' Without Exit-Nodes',	LaunchOptions: 'export TAILSCALE_EXIT_NODE= && %command%' },
				...(
					exitNodes
						.map(([DNSName, TailscaleIPs]) => ({ name: ` With Custom Exit-Node ${DNSName} `, LaunchOptions: `export TAILSCALE_EXIT_NODE=${TailscaleIPs[0]} && %command%` }))
				)
			]
				.forEach(({ name, LaunchOptions }) => {
					AddShortcut({ AppName: AppName + name, exe, StartDir, LaunchOptions });
				});
		}
	});
