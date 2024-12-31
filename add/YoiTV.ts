import path from 'path';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { AddCompat } from '../util/Compatibilities';
import { execSync } from 'child_process';
import { existsSync } from 'fs';

const yoitv_path:string = path.join(
	`${process.env.HOME}`,
	'.local',
	'YoiTV'
);
const compatdataPath:string = path.join(
	`${process.env.HOME}`,
	'.steam',
	'steam',
	'steamapps',
	'compatdata'
);

function __check_file__ ():any {
	execSync(`mkdir -p ${yoitv_path}`);
	const zip = execSync(`find / -name 'yoitv.zip' -type f || true`).toString().replaceAll('\n','');
	console.log(zip);
	const extract = `cp '${zip}' ${JSON.stringify(yoitv_path)} && cd ${JSON.stringify(yoitv_path)} && unzip yoitv`;
	const findexe = `cd ${JSON.stringify(yoitv_path)} && find . -name '*.exe' -type f | head -n 1`;
		if (zip != '') {
			if (execSync(findexe).toString().replaceAll('\n', '') == '') {
				execSync(extract).toString();
			}
			const exe = `${path.join(yoitv_path, execSync(findexe).toString().replaceAll('\n', ''))}`;
			return `${exe}`;
		}
	console.warn('[Warn] Could not found yoitv.zip');
	return '';
}

export async function __main__ () {
	let yappid:any = null;
	await (async function () {
		const AppName: string = 'YoiTV';
		const exe: string = `${__check_file__()}`;
		if(exe == ''){
			return '';
		}
		const StartDir: string = `${exe}`;
		const tags = ['YoiTV', 'TV'];
		const opts = { AppName, exe, StartDir, LaunchOptions: '%command%' };
		const appid = getShortcutAppID(opts);
		yappid = appid;
		AddCompat({ appid: `${appid}`, compat: 'proton_experimental' });
		AddShortcut(Object.assign({ appid, tags }, opts));
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	})();
	await (async function () {
		const AppName: string = 'YoiTV clear compat';
		const tags = ['YoiTV', 'TV'];
		const StartDir: string = `${process.env.HOME}`;
		const exe: string = '/usr/bin/true';
		const ycp = path.join(compatdataPath, `${yappid}`);
		const opts = { AppName, exe, StartDir, LaunchOptions: `cd ${ycp} && rm -rf ${ycp}` };
		const appid = getShortcutAppID(opts);
		AddShortcut(Object.assign({ appid, tags }, opts));
		for (let j = 0; j < tags?.length; j++) {
			const tag = tags[j];
			if (!tag) continue;
			await AddToCats(appid, tag);
		}
	})();
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
