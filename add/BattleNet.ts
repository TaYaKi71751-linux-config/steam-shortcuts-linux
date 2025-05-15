import { execSync } from 'child_process'
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';
import { setBackground, setCapsule, setLogo, setWideCapsule } from '../util/Grid';
import fs from 'fs';
const __GAME_NAME__ = 'Battle.net';
const __OUT_NAME__ = 'battlenet';
const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
let apps:any = [
	{AppName: '[Lutris] Install Battle.net', exe: path.join(outPath, 'install_battlenet.out'), StartDir: outPath, LaunchOptions: '%command%'},
	{AppName: '[Lutris] Battle.net', exe: path.join(outPath, 'launch_battlenet.out'), StartDir: outPath,LaunchOptions:'%command%'},
	{AppName: '[Proton] Battle.net', exe: path.join(`${process.env.HOME}`,'Games','battlenet','drive_c','Program Files (x86)','Battle.net','Battle.net.exe'), StartDir: path.join(`${process.env.HOME}`,'Games','battlenet','drive_c','Program Files (x86)','Battle.net'), compat:'proton_experimental', LaunchOptions:`STEAM_COMPAT_DATA_PATH="${process.env.HOME}/Games/battlenet" %command%` },
	{AppName: '[Lutris] Launch Diablo II Resurrected', exe: path.join(outPath, 'launch_d2r.out'), StartDir: outPath,LaunchOptions:'%command%'},
	{AppName: '[Lutris] World of Warcraft', exe: path.join(outPath, 'launch_wow.out'), StartDir: outPath, background: `${process.env.PWD}/image/background/wow.png`, wideCapsule: `${process.env.PWD}/image/widecapsule/wow.png`, capsule: `${process.env.PWD}/image/capsule/wow.png`, logo: `${process.env.PWD}/image/logo/wow.png`, icon: `${process.env.PWD}/image/icon/wow.png`,LaunchOptions: '%command%' },
];

export async function __main__ () {

	// Lutris
	{
		const tags = [__GAME_NAME__,'Lutris'];
		for (let i = 0; i < apps?.length; i++) {
			const { compat, AppName, exe, StartDir, icon, background, wideCapsule, capsule, logo, LaunchOptions }:any = apps[i];
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, icon: icon ?? '', LaunchOptions });
			if(compat){
				AddCompat({
					`${appid}`,
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

	// WoW Locale
	{
		const tags = [__GAME_NAME__];
		const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
		const locales = ['koKR','zhCN','enUS'];
		for(let locale of locales){
			const exe = path.join(outPath,'locale_wow.out');
			const AppName = `[World of Warcraft] Set locale to ${locale}`;
			const LaunchOptions = `export LOCALE="${locale}" && %command%`;
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir: outPath, LaunchOptions });
			for(let tag of tags){
				if(!tag) continue;
				await AddToCats(appid, tag);
			}
		}
	}

}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
