import { execSync } from 'child_process'
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';

export async function __main__ () {
	const __GAME_NAME__ = 'Zenless Zone Zero';
	const __LAUNCHER_NAME__ = 'Sleepy';
	const __EXE_NAME__ = 'ZenlessZoneZero.exe';
	const __OUT_NAME__ = 'ZZZ';

	// 3DMigoto Lutris
	{
		RemoveShortcutStartsWith({ AppName: `[3dmigoto] ${__GAME_NAME__}` });
		const tags = ['3dmigoto',__GAME_NAME__,'Lutris'];
		const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
		const outFiles = ['3dmigoto_lutris.out'];
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = `[3dmigoto] ${__GAME_NAME__}`;
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
		}
	}

	// Plain Lutris
	{
		RemoveShortcutStartsWith({ AppName: `[Lutris] ${__GAME_NAME__}` });
		const tags = [__GAME_NAME__,'Lutris'];
		const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
		const outFiles = ['plain_lutris.out'];
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = `[Lutris] ${__GAME_NAME__}`;
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
		}
	}

	// AAGL
	{
		let tags = [__GAME_NAME__, __LAUNCHER_NAME__.toUpperCase()	];

		const outPath = path.join(`${process.env.PWD}`,'out',__OUT_NAME__);
			const outFiles = [`install_${__LAUNCHER_NAME__.toLowerCase()}.out`,`launch_${__LAUNCHER_NAME__.toLowerCase()}.out`];
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = `[${__LAUNCHER_NAME__.toUpperCase()}]` + (function () {
				switch (filename) {
					case `install_${__LAUNCHER_NAME__.toLowerCase()}.out`:
						tags = ['Install', __GAME_NAME__, __LAUNCHER_NAME__.toUpperCase()];
					return 'Install';
					case `launch_${__LAUNCHER_NAME__.toLowerCase()}.out`:
						tags = [__GAME_NAME__, __LAUNCHER_NAME__];
					return `${__GAME_NAME__} Launcher`;
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

	// Reload
	{
		let tags = [__GAME_NAME__];

		const outPath = path.join(`${process.env.PWD}`,'out',__OUT_NAME__);
		const outFiles = ['reload.out'];
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = `${process.env.PWD}`;
			const exe = path.join(outPath, filename);
			const AppName = `[${__GAME_NAME__}]` + (function () {
				switch (filename) {
					case 'reload.out':
						tags = ['Reload', __GAME_NAME__];
					return 'Reload';
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
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
