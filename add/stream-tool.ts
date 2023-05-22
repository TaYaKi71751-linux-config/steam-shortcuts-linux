import path from 'path';
import fs from 'fs';
import 'dotenv/config';
import { AddShortcut } from '../util/Shortcut';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'stream-tool'
);

const outFiles = fs.readdirSync(outPath);
outFiles
	.forEach((filename) => {
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[Stream][ffmpeg]' + (function () {
			switch (filename) {
			case 'start-capture-screen.out': return 'Start Screen Capture';
			case 'stop-capture-screen.out': return 'Stop Screen Capture';
			}
		})();
		AddShortcut({ AppName, exe, StartDir });
	});
