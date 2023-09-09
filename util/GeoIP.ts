import { execSync } from 'child_process';

export function getIPLocation (target:string):undefined | {
	'status': `${'success'|'fail'}`,
	'country'?:string,
	'message'?:string,
	'query':string,
	'countryCode'?:string,
	'region'?:string,
	'regionName'?:string,
	'city'?:string,
	'zip'?:string,
	'lat'?:number,
	'lon'?:number,
	'timezone'?:string,
	'isp'?:string,
	'org'?:string,
	'as'?:string,
} {
	try {
		const result = JSON.parse(`${execSync(`curl 'https://demo.ip-api.com/json/${target}'\
	-H 'User-Agent: Mozilla/5.0' \
	-H 'Referer: https://ip-api.com/' \
	-H 'Origin: https://ip-api.com' \
	-H 'DNT: 1' \
	-H 'Cache-Control: no-cache'
	`)}`);
		return result;
	} catch (e) {
		console.error(e);
	}
}
