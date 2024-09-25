import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { setBackground, setCapsule, setLogo, setWideCapsule } from '../util/Grid';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'lutris'
);
const DEEPLINK_URLS = [
//	{ name: 'MapleStory', url: 'lutris:steam', tags: ['MapleStory', 'Lutris'] },
	{ name: 'Mabinogi', url: 'lutris:steam', tags: ['Mabinogi', 'Lutris'] },
//	{ name: '[Lutris] Genshin Impact', url: 'lutris:genshin-impact-standard', tags: ['Genshin Impact', 'Lutris'] },
	{ name: '[Lutris] NexonPlug', url: 'lutris:nexonplug-standard-kr-region', tags: ['Nexon', 'Lutris'] },
	{ name: '[Lutris] Diablo II: Resurrected', url: 'lutris:diablo-2-ressurected', tags: ['Battle.net', 'Diablo', 'Lutris'] },
	{ name: '[Lutris] Grand Theft Auto V (EGS)', url: 'lutris:grand-theft-auto-v-epic-games-launcher', tags: ['Grand Theft Auto V', 'Lutris'] },
	{ name: '[Lutris] Grand Theft Auto V (Rockstar)', url: 'lutris:grand-theft-auto-v-rockstar-games-launc', tags: ['Grand Theft Auto V', 'Lutris'] },
	{ name: '[Lutris] Grand Theft Auto V (PS3)', url: 'lutris:grand-theft-auto-v-ps3', tags: ['Grand Theft Auto V', 'Lutris'] },
	{ name: 'Lutris', url: '', tags: ['Lutris'] }
];

export async function __main__ () {
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		if (filename == 'install.out') {
			const AppName = '[Lutris] Install';
			const tags = ['Install', 'Lutris'];
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, tags });
			for (let k = 0; k < tags?.length; k++) {
				const tag = tags[k];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
		} else if (filename == 'url.out') {
			for (let j = 0; j < DEEPLINK_URLS?.length; j++) {
				const { name, url, tags, icon, background, widecapsule, logo, capsule }:any = DEEPLINK_URLS[j];
				const appid = getShortcutAppID({ AppName: name, exe });
				AddShortcut({ appid, AppName: name, exe, StartDir, LaunchOptions: `LUTRIS_DEEPLINK_URL="${url}" %command%`, tags, icon: icon ?? '' });
				if (background) {
					setBackground({
						appid,
						path: background
					});
				}
				if (widecapsule) {
					setWideCapsule({
						appid,
						path: widecapsule
					});
				}
				if (capsule) {
					setCapsule({
						appid,
						path: capsule
					});
				}
				if (logo) {
					setLogo({
						appid,
						path: logo
					});
				}
				for (let k = 0; k < tags?.length; k++) {
					const tag = tags[k];
					if (!tag) continue;
					await AddToCats(appid, tag);
				}
			}
		} else if (filename == 'reset.out') {
			const AppName = '[Lutris] Reset Data';
			const tags = ['Lutris'];
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, tags });
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
