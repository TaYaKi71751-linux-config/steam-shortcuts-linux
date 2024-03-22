import { execSync } from 'child_process';

export async function __main__ () {
	try {
		const r = execSync(`cp ${process.env.PWD}/controller_config/*.vdf ${process.env.HOME}/.steam/steam/controller_base/templates/`).toString();
		console.log(r);
	} catch (e) { console.error(e); }
}

if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
