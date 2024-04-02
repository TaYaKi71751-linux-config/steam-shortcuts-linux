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
		let filenames = execSync('find / -name \'GenshinImpact.exe\' -type f || true').toString().split('\n');
		const tags = ['Genshin Impact', 'Proton'];
		filenames = filenames
			.map((filename) => (filename.trim()))
			.filter((filename) => (filename.length))
			.filter((filename) => { try { if (existsSync(filename)) { return true; } } catch (e) { return false; } return false; });
		for (const filename of filenames) {
			const StartDir = dirname(filename);
			const exe = JSON.stringify(filename);
			const AppName = `[Proton] Genshin Impact (${filename})`;
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

	// 3DMigoto Lutris
	{
		RemoveShortcutStartsWith({ AppName: '[3dmigoto] Genshin Impact' });
		const tags = ['3dmigoto','Genshin Impact','Lutris'];
		const outPath = path.join(`${process.env.PWD}`, 'out', 'GI');
		const outFiles = ['3dmigoto_lutris.out'];
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

	// Plain Lutris
	{
		RemoveShortcutStartsWith({ AppName: '[Lutris] Genshin Impact' });
		const tags = ['Genshin Impact','Lutris'];
		const outPath = path.join(`${process.env.PWD}`, 'out', 'GI');
		const outFiles = ['plain_lutris.out'];
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = '[Lutris] Genshin Impact';
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir });
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
