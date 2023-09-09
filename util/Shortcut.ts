import { readVdf, writeVdf } from 'steam-binary-vdf';
import fs from 'fs';
import path from 'path';

const userdataPath = path.join(
	`${process.env.HOME}`,
	'.steam',
	'steam',
	'userdata'
);

export function AddShortcut (_opts:{
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
  tags?: any
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
			shortcuts[`${typeof _i != 'undefined' ? _i : Object.entries(shortcuts).length}`] = _opts;

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
				Object.entries(shortcut).filter(([key, value]) => (!value))?.length ? index : undefined
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
