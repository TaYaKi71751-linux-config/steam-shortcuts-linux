import { execSync } from 'child_process';

export function getOpenVPNConfigs () {
	let r:string = '';
	try {
		r = execSync('find / -type f -name \'*.ovpn\' 2> /dev/null')?.toString();
	} catch (e:any) {
		r = `${e?.stdout?.toString()}`;
	}
	return r.split('\n').filter((c:string) => (c?.length));
}

export function getWhichOpenVPN () {
	return `${execSync('which openvpn')?.toString()}`.split('\n')[0];
}