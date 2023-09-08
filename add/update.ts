import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'update'
);

const outFiles = fs.readdirSync(outPath);
outFiles
	.forEach((filename) => {
		const StartDir = `${process.cwd()}`;
		const exe = path.join(outPath, filename);
		const AppName = 'Update TaYaKi71751/steam-shortcuts';
		AddShortcut({ AppName, exe, StartDir });
	});
