import { basename, dirname } from 'path';
import { AddShortcut, RemoveShortcutStartsWith } from '../util/Shortcut';
import { getOpenVPNConfigRemote, getOpenVPNConfigs, getWhichOpenVPN } from '../util/OpenVPN';
import { execSync } from 'child_process';
import { getIPLocation } from '../util/GeoIP';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

export async function __main__ () {
	const outFiles = getOpenVPNConfigs();

	RemoveShortcutStartsWith({ AppName: '[OpenVPN]' });

	const tags = ['OpenVPN'];
	await (async function () {
		const StartDir = `${process.env.HOME}`;
		const exe = `${execSync('which pkill')?.toString().split('\n')[0]}`;
		const AppName = '[OpenVPN] Kill';
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: 'sudo %command% openvpn', tags });
		for (let i = 0; i < tags?.length; i++) {
			const tag = tags[i];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	})();

	await (async function () {
		const StartDir = `${process.env.HOME}`;
		const exe = `${execSync('which rm')?.toString().split('\n')[0]}`;
		const AppName = '[OpenVPN] Remove All .ovpn';
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: 'find / -type f -name \'*.ovpn\' -exec %command% \'{}\' \\;', tags });
		for (let i = 0; i < tags?.length; i++) {
			const tag = tags[i];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	})();

	for (let i = 0; i < outFiles?.length; i++) {
		const OpenVPNConfigPath = outFiles[i];
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
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: `sudo %command% "${OpenVPNConfigPath}"`, tags });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	}
}
