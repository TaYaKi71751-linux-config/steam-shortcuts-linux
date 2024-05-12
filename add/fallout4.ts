import { execSync } from 'child_process';
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';

export async function __main__ () {
	RemoveShortcutStartsWith({ AppName: '[Fallout4] ' });

	// https://gall.dcinside.com/mgallery/board/view/?id=steamdeck&no=119114
	// Proton redist
	{
		let filenames = execSync('find / -name \'VC_redist.x64.exe\' -type f || true').toString().split('\n');
		console.log(filenames);
		const tags = ['Fallout4', 'Proton'];
		filenames = filenames
			.map((filename) => (filename.trim()))
			.filter((filename) => (filename.length))
			.filter((filename) => { try { if (existsSync(filename)) { return true; } } catch (e) { return false; } return false; });
		for (const filename of filenames) {
			const StartDir = dirname(filename);
			const exe = JSON.stringify(filename);
			const AppName = `[Fallout4] VC_redist.x64.exe (${filename})`;
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: `STEAM_COMPAT_DATA_PATH="${process.env.HOME}/.steam/steam/steamapps/compatdata/377160" %command% > /dev/null 2>&1` });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
			AddCompat({ appid: `${appid}`, compat: 'proton_experimental' });
		}
	}
	// Proton MO2
	{
		let filenames = execSync('find / -name \'ModOrganizer.exe\' -type f || true').toString().split('\n');
		console.log(filenames);
		const tags = ['Fallout4', 'Proton'];
		filenames = filenames
			.map((filename) => (filename.trim()))
			.filter((filename) => (filename.length))
			.filter((filename) => { try { if (existsSync(filename)) { return true; } } catch (e) { return false; } return false; });
		for (const filename of filenames) {
			const StartDir = dirname(filename);
			const exe = JSON.stringify(filename);
			const AppName = `[Fallout4] ModOrganizer.exe (${filename})`;
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: `STEAM_COMPAT_DATA_PATH="${process.env.HOME}/.steam/steam/steamapps/compatdata/377160" %command% > /dev/null 2>&1` });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
			AddCompat({ appid: `${appid}`, compat: 'proton_experimental' });
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
