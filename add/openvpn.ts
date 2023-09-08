import { basename, dirname } from 'path';
import { AddShortcut } from '../util/Shortcut';
import { getOpenVPNConfigs, getWhichOpenVPN } from '../util/OpenVPN';
import { execSync } from 'child_process';

const outFiles = getOpenVPNConfigs();

(function () {
	const StartDir = `${process.env.HOME}`;
	const exe = `${execSync('which pkill')?.toString()}`;
	const AppName = '[OpenVPN] Kill';
	AddShortcut({ AppName, exe, StartDir, LaunchOptions: 'sudo %command% openvpn' });
})();
outFiles
	.forEach((OpenVPNConfigPath) => {
		const StartDir = dirname(OpenVPNConfigPath);
		const exe = getWhichOpenVPN();
		const AppName = `[OpenVPN] (${basename(OpenVPNConfigPath)})`;
		AddShortcut({ AppName, exe, StartDir, LaunchOptions: `sudo %command% "${OpenVPNConfigPath}"` });
	});
