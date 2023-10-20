import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'chrome'
);
const PAGE_URLS = [
	{ name: 'VPNGate', url: 'https://vpngate.net', tags: ['VPN'] },
	{ name: 'Abema TV', url: 'https://abema.tv', tags: ['Live', 'OTT'] },
	{ name: 'Twitch', url: 'https://twitch.tv', tags: ['Live', 'Video'] },
	{ name: 'YouTube', url: 'https://youtube.com/tv', tags: ['Live', 'Video'] },
	{ name: 'bilibili', url: 'https://bilibili.com', tags: ['Video'] },
	{ name: 'Coupang Play', url: 'https://coupangplay.com/profiles', tags: ['OTT'] },
	{ name: 'Crunchyroll', url: 'https://crunchyroll.com', tags: ['OTT'] },
	{ name: 'Netflix', url: 'https://netflix.com', tags: ['OTT'] },
	{ name: 'Laftel', url: 'https://laftel.net/profile', tags: ['OTT'] },
	{ name: 'Watcha', url: 'https://watcha.com/manage_profiles', tags: ['OTT'] },
	{ name: 'Wavve', url: 'https://www.wavve.com', tags: ['OTT'] },
	{ name: 'Tubi', url: 'https://www.tubitv.com', tags: ['OTT'] },
	{ name: 'Twitter Analytics', url: 'https://analytics.twitter.com', tags: ['Dashboard'] },
	{ name: 'Twitch Dashboard', url: 'https://dashboard.twitch.tv/stream-manager', tags: ['Dashboard'] },
	{ name: 'YouTube Studio', url: 'https://studio.youtube.com', tags: ['Dashboard'] },
	{ name: 'Restream.io', url: 'https://app.restream.io', tags: ['Dashboard'] },
	{ name: 'Twitter', url: 'https://twitter.com', tags: ['SNS', 'Social'] },
	{ name: 'MahjongSoul[EN]', url: 'https://mahjongsoul.game.yo-star.com/', tags: ['MahjongSoul'] },
	{ name: 'MahjongSoul[KR]', url: 'https://mahjongsoul.game.yo-star.com/kr/index.html', tags: ['MahjongSoul'] },
	{ name: 'MahjongSoul[JP]', url: 'https://game.mahjongsoul.com/index.html', tags: ['MahjongSoul'] }
];

export async function __main__ () {
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		if (filename == 'kiosk.out') {
			for (let j = 0; j < PAGE_URLS?.length; j++) {
				const { name, url, tags } = PAGE_URLS[j];
				const appid = getShortcutAppID({ AppName: name, exe });
				AddShortcut({ appid, AppName: name, exe, StartDir, LaunchOptions: `PAGE_URL="${url}" %command%`, tags });
				for (let k = 0; k < tags?.length; k++) {
					const tag = tags[k];
					if (!tag) continue;
					await AddToCats(appid, tag);
				}
			}
		}
	}
}
