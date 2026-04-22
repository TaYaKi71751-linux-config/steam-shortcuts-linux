import { getShortcutAppID } from '../util/AppID';
import { AddShortcut } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path from 'path';
const __GAME_NAME__ = 'Netmarble';
const __OUT_NAME__ = 'netmarble';
const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
let apps = [
	{AppName: '[Lutris] Install Mongil: Star Dive', exe: path.join(outPath, 'install_mongil.out'), StartDir: outPath, LaunchOptions: '%command%'},
	{AppName: '[Lutris] Mongil: Star Dive Launcher', exe: path.join(outPath, 'launch_mongil_launcher.out'), StartDir: outPath,LaunchOptions:'%command%'},
	{AppName: '[Proton] Mongil: Star Dive Launcher', exe: `"${process.env.HOME}/Games/mongil/drive_c/Program Files/Netmarble/Netmarble Launcher/Netmarble Launcher.exe"`, StartDir: `"${process.env.HOME}/Games/mongil/drive_c/Program Files/Netmarble/Netmarble Launcher/"`, compat:'proton_experimental', LaunchOptions:`STEAM_COMPAT_DATA_PATH="${process.env.HOME}/Games/mongil" %command%` },
];

export async function __main__ () {

	{
		const tags = [__GAME_NAME__,'Netmarble'];
		for (let i = 0; i < apps?.length; i++) {
			const { AppName, exe, StartDir, LaunchOptions, compat } = apps[i];
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions });
			if(compat){
				AddCompat({
					appid: `${appid}`,
					compat: compat,
				});
			}
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
