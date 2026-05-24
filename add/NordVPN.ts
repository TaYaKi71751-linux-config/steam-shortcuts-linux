import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';
import { setBackground, setCapsule, setLogo, setWideCapsule } from '../util/Grid';
import fs from 'fs';
const __GAME_NAME__ = 'NordVPN';
const __OUT_NAME__ = 'nordvpn';
const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
let apps = [
	{AppName: '[NordVPN] Install', exe: path.join(outPath, 'install.out'), StartDir: outPath, LaunchOptions: '%command%'},
	{AppName: 'NordVPN', exe: path.join(outPath, 'launch.out'), StartDir: outPath, LaunchOptions: '%command%'},
];

export async function __main__ () {

	// Lutris
	{
		const tags = [__GAME_NAME__];
		for (let i = 0; i < apps?.length; i++) {
			const { compat, AppName, exe, StartDir, icon, background, wideCapsule, capsule, logo, LaunchOptions }:any = apps[i];
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, icon: icon ?? '', LaunchOptions });
			if(compat){
				AddCompat({
					appid: `${appid}`,
					compat: compat,
				});
			}
			if (background){
				setBackground({
					appid,
					path: background,
				});
			}
			if (wideCapsule){
				setWideCapsule({
					appid,
					path: wideCapsule,
				});
			}
			if(capsule){
				setCapsule({
					appid,
					path: capsule,
				});
			}
			if(logo){
				setLogo({
					appid,
					path: logo,
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
