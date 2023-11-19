import * as VDF from 'vdf-parser';
import fs from 'fs';
import path from 'path';
import { exit } from 'process';

const config_vdf_path = path.join(
	`${process.env.HOME}`,
	'.steam',
	'steam',
	'config',
	'config.vdf'
);

export function AddCompat ({ appid, compat }:{appid:string, compat?:string}) {
	if (!fs.existsSync(config_vdf_path)) { exit(); }
	const config_vdf = fs.readFileSync(config_vdf_path);
	if (!config_vdf.length) { exit(); }
	let config:any = VDF.parse(`${config_vdf}`, { types: false, arrayify: false });
	config.InstallConfigStore = Object.assign({}, config.InstallConfigStore);
	config.InstallConfigStore.Software = Object.assign({}, config.InstallConfigStore.Software);
	config.InstallConfigStore.Software.Valve = Object.assign({}, config.InstallConfigStore.Software.Valve);
	config.InstallConfigStore.Software.Valve.Steam = Object.assign({}, config.InstallConfigStore.Software.Valve.Steam);
	config.InstallConfigStore.Software.Valve.Steam.CompatToolMapping = Object.assign({}, config.InstallConfigStore.Software.Valve.Steam.CompatToolMapping);
	config.InstallConfigStore.Software.Valve.Steam.CompatToolMapping[`${appid}`] = Object.assign({}, config.InstallConfigStore.Software.Valve.Steam.CompatToolMapping[`${appid}`], { name: compat || 'proton_experimental', config: config.InstallConfigStore.Software.Valve.Steam.CompatToolMapping[`${appid}`]?.config || '', priority: config.InstallConfigStore.Software.Valve.Steam.CompatToolMapping[`${appid}`]?.priority || '250' });
	config.InstallConfigStore.Software.Valve.Steam.Tools = Object.assign({}, config.InstallConfigStore.Software.Valve.Steam.Tools);
	config.InstallConfigStore.Software.Valve.Steam.Tools[`${appid}`] = Object.assign({}, config.InstallConfigStore.Software.Valve.Steam.Tools[`${appid}`], { SizeOnDisk: config.InstallConfigStore.Software.Valve.Steam.Tools[`${appid}`]?.SizeOnDisk || '0' });
	config = VDF.stringify(config, { pretty: true, indent: '\t' });
	fs.writeFileSync(config_vdf_path, config);
}
