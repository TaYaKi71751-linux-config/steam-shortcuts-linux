import { basename, dirname } from 'path';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getOpenVPNConfigRemote, getOpenVPNConfigs, getWhichOpenVPN } from '../util/OpenVPN';
import { execSync } from 'child_process';
import { getIPLocation } from '../util/GeoIP';

const outFiles = getOpenVPNConfigs();

RemoveShortcutStartsWith({ AppName: '[OpenVPN]' });

(function () {
	const StartDir = `${process.env.HOME}`;
	const exe = `${execSync('which pkill')?.toString().split('\n')[0]}`;
	const AppName = '[OpenVPN] Kill';
	AddShortcut({ AppName, exe, StartDir, LaunchOptions: 'sudo %command% openvpn' });
})();
outFiles
	.forEach((OpenVPNConfigPath) => {
		const StartDir = dirname(OpenVPNConfigPath);
		const exe = getWhichOpenVPN();
		let remote_address = '';
		let remote_isp = '';
		let remote_country = '';
		try {
			remote_address = getOpenVPNConfigRemote(OpenVPNConfigPath)?.address;
		} catch (e) {
			console.error(e);
			return;
		}
		if (remote_address) {
			try {
				const remote_location = getIPLocation(remote_address);
				if (typeof remote_location?.isp == 'string') remote_isp = remote_location?.isp;
				if (typeof remote_location?.country == 'string') remote_country = remote_location?.country;
			} catch (e) {
				console.error(e);
			}
		}

		const AppName = `[OpenVPN] (${(() => {
			if (!remote_address) return basename(OpenVPNConfigPath);
			if (!remote_isp || !remote_country) return remote_address;
			return `${remote_country},${remote_isp},${remote_address}`;
		})()})`;
		AddShortcut({ AppName, exe, StartDir, LaunchOptions: `sudo %command% "${OpenVPNConfigPath}"` });
	});
