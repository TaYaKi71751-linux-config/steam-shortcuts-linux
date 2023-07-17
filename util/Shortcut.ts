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
			if (!fs.existsSync(shortcutsPath)) return;
			console.log(`Add '${_opts?.AppName} (${_opts?.exe})' shortcuts to ${shortcutsPath}`);
			const inBuffer = fs.readFileSync(shortcutsPath);
			const { shortcuts }:any = readVdf(inBuffer);
			const _i = Object.entries(shortcuts).map(([index, shortcut]:any) => (
				shortcut.AppName === _opts?.AppName ? index : undefined
			)).filter((index) => (typeof index != 'undefined'))[0];
			shortcuts[`${typeof _i != 'undefined' ? _i : Object.entries(shortcuts).length}`] = _opts;
			const outBuffer = Buffer.concat([Buffer.from([0]), Buffer.from('shortcuts'), Buffer.from([0]), writeVdf(shortcuts), Buffer.from([0x08, 0x08])]);

			fs.writeFileSync(shortcutsPath, outBuffer);
		});
}
