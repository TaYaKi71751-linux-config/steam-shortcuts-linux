import path from 'path';
import fs from 'fs';
import 'dotenv/config';
import { AddShortcut } from '../util/Shortcut';

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
			[{ name: ' Without Exit-Nodes',	LaunchOptions: 'export TAILSCALE_EXIT_NODE= && %command%' },

				...(
					`${process.env.TAILSCALE_EXIT_NODE}`
						.split(',')
						.map((node) => (node.trim()))
						.map((e) => ({ name: ` With Custom Exit-Node ${e} `, LaunchOptions: `export TAILSCALE_EXIT_NODE=${e} && %command%` }))
				)
			]
				.forEach(({ name, LaunchOptions }) => {
					AddShortcut({ AppName: AppName + name, exe, StartDir, LaunchOptions });
				});
		}
	});
