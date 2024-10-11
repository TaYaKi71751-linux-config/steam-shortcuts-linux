import { execSync } from 'child_process';

export function getExitNodes () {
	const up = execSync('bash sh/tailscale/up.sh').toString();
	console.log(`${up}`);
	const binPath = `${execSync(`find ${process.env.HOME} -type f -name \'tailscale\' 2> /dev/null || true`)}`.split('\n')[0];
	console.log(binPath);
	if (!binPath) throw new Error('Cannot find tailscale');
	const statusBuffer = execSync(`${binPath} status --json`);
	if (!statusBuffer?.toString) return [];
	const statusString:string = statusBuffer.toString();
	const statusObject:any = JSON.parse(statusString);
	const exitNodes = Object.entries(statusObject.Peer).filter(([nodekey, props]:any) => (
		props.ExitNodeOption
	)).map(([nodekey, props]:any) => ([props.DNSName, props.TailscaleIPs]));
	console.log(exitNodes);
	return exitNodes;
}
