import { AddShortcut } from '../util/Shortcut';
import { execSync } from 'child_process';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

export async function __main__ () {
	const StartDir: string = `${process.cwd()}`;
	const bashPath = `${execSync('which bash').toString().split('\n')[0]}`;
	const envPath = `${execSync('which env').toString().split('\n')[0]}`;
	const tags = ['flatpak'];

	const shortcuts = [{
		AppName: '[flatpak]Update All',
		exe: `${bashPath}`,
		StartDir,
		LaunchOptions: `${envPath} && %command% -c "find / -name 'flatpak' -type f -exec {} update -y \\\\;"`
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
