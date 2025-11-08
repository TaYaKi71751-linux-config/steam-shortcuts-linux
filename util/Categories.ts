import { execSync } from 'child_process';
import fs from 'fs';
import * as VDF from 'vdf-parser';

const SteamCat = require('steam-categories');
const path = require('path');

// %LOCALAPPDATA%/Steam/htmlcache/Local Storage/leveldb
const levelDBPath = path.join(process.env.HOME, '.steam', 'steam', 'config', 'htmlcache', 'Local Storage', 'leveldb');

const userdataPath = path.join(process.env.HOME, '.steam', 'steam', 'userdata');
// Supply leveldb path and Steam3 ID of user whose collections to edit

export async function AddToCats(appid: number, cat: string) {
	const user_ids = fs.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const localconfig_vdf_path = path.join(
				userdataPath,
				user_id,
				'config',
				'localconfig.vdf'
			);
			if (!fs.existsSync(localconfig_vdf_path)) { return; }
			let localconfig_vdf = fs.readFileSync(localconfig_vdf_path).toString();
			if (!localconfig_vdf.length) { return; }
			let localconfig: any = VDF.parse(`${localconfig_vdf}`, { types: false, arrayify: false });
			localconfig.UserLocalConfigStore = Object.assign({}, localconfig.UserLocalConfigStore);
			localconfig.UserLocalConfigStore.WebStorage = Object.assign({}, localconfig.UserLocalConfigStore.WebStorage);
			let user_collections = JSON.parse(`${localconfig.UserLocalConfigStore.WebStorage['user-collections'].replaceAll(/\\/g, '')}`);
			if (user_collections[`${cat.toLowerCase().replaceAll(/^[a-zA-Z0-9]/g, '-')}`]) {
				if (!user_collections[`${cat.toLowerCase().replaceAll(/^[a-zA-Z0-9]/g, '-')}`].added.includes(appid)) {
					return;
				} else {
					user_collections[`${cat.toLowerCase().replaceAll(/^[a-zA-Z0-9]/g, '-')}`].added.push(appid);
				}
			} else {
				user_collections[`${cat.toLowerCase().replaceAll(/^[a-zA-Z0-9]/g, '-')}`] = {
					name: cat,
					id: `${cat.toLowerCase().replaceAll(/^[a-zA-Z0-9]/g, '-')}`,
					added: [appid],
					removed: []
				};
			}
			localconfig.UserLocalConfigStore.WebStorage['user-collections'] = JSON.stringify(user_collections).replaceAll(/"/g, '\\"');
			localconfig_vdf = VDF.stringify(localconfig, { pretty: true, indent: '\t' });
			fs.writeFileSync(localconfig_vdf_path, localconfig_vdf);
		});
}
