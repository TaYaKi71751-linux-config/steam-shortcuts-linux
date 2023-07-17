import path from 'path';
import fs from 'fs';
import 'dotenv/config';
import { AddShortcut } from '../util/Shortcut';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'RDO'
);

const outFiles = fs.readdirSync(outPath);
outFiles
	.forEach((filename) => {
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[RDO]' + (function () {
			switch (filename) {
			case 'private-session.out': return 'Private Session';
			case 'public-session.out': return 'Public Session';
			}
		})();
		const LaunchOptions = (function () {
			switch (filename) {
			case 'private-session.out': return 'RDO_PW="" %command%';
			}
		})();
		AddShortcut({ AppName, exe, StartDir, LaunchOptions: LaunchOptions || '' });
	});
