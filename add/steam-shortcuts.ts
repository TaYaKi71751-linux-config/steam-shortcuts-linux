import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { execSync, spawnSync } from 'child_process';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

export async function __main__ () {
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
	const tags = ['steam-shortcuts'];

	const shortcuts = [{
		AppName: '[steam-shortcuts][Git] Pull',
		exe: `${bashPath}`,
		StartDir,
		LaunchOptions: `cd ${JSON.stringify(StartDir)} && find / -name 'git' -type f -exec {} pull \\;`
	},
	{
		AppName: '[steam-shortcuts][Bash] build bins',
		exe: `${bashPath}`,
		StartDir,
		LaunchOptions: `${envPath} && %command% ./build.sh`
	},
	{
		AppName: '[steam-shortcuts][pnpm] Add Steam Shortcuts',
		exe: `${bashPath}`,
		StartDir,
		LaunchOptions: `sudo -nv && export SUDO_EXECUTOR="sudo" || export SUDO_EXECUTOR="pkexec"; $SUDO_EXECUTOR bash -c "$(env) ; cd ${StartDir} && find / -name 'pnpm' -type f -exec ${bashPath} -c '{} add:steam &&  pkill find' \\;"`
	}];
	for (let i = 0; i < shortcuts?.length; i++) {
		const opts: {
			AppName: string,
			exe: string,
			StartDir: string,
			LaunchOptions: string,
		} = shortcuts[i];
		const appid = getShortcutAppID(opts);
		AddShortcut(Object.assign({ appid, tags }, opts));
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
