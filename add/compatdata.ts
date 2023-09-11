import path from 'path';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

const compatdataPath:string = path.join(
	`${process.env.HOME}`,
	'.steam',
	'steam',
	'steamapps',
	'compatdata'
);

export async function __main__ () {
	const StartDir: string = `${process.env.HOME}`;
	const AppName: string = '[compatdata] Clear compatdata';
	const exe: string = '/usr/bin/true';
	const tags = ['compatdata'];
	const opts = { AppName, exe, StartDir, LaunchOptions: `cd ${compatdataPath} && rm -rf ${compatdataPath}` };
	const appid = getShortcutAppID(opts);
	AddShortcut(Object.assign({ appid, tags }, opts));
	for (let j = 0; j < tags?.length; j++) {
		const tag = tags[j];
		if (!tag) continue;
		await AddToCats(appid, tag);
	}
}
