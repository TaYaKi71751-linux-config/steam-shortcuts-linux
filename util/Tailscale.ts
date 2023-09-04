import { execSync } from 'child_process';

export function getExitNodes () {
	const statusBuffer:Buffer = execSync('tailscale status --json');
	if (!statusBuffer?.toString) return [];
	const statusString:string = statusBuffer.toString();
	const statusObject:any = JSON.parse(statusString);
	const exitNodes = Object.entries(statusObject.Peer).filter(([nodekey, props]:any) => (
		props.ExitNodeOption
	)).map(([nodekey, props]:any) => ([props.DNSName, props.TailscaleIPs]));
	console.log(exitNodes);
	return exitNodes;
}
