import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { setBackground, setCapsule, setLogo, setWideCapsule } from '../util/Grid';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'firefox'
);
const PAGE_URLS = [
	{ name: 'ProtonVPN', url: 'https://account.proton.me/u/2/vpn/OpenVpnIKEv2', tags: ['ProtonVPN'] },
];

export async function __main__ () {
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		if (filename == 'kiosk.out') {
			for (let j = 0; j < PAGE_URLS?.length; j++) {
				const { name, url, tags } = PAGE_URLS[j];
				const appid = getShortcutAppID({ AppName: name, exe });
				AddShortcut({ appid, AppName: name, exe, StartDir, LaunchOptions: `PAGE_URL="${url}" %command%`, tags, icon: icon ?? '' });
				for (let k = 0; k < tags?.length; k++) {
					const tag = tags[k];
					if (!tag) continue;
					await AddToCats(appid, tag);
				}
				await AddToCats(appid, 'Firefox');
			}
		} else if (filename == 'install.out') {
			const name = '[Firefox] Install';
			const appid = getShortcutAppID({ AppName: name, exe });
			const tags = ['Install'];
			AddShortcut({ appid, AppName: name, exe, StartDir, LaunchOptions: '%command%', tags });
			for (let k = 0; k < tags?.length; k++) {
				const tag = tags[k];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
