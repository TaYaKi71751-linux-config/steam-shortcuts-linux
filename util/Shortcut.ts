import { getShortcutUrl, readVdf, writeVdf } from 'steam-binary-vdf';
import * as VDF from 'vdf-parser';
import fs from 'fs';
import path from 'path';
import { exit } from 'process';


const userdataPath = path.join(
	`${process.env.HOME}`,
	'.steam',
	'steam',
	'userdata'
);

export function AddSteamGameShortcut (_opts:{
		appid: number,
  LaunchOptions: string,
}) {
	const user_ids = fs.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const config_vdf_path = path.join(
				userdataPath,
				user_id,
				'config',
				'localconfig.vdf'
			);
			if (!fs.existsSync(config_vdf_path)) { exit(); }
			const config_vdf = fs.readFileSync(config_vdf_path);
			if (!config_vdf.length) { exit(); }
			let config:any = VDF.parse(`${config_vdf}`, { types: false, arrayify: false });
			config.UserLocalConfigStore = Object.assign({}, config.UserLocalConfigStore);
			config.UserLocalConfigStore.Software = Object.assign({}, config.UserLocalConfigStore.Software);
			config.UserLocalConfigStore.Software.Valve = Object.assign({}, config.UserLocalConfigStore.Software.Valve);
			config.UserLocalConfigStore.Software.Valve.Steam = Object.assign({}, config.UserLocalConfigStore.Software.Valve.Steam);
			config.UserLocalConfigStore.Software.Valve.Steam.apps = Object.assign({}, config.UserLocalConfigStore.Software.Valve.Steam.apps);
			config.UserLocalConfigStore.Software.Valve.Steam.apps[`${_opts.appid}`] = Object.assign({}, config.UserLocalConfigStore.Software.Valve.Steam.apps[`${_opts.appid}`], Object.fromEntries(Object.entries(_opts).filter(([k,v]) => (k != 'appid'))));
			config = VDF.stringify(config, { pretty: true, indent: '\t' });
			fs.writeFileSync(config_vdf_path, config);
		});
}

export function AddShortcut (_opts:{
		appid: number,
  AppName: string,
  exe: string,
  StartDir?: string,
  icon?: string,
  ShortcutPath?: string,
  LaunchOptions?: string,
  IsHidden?: number,
  AllowDesktopConfig?: number,
  AllowOverlay?: number,
  openvr?: number,
  Devkit?: number,
  DevkitGameID?: string,
  LastPlayTime?: number,
  tags?: string[],
		steam?:boolean,
}) {
	if(typeof _opts.steam == 'undefined'){
		AddNonSteamGameShortcut(_opts);
	} else if (_opts.steam) {
		AddSteamGameShortcut({appid:_opts.appid,LaunchOptions:_opts.LaunchOptions ?? '%command%'});
	} else {
		AddNonSteamGameShortcut(_opts);
	}
}

export function AddNonSteamGameShortcut (_opts:{
		appid: number,
  AppName: string,
  exe: string,
  StartDir?: string,
  icon?: string,
  ShortcutPath?: string,
  LaunchOptions?: string,
  IsHidden?: number,
  AllowDesktopConfig?: number,
  AllowOverlay?: number,
  openvr?: number,
  Devkit?: number,
  DevkitGameID?: string,
  LastPlayTime?: number,
  tags?: string[],
		steam?:boolean,
}) {
	const user_ids = fs.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const shortcutsPath = path.join(
				userdataPath,
				user_id,
				'config',
				'shortcuts.vdf'
			);
			let inBuffer:Buffer = Buffer.from([]);
			let shortcuts:any = {};

			if (!fs.existsSync(shortcutsPath)) {
				if (!fs.existsSync(path.dirname(shortcutsPath))) {
					fs.mkdirSync(path.dirname(shortcutsPath), { recursive: true });
				}
				fs.writeFileSync(shortcutsPath, '');
			} else {
				inBuffer = fs.readFileSync(shortcutsPath);
				if (inBuffer.length) shortcuts = readVdf(inBuffer)?.shortcuts;
			}

			const _i = Object.entries(shortcuts).map(([index, shortcut]:any) => (
				shortcut.AppName === _opts?.AppName ? index : undefined
			)).filter((index) => (typeof index != 'undefined'))[0];
			shortcuts[`${typeof _i != 'undefined' ? _i : Object.entries(shortcuts).length}`] = Object.assign(
				{},
				_opts,
				(_opts?.tags?.length ? {tags:Object.fromEntries(_opts?.tags.map((t,i:any)=>([`${i}`,t])))} : undefined
			));

			console.log(`Add '${_opts?.AppName} (${_opts?.exe})' shortcuts to ${shortcutsPath}`);

			//			console.log(shortcuts);

			const outBuffer = Buffer.concat([Buffer.from([0]), Buffer.from('shortcuts'), Buffer.from([0]), writeVdf(shortcuts), Buffer.from([0x08, 0x08])]);

			fs.writeFileSync(shortcutsPath, outBuffer);
		});
}

export function RemoveShortcutStartsWith (_opts:{
  AppName: string,
}) {
	const user_ids = fs.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const shortcutsPath = path.join(
				userdataPath,
				user_id,
				'config',
				'shortcuts.vdf'
			);
			let inBuffer:Buffer = Buffer.from([]);
			let shortcuts:any = {};

			if (!fs.existsSync(shortcutsPath)) {
				if (!fs.existsSync(path.dirname(shortcutsPath))) {
					fs.mkdirSync(path.dirname(shortcutsPath), { recursive: true });
				}
				fs.writeFileSync(shortcutsPath, '');
			} else {
				inBuffer = fs.readFileSync(shortcutsPath);
				if (inBuffer.length) shortcuts = readVdf(inBuffer)?.shortcuts;
			}

			const _i = Object.entries(shortcuts).map(([index, shortcut]:any) => (
				shortcut.AppName.startsWith(_opts?.AppName) ? index : undefined
			)).filter((index) => (typeof index != 'undefined'));
			_i.forEach((index) => {
				Object.entries(shortcuts[`${index}`]).forEach(([key, value]) => {
					shortcuts[`${index}`][key] = '';
				});
			});

			console.log(`Remove startsWith('${_opts?.AppName}') shortcuts to ${shortcutsPath}`);

			//			console.log(shortcuts);

			const outBuffer = Buffer.concat([Buffer.from([0]), Buffer.from('shortcuts'), Buffer.from([0]), writeVdf(shortcuts), Buffer.from([0x08, 0x08])]);

			fs.writeFileSync(shortcutsPath, outBuffer);
		});
}

export function TrimShortcuts () {
	const user_ids = fs.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const shortcutsPath = path.join(
				userdataPath,
				user_id,
				'config',
				'shortcuts.vdf'
			);
			let inBuffer:Buffer = Buffer.from([]);
			let shortcuts:any = {};

			if (!fs.existsSync(shortcutsPath)) {
				if (!fs.existsSync(path.dirname(shortcutsPath))) {
					fs.mkdirSync(path.dirname(shortcutsPath), { recursive: true });
				}
				fs.writeFileSync(shortcutsPath, '');
			} else {
				inBuffer = fs.readFileSync(shortcutsPath);
				if (inBuffer.length) shortcuts = readVdf(inBuffer)?.shortcuts;
			}

			const _i = Object.entries(shortcuts).map(([index, shortcut]:any) => (
				shortcut.AppName === '' ? index : undefined
			)).filter((index) => (typeof index != 'undefined'));
			_i.forEach((index) => {
				Object.entries(shortcuts[`${index}`]).forEach(([key, value]) => {
					delete shortcuts[`${index}`];
				});
			});

			console.log(`Trim shortcuts to ${shortcutsPath}`);

			console.log(shortcuts);

			const outBuffer = Buffer.concat([Buffer.from([0]), Buffer.from('shortcuts'), Buffer.from([0]), writeVdf(shortcuts), Buffer.from([0x08, 0x08])]);

			fs.writeFileSync(shortcutsPath, outBuffer);
		});
}
