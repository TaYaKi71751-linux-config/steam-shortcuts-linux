import { execSync } from 'child_process';
import { existsSync, readdirSync } from 'fs';

const SteamCat = require('steam-categories');
const path = require('path');

// %LOCALAPPDATA%/Steam/htmlcache/Local Storage/leveldb
const levelDBPath = path.join(process.env.HOME, '.steam', 'steam', 'config', 'htmlcache', 'Local Storage', 'leveldb');

const userdataPath = path.join(process.env.HOME, '.steam', 'steam', 'userdata');
// Supply leveldb path and Steam3 ID of user whose collections to edit

export async function AddToCats (appid:number, cat:string) {
	console.log(appid, cat);
	const is_steam_running = execSync('ps -A | grep steam || true').toString().split('\n').filter((t:any) => (t))?.length;
	if (existsSync(path.join(levelDBPath, 'LOCK'))) execSync(`rm ${JSON.stringify(path.join(levelDBPath, 'LOCK'))}`).toString();
	console.log(is_steam_running);
	const user_ids = readdirSync(userdataPath);
	for (let i = 0; i < user_ids?.length; i++) {
		const user_id = user_ids[i];
		if (user_id === '0') continue;
		const cats = new SteamCat(levelDBPath, user_id);
		const { collections } = await cats.read();
		let col:any = cats.get(cat.toLowerCase().replaceAll(/[^a-zA-Z0-9]/g, '_'));
		if (col) {
			if (col.is_deleted) {
				cats.remove(cat.toLowerCase().replaceAll(/[^a-zA-Z0-9]/g, '-'));
				col = undefined;
			}
			if (col && !(col?.value?.added?.filter((_appid:any) => (Number(`${_appid}`) === Number(`${appid}`)))?.length)) {
				col.value.added.push(appid);
			}
		}
		if (!col) {
			col = cats.add(cat.toLowerCase().replaceAll(/[^a-zA-Z0-9]/g, '_'), {
				name: cat,
				added: [appid]
			});
		}
		await cats.save();
		await cats.close();
		console.info('Database closed, safe to open Steam again.');
	}
}
