import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { setBackground, setCapsule, setLogo, setWideCapsule } from '../util/Grid';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'lutris_stove_launcher'
);
const DEEPLINK_URLS = [
	{ name: '[STOVE] Tales Runner', url: '', tags: ['STOVE', 'Tales Runner', 'Lutris'] },
];

export async function __main__ () {
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		if (filename == 'run.out') {
			for (let j = 0; j < DEEPLINK_URLS?.length; j++) {
				const { name, url, tags, icon, background, widecapsule, logo, capsule }:any = DEEPLINK_URLS[j];
				const appid = getShortcutAppID({ AppName: name, exe });
				AddShortcut({ appid, AppName: name, exe, StartDir, LaunchOptions: `%command%`, tags, icon: icon ?? '' });
				for (let k = 0; k < tags?.length; k++) {
					const tag = tags[k];
					if (!tag) continue;
					await AddToCats(appid, tag);
				}
			}
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
