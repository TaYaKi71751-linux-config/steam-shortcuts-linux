import { getShortcutUrl } from 'steam-binary-vdf';

export function getShortcutAppID ({
	AppName,
	exe
}:{
	AppName: string,
	exe: string
}):number {
	const s = getShortcutUrl(AppName, exe).split('/');
	return Number((BigInt(s[s.length - 1]) % BigInt('0xFFFFFFFF')).toString());
}
