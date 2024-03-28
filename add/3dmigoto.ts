import path from 'path';
import fs from 'fs';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getExitNodes } from '../util/Tailscale';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { execSync } from 'child_process';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'3dmigoto'
);

export async function __main__ () {
	RemoveShortcutStartsWith({ AppName: '[3dmigoto] Genshin Impact' });

	const tags = ['3dmigoto','Genshin Impact'];
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[3dmigoto] Genshin Impact';
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir });
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
