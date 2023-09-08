import { basename, dirname } from 'path';
import { AddShortcut } from '../util/Shortcut';
import { getOpenVPNConfigs, getWhichOpenVPN } from '../util/OpenVPN';

const outFiles = getOpenVPNConfigs();

outFiles
	.forEach((OpenVPNConfigPath) => {
		const StartDir = dirname(OpenVPNConfigPath);
		const exe = getWhichOpenVPN();
		const AppName = `[OpenVPN] (${basename(OpenVPNConfigPath)})`;
		AddShortcut({ AppName, exe, StartDir, LaunchOptions: `sudo %command% "${OpenVPNConfigPath}"` });
	});
