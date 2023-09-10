import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { execSync, spawnSync } from 'child_process';

const StartDir: string = `${process.cwd()}`;
const gitPath = `${execSync('which git').toString().split('\n')[0]}`;
const bashPath = `${execSync('which bash').toString().split('\n')[0]}`;
const envPath = `${execSync('which env').toString().split('\n')[0]}`;
const teePath = `${execSync('which tee').toString().split('\n')[0]}`;
const pnpmPath = (() => {
	const arr = `${execSync('find / -type f -name \'pnpm\' 2> /dev/null || true')}`.split('\n');
	const r = arr.filter((p) => (p)).filter((p) => {
		const r = spawnSync(p, ['--help']);
		if (r.stdout) return true;
		return false;
	});
	console.log(r);
	return r[0];
})();

[{
	AppName: '[steam-shortcuts][Git] Pull TaYaKi71751/steam-shortcuts',
	exe: `${gitPath}`,
	StartDir,
	LaunchOptions: '%command% pull'
},
{
	AppName: '[steam-shortcuts][Bash] build bins',
	exe: `${bashPath}`,
	StartDir,
	LaunchOptions: `${envPath} && %command% ./build.sh`
},
{
	AppName: '[steam-shortcuts][pnpm] Add Steam Shortcuts',
	exe: `${pnpmPath}`,
	StartDir,
	LaunchOptions: `${bashPath} -c '${pnpmPath} i && ${pnpmPath} add:steam'`
}]
	.forEach((opts: {
		AppName: string,
		exe: string,
		StartDir: string,
		LaunchOptions: string,
	}) => {
		AddShortcut(opts);
	});
