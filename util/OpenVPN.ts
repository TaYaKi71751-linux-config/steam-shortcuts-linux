import { execSync } from 'child_process';
import { existsSync, readFileSync } from 'fs';

export function getOpenVPNConfigs () {
	let r:string = '';
	try {
		r = execSync('find / -type f -name \'*.ovpn\' 2> /dev/null || true')?.toString();
	} catch (e:any) {
		r = `${e?.stdout?.toString()}`;
	}
	return r.split('\n').filter((c:string) => (c?.length));
}

export function getWhichOpenVPN () {
	return `${execSync('which openvpn')?.toString()}`.split('\n')[0];
}

export function getOpenVPNConfigRemote (path:string):{
	address:string,
	port:string
} {
	const _throw = (m:string) => { throw new Error(m); };
	if (!existsSync(path)) { _throw('File not Exists'); }
	const remote_line = `${readFileSync(path)}`.split('\n').filter((l:string) => (l.startsWith('remote')))[0];
	if (
		!remote_line.split(' ').length ||
			!remote_line.split(' ')[1] ||
			!remote_line.split(' ')[2]
	) { _throw('Cannot find remote in file'); }
	return {
		address: remote_line.split(' ')[1],
		port: remote_line.split(' ')[2]
	};
}
