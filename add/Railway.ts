import { execSync } from 'child_process';
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';

export async function __main__ () {
	// Proton
	{
		RemoveShortcutStartsWith({ AppName: '[Proton] Genshin Impact' });
		let filenames = execSync('find / -name \'StarRail.exe\' -type f || true').toString().split('\n');
		try {
		filenames = [...filenames, ...execSync(`find -L ${process.env.HOME}/Games/*/drive_c -name \'StarRail.exe\' -type f || true`).toString().split('\n')];
		} catch(e){}
		console.log(filenames);
		const tags = ['Honkai StarRail', 'Proton'];
		filenames = filenames
			.map((filename) => (filename.trim()))
			.filter((filename) => (filename.length))
			.filter((filename) => { try { if (existsSync(filename)) { return true; } } catch (e) { return false; } return false; });
		for (const filename of filenames) {
			const StartDir = dirname(filename);
			const exe = JSON.stringify(filename);
			const AppName = `[Proton] Honkai StarRail (${filename})`;
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: 'obs-gamecapture %command%' });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
			AddCompat({ appid: `${appid}`, compat: 'proton_7' });
		}
	}

	// AAGL
	{
		let tags = ['Honkai StarRail', 'The Honkers Railway Launcher'];

		const outPath = path.join(`${process.env.PWD}`,'out','HS');
		const outFiles = ['install_railway.out','launch_railway.out'];
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = '[Railway]' + (function () {
				switch (filename) {
					case 'install_railway.out':
						tags = ['Install', 'Honkai StarRail'];
					return 'Install';
					case 'launch_railway.out':
						tags = ['Honkai StarRail'];
					return 'Honkai StarRail Launcher';
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
