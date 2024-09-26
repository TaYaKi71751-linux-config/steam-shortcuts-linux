import { execSync } from 'child_process'
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';
import fs from 'fs';

export async function __main__ () {
	const __OUT_NAME__ = 'battlenet';

	// Lutris
	{
		const tags = [__GAME_NAME__,'Lutris'];
		const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
		const outFiles = fs.readdirSync(outPath);
		for (let i = 0; i < outFiles?.length; i++) {
			const filename = outFiles[i];
			const StartDir = outPath;
			const exe = path.join(outPath, filename);
			const AppName = `[Lutris] ` + (() => {
				switch(filename){
					case 'install_battlenet.out': return 'Install Battle.net';
					case 'launch_battlenet.out': return 'Battle.net';
					case 'launch_d2r.out': return 'Diablo II Resurrected';
				}
			})();
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
