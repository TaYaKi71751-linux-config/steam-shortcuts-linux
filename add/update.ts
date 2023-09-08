import path from 'path';
import fs from 'fs';
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
		const AppName = 'Update TaYaKi71751/steam-shortcuts';
		AddShortcut({ AppName, exe, StartDir });
	});
