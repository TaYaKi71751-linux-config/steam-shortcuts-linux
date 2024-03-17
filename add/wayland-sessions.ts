import path, { basename } from 'path';
import fs from 'fs';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { getWaylandSessions } from '../util/Sessions';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'wayland-sessions'
);

export async function __main__ () {
	RemoveShortcutStartsWith({ AppName: '[wayland-sessions]' });

	const tags = ['wayland-sessions'];
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[wayland-sessions] ' + (function () {
			switch (filename) {
			case 'run.out': return 'Run';
			}
		})();
		if (filename.startsWith('run')) {
			let sessions:any;
			try {
				sessions = getWaylandSessions();
			} catch (e) {
				continue;
			}

			const shortcuts = [
				...(
					sessions
						.filter((s:any) => (s.endsWith('.desktop')))
						.map((s:any) => (basename(s)))
						.map((s:any) => (s.substring(0, s.length - '.desktop'.length)))
						.map((s:any) => ({ name: ` With ${s} `, LaunchOptions: `export SESSION=${s.substring(0)} && %command%` }))
				)
			];
			for (let k = 0; k < shortcuts?.length; k++) {
				const { name, LaunchOptions } = shortcuts[k];
				const appid = getShortcutAppID({ AppName: AppName + name, exe });
				AddShortcut({ appid, AppName: AppName + name, exe, StartDir, LaunchOptions, tags });
				for (let l = 0; l < tags?.length; l++) {
					const tag = tags[l];
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
