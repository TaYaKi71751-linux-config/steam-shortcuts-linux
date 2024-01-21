import * as FS from 'fs';
import * as PATH from 'path';

const userdataPath = PATH.join(
	`${process.env.HOME}`,
	'.steam',
	'steam',
	'userdata'
);

export function setBackground (input:{
	appid: number;
	path: string;
}) {
	const user_ids = FS.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const backgroundPath = PATH.join(
				userdataPath,
				user_id,
				'config',
				'grid',
				`${input.appid}_hero${PATH.extname(input.path)}`
			);
			FS.writeFileSync(backgroundPath, FS.readFileSync(input.path));
		});
}

export function setLogo (input:{
	appid: number;
	path: string;
}) {
	const user_ids = FS.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const backgroundPath = PATH.join(
				userdataPath,
				user_id,
				'config',
				'grid',
				`${input.appid}_logo${PATH.extname(input.path)}`
			);
			FS.writeFileSync(backgroundPath, FS.readFileSync(input.path));
		});
}

export function setWideCapsule (input:{
	appid: number;
	path: string;
}) {
	const user_ids = FS.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const backgroundPath = PATH.join(
				userdataPath,
				user_id,
				'config',
				'grid',
				`${input.appid}${PATH.extname(input.path)}`
			);
			FS.writeFileSync(backgroundPath, FS.readFileSync(input.path));
		});
}

export function setCapsule (input:{
	appid: number;
	path: string;
}) {
	const user_ids = FS.readdirSync(userdataPath);
	user_ids
		.forEach((user_id) => {
			const backgroundPath = PATH.join(
				userdataPath,
				user_id,
				'config',
				'grid',
				`${input.appid}p${PATH.extname(input.path)}`
			);
			FS.writeFileSync(backgroundPath, FS.readFileSync(input.path));
		});
}
