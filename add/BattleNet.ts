import { execSync } from 'child_process'
import { existsSync } from 'fs';
import { getShortcutAppID } from '../util/AppID';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import path,{ dirname } from 'path';
import { setBackground, setCapsule, setLogo, setWideCapsule } from '../util/Grid';
import fs from 'fs';
export async function __main__ () {

	const __GAME_NAME__ = 'Battle.net';
	const __OUT_NAME__ = 'battlenet';
	const outPath = path.join(`${process.env.PWD}`, 'out', __OUT_NAME__);
	let apps = [
		{AppName: '[Lutris] Install Battle.net', exe: path.join(outPath, 'install_battlenet.out'), StartDir: outPath, LaunchOptions: '%command%', tags: [__GAME_NAME__, 'Lutris', 'Install']},
		{AppName: '[Lutris] Battle.net', exe: path.join(outPath, 'launch_battlenet.out'), StartDir: outPath,LaunchOptions:'%command%', tags: [__GAME_NAME__, 'Lutris']},
		{AppName: '[Proton] Battle.net', exe: `"${process.env.HOME}/Games/battlenet/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"`, StartDir: `"${process.env.HOME}/Games/battlenet/drive_c/Program Files (x86)/Battle.net/"`, compat:'proton_experimental', LaunchOptions:`STEAM_COMPAT_DATA_PATH="${process.env.HOME}/Games/battlenet" %command%`, tags: [__GAME_NAME__, 'Proton'] },
		{AppName: '[Proton] World of Warcraft', exe: `"${process.env.HOME}/Games/battlenet/pfx/drive_c/Program Files (x86)/World of Warcraft/_retail_/Wow.exe"`, StartDir: `"${process.env.HOME}/Games/battlenet/pfx/drive_c/Program Files (x86)/World of Warcraft/"`, compat:'proton_experimental', LaunchOptions:`STEAM_COMPAT_DATA_PATH="${process.env.HOME}/Games/battlenet" %command%`, tags: [__GAME_NAME__, 'World of Warcraft', 'Proton'], background: `${process.env.PWD}/image/background/wow.png`, wideCapsule: `${process.env.PWD}/image/widecapsule/wow.png`, capsule: `${process.env.PWD}/image/capsule/wow.png`, logo: `${process.env.PWD}/image/logo/wow.png`, icon: `${process.env.PWD}/image/icon/wow.ico` },
		{AppName: '[Proton] World of Warcraft Classic Era', exe: `"${process.env.HOME}/Games/battlenet/pfx/drive_c/Program Files (x86)/World of Warcraft/_classic_era_/WowClassic.exe"`, StartDir: `"${process.env.HOME}/Games/battlenet/pfx/drive_c/Program Files (x86)/World of Warcraft/"`, compat:'proton_experimental', LaunchOptions:`STEAM_COMPAT_DATA_PATH="${process.env.HOME}/Games/battlenet" %command%`, tags: [__GAME_NAME__, 'World of Warcraft', 'World of Warcraft Classic', 'Proton'], background: `${process.env.PWD}/image/background/wow_classic.jpg`, wideCapsule: `${process.env.PWD}/image/widecapsule/wow_classic.png`, capsule: `${process.env.PWD}/image/capsule/wow_classic.png`, logo: `${process.env.PWD}/image/logo/wow_classic.png`, icon: `${process.env.PWD}/image/icon/wow_classic.ico` },
		{AppName: '[Lutris] Launch Diablo II Resurrected', exe: path.join(outPath, 'launch_d2r.out'), StartDir: outPath,LaunchOptions:'%command%', tags: [__GAME_NAME__, 'Diablo II Resurrected', 'Lutris']},
		{AppName: '[Lutris] World of Warcraft', exe: path.join(outPath, 'launch_wow.out'), StartDir: outPath, tags: [__GAME_NAME__, 'World of Warcraft', 'Lutris'], background: `${process.env.PWD}/image/background/wow.png`, wideCapsule: `${process.env.PWD}/image/widecapsule/wow.png`, capsule: `${process.env.PWD}/image/capsule/wow.png`, logo: `${process.env.PWD}/image/logo/wow.png`, icon: `${process.env.PWD}/image/icon/wow.ico`,LaunchOptions: '%command%' },
		{AppName: '[World of Warcraft] Set locale to koKR', exe: path.join(outPath,'locale_wow.out'), StartDir: outPath, LaunchOptions: 'export LOCALE="koKR" && %command%', tags: [__GAME_NAME__, 'World of Warcraft']},
		{AppName: '[World of Warcraft] Set locale to zhCN', exe: path.join(outPath,'locale_wow.out'), StartDir: outPath, LaunchOptions: 'export LOCALE="zhCN" && %command%', tags: [__GAME_NAME__, 'World of Warcraft']},
		{AppName: '[World of Warcraft] Set locale to enUS', exe: path.join(outPath,'locale_wow.out'), StartDir: outPath, LaunchOptions: 'export LOCALE="enUS" && %command%', tags: [__GAME_NAME__, 'World of Warcraft']},
	];

	// Lutris
	{
		for (let i = 0; i < apps?.length; i++) {
			const { compat, AppName, exe, StartDir, icon, background, wideCapsule, capsule, logo, LaunchOptions, tags }:any = apps[i];
			const appid = getShortcutAppID({ AppName, exe });
			AddShortcut({ appid, AppName, exe, StartDir, icon: icon ?? '', LaunchOptions, tags });
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
