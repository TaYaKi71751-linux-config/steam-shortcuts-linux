import { basename, dirname } from 'path';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getOpenVPNConfigs, getWhichOpenVPN } from '../util/OpenVPN';

const outFiles = getOpenVPNConfigs();
RemoveShortcutStartsWith({ AppName: '[OpenVPN]' });
outFiles
	.forEach((OpenVPNConfigPath:string) => {
		const StartDir = dirname(OpenVPNConfigPath);
		const exe = getWhichOpenVPN();
		const AppName = `[OpenVPN] (${basename(OpenVPNConfigPath)})`;
		AddShortcut({ AppName, exe, StartDir, LaunchOptions: `sudo %command% ${OpenVPNConfigPath}` });
	});
