import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'stream-tool'
);

export async function __main__ () {
	const outFiles = fs.readdirSync(outPath);
	const tags = ['Stream'];
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[Stream][ffmpeg][gstreamer]' + (function () {
			switch (filename) {
			case 'start-capture-screen.out': return 'Start Screen Capture';
			case 'stop-capture-screen.out': return 'Stop Screen Capture';
			}
		})();
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, tags });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	}
}
