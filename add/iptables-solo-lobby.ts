import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

export async function __main__ () {
	const outPath = path.join(
		`${process.env.PWD}`,
		'out',
		'iptables-solo-lobby'
	);
	const tags = ['Red Dead Online', 'Grand Theft Auto Online', 'iptables-solo-lobby', 'Firewall'];

	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[iptables-solo-lobby]' + (function () {
			switch (filename) {
			case 'enable-solo-lobby.out': return 'Enable Solo Lobby';
			case 'temporarily-solo-lobby.out': return 'Apply Solo Lobby Temporarily';
			case 'disable-solo-lobby.out': return 'Disable Solo Lobby';
			case 'enable-iptables-service.out': return 'Enable iptables';
			case 'disable-iptables-service.out': return 'Disable iptables';
			}
		})();
		const LaunchOptions = (function () {
			return `cd ${JSON.stringify(outPath)} && %command%`;
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
