import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

export async function __main__ () {
	const outPath = path.join(
		`${process.env.PWD}`,
		'out',
		'AAGL'
	);
	const tags = ['Genshin Impact', 'AAGL'];

	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '' + (function () {
			switch (filename) {
		 case 'install_aagl.out': return 'Install AAGL';
		 case 'launch_aagl.out': return 'Genshin Impact Launcher (AAGL)';
			}
		})();
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: '%command%', tags });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
