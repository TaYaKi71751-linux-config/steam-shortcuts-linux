import path from 'path';
import fs from 'fs';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'openttd-jgrpp'
);

export async function __main__ () {
	const tags = ['openttd-jgrpp'];
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '' + (function () {
			switch (filename) {
			case 'openttd-jgrpp-install.out': return '[openttd-jgrpp] Install';
			case 'openttd-jgrpp-remove.out': return '[openttd-jgrpp] Remove';
			case 'openttd-jgrpp-update.out': return '[openttd-jgrpp] Update';
			case 'openttd-jgrpp-launch.out': return '[openttd-jgrpp] Launch';
			case 'opengfx-install.out': return '[opengfx] Install';
			}
		})();
		const LaunchOptions = '' + (function () {
			switch (filename) {
			case 'openttd-jgrpp-install.out': return 'export CHECKOUT_BRANCH="jgrpp" && %command%';
			case 'openttd-jgrpp-update.out': return 'export CHECKOUT_BRANCH="jgrpp" && %command%';
			default: return '';
			}
		})();
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions });
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
