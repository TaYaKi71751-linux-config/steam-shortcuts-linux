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

	let tags = ['OpenVPN'];
	const StartDir = `${process.env.PWD}/`;
	await (async function () {
		const exe = `${StartDir}/out/openvpn/kill.out`;
		const AppName = '[OpenVPN] Kill';
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: '%command%', tags });
		for (let i = 0; i < tags?.length; i++) {
			const tag = tags[i];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	})();

	await (async function () {
		const exe = `${StartDir}/out/openvpn/reload.out`;
		const AppName = '[OpenVPN] Reload';
		const appid = getShortcutAppID({ AppName, exe });
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: '%command%', tags });
		for (let i = 0; i < tags?.length; i++) {
			const tag = tags[i];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	})();

	await (async function () {
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
		// const StartDir = dirname(OpenVPNConfigPath);
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

		await (async () => {
		const exe = `${process.env.PWD}/out/openvpn/openvpn.out`;
			const AppName = `[OpenVPN] (${(() => {
			if (!remote_address) return basename(OpenVPNConfigPath);
			if (!remote_isp || !remote_country) return remote_address;
			return `${remote_country},${remote_isp},${remote_address}`;
		})()})`;
		const appid = getShortcutAppID({ AppName, exe });
		tags = ['OpenVPN'];
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: `export OPENVPN_CONFIG_PATH='${OpenVPNConfigPath}' && %command%`, tags });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
		})();
		await (async () => {
		const exe = `${process.env.PWD}/out/openvpn/openvpn_proton.out`;
			const AppName = `[OpenVPN][ProtonVPN] (${(() => {
			if (!remote_address) return basename(OpenVPNConfigPath);
			if (!remote_isp || !remote_country) return remote_address;
			return `${remote_country},${remote_isp},${remote_address}`;
		})()})`;
		const appid = getShortcutAppID({ AppName, exe });
		tags = ['OpenVPN','ProtonVPN'];
		if (OpenVPNConfigPath.includes('.protonvpn.')){
		AddShortcut({ appid, AppName, exe, StartDir, LaunchOptions: `export OPENVPN_CONFIG_PATH='${OpenVPNConfigPath}' && %command%`, tags });
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
		}
		})();
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
