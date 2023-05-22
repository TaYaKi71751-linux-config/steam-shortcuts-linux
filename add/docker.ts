import path from 'path';
import fs from 'fs';
import 'dotenv/config';
import { AddShortcut } from '../util/Shortcut';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'docker'
);

const outFiles = fs.readdirSync(outPath);
outFiles
	.forEach((filename) => {
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[Docker]' + (function () {
			switch (filename) {
			case 'enable.out': return 'Enable docker';
			case 'disable.out': return 'Disable docker';
			}
		})();
		AddShortcut({ AppName, exe, StartDir });
	});
