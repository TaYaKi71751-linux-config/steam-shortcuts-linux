import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

export async function __main__ () {
	const outPath = path.join(
		`${process.env.PWD}`,
		'out',
		'RDO'
	);
	const tags = ['Red Dead Online'];

	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
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
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: LaunchOptions || '', tags });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	}
}
