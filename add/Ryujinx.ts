import { execSync } from 'child_process';
import fs, { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import __path__ from 'path';

const outPath = __path__.join(
	`${process.env.PWD}`,
	'out',
	'ryujinx'
);

export async function __main__ () {
	RemoveShortcutStartsWith({ AppName: '[Ryujinx]' });
	let outFiles = fs.readdirSync(outPath);
	outFiles = outFiles.map((o) => (__path__.join(outPath, o)));
	for (const outfile of outFiles) {
		if (outfile.endsWith('run.out')) {
			{
				let filenames = execSync(`find ${process.env.HOME} -name \'*.nsp\' -type f || true`).toString().split('\n');
				const tags = ['Ryujinx', 'NSP'];
				filenames = filenames
					.map((filename) => (filename.trim()))
					.filter((filename) => (filename.length))
					.filter((filename) => {
						try {
							if (existsSync(filename)) {
								return true;
							}
						} catch (e) { return false; }
						return false;
					});
				for (const filename of filenames) {
					const StartDir = __path__.dirname(filename);
					const exe = JSON.stringify(outfile);
					const AppName = `[Ryujinx][NSP] ${__path__.basename(filename)} (${filename})`;
					const appid = getShortcutAppID({ AppName, exe });
					AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: `export __GAME_PATH__="${filename}" && %command%` });
					for (let j = 0; j < tags?.length; j++) {
						const tag = tags[j];
						if (!tag) continue;
						await AddToCats(appid, tag);
					}
				}
			}
			{
				let filenames = execSync(`find ${process.env.HOME} -name \'*.xci\' -type f || true`).toString().split('\n');
				const tags = ['Ryujinx', 'XCI'];
				filenames = filenames
					.map((filename) => (filename.trim()))
					.filter((filename) => (filename.length))
					.filter((filename) => {
						try {
							if (existsSync(filename)) {
								return true;
							}
						} catch (e) { return false; }
						return false;
					});
				for (const filename of filenames) {
					const StartDir = __path__.dirname(filename);
					const exe = JSON.stringify(outfile);
					const AppName = `[Ryujinx][XCI] ${__path__.basename(filename)} (${filename})`;
					const appid = getShortcutAppID({ AppName, exe });
					AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: `export __GAME_PATH__="${filename}" && %command%` });
					for (let j = 0; j < tags?.length; j++) {
						const tag = tags[j];
						if (!tag) continue;
						await AddToCats(appid, tag);
					}
				}
			}
		} else if (outfile.endsWith('install.out')) {
			const tags = ['Ryujinx', 'Install'];
			const StartDir = __path__.dirname(outfile);
			const exe = JSON.stringify(outfile);
			const AppName = '[Ryujinx] Install';
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
		} else if (outfile.endsWith('install_keys.out')) {
			const tags = ['Ryujinx', 'Install'];
			const StartDir = __path__.dirname(outfile);
			const exe = JSON.stringify(outfile);
			const AppName = '[Ryujinx] Install Keys';
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir });
			for (let j = 0; j < tags?.length; j++) {
				const tag = tags[j];
				if (!tag) continue;
				await AddToCats(appid, tag);
			}
		} else if (outfile.endsWith('download_firmware.out')) {
			const tags = ['Ryujinx', 'Install'];
			const StartDir = __path__.dirname(outfile);
			const exe = JSON.stringify(outfile);
			const AppName = '[Ryujinx] Download Firmware';
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
