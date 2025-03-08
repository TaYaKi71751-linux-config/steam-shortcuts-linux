import { execSync } from 'child_process'
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';

export async function __main__ () {
	const __GAME_NAME__ = 'Infinity Nikki';
	const __EXE_NAME__ = 'InfinityNikki.exe';
	const __OUT_NAME__ = 'infinity_nikki';

	// Plain Lutris
	{
		RemoveShortcutStartsWith({ AppName: `[Lutris] ${__GAME_NAME__}` });
		const tags = [__GAME_NAME__,'Lutris'];
		const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
		const outFiles = ['launch_infinity_nikki.out'];
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

	// Plain Launcher
	{
		let tags = [__GAME_NAME__];

		const outPath = path.join(`${process.env.PWD}`,'out',__OUT_NAME__);
			const outFiles = [`install_infinity_nikki_launcher.out`,`launch_infinity_nikki_launcher.out`];
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = `[InfinityNikkiPlain]` + (function () {
				switch (filename) {
					case `install_infinity_nikki_launcher.out`:
						tags = ['Install', __GAME_NAME__];
					return 'Install';
					case `launch_infinity_nikki_launcher.out`:
						tags = [__GAME_NAME__];
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
