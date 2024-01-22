import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { getShortcutAppID } from '../util/AppID';
import { AddToCats } from '../util/Categories';
import { setBackground, setCapsule, setLogo, setWideCapsule } from '../util/Grid';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'chrome'
);
const PAGE_URLS = [
	{ name: 'VPNGate', url: 'https://vpngate.net', tags: ['VPN'] },
	{ name: '爱壹帆', url: 'https://www.iyf.tv', tags: ['OTT', 'Video'], icon: `${process.env.PWD}/image/icon/iyf.png`, background: `${process.env.PWD}/image/background/iyf.png`, capsule: `${process.env.PWD}/image/capsule/iyf.png`, widecapsule: `${process.env.PWD}/image/widecapsule/iyf.png`, logo: `${process.env.PWD}/image/logo/iyf.png` },
	{ name: 'Abema TV', url: 'https://abema.tv', tags: ['Live', 'OTT'], icon: `${process.env.PWD}/image/icon/abema.ico`, logo: `${process.env.PWD}/image/logo/abema.png`, capsule: `${process.env.PWD}/image/capsule/abema.png`, background: `${process.env.PWD}/image/background/abema.png`, widecapsule: `${process.env.PWD}/image/widecapsule/abema.png` },
	{ name: 'Twitch', url: 'https://twitch.tv', tags: ['Live', 'Video'], icon: `${process.env.PWD}/image/icon/twitch.png`, logo: `${process.env.PWD}/image/logo/twitch.png`, capsule: `${process.env.PWD}/image/capsule/twitch.png`, widecapsule: `${process.env.PWD}/image/widecapsule/twitch.png`, background: `${process.env.PWD}/image/background/twitch.png` },
	{ name: 'YouTube', url: 'https://youtube.com/tv', tags: ['Live', 'Video'], icon: `${process.env.PWD}/image/icon/youtube.png`, logo: `${process.env.PWD}/image/logo/youtube.png`, capsule: `${process.env.PWD}/image/capsule/youtube.png`, widecapsule: `${process.env.PWD}/image/widecapsule/youtube.png`, background: `${process.env.PWD}/image/background/youtube.png` },
	{ name: 'bilibili', url: 'https://bilibili.com', tags: ['Video'], icon: `${process.env.PWD}/image/icon/bilibili.ico`, background: `${process.env.PWD}/image/background/bilibili.png`, capsule: `${process.env.PWD}/image/capsule/bilibili.png`, widecapsule: `${process.env.PWD}/image/widecapsule/bilibili.png`, logo: `${process.env.PWD}/image/logo/bilibili.png` },
	{ name: 'Coupang Play', url: 'https://coupangplay.com/profiles', tags: ['OTT'], icon: `${process.env.PWD}/image/icon/coupangplay.ico`, logo: `${process.env.PWD}/image/logo/coupangplay.png`, widecapsule: `${process.env.PWD}/image/widecapsule/coupangplay.png`, capsule: `${process.env.PWD}/image/capsule/coupangplay.png`, background: `${process.env.PWD}/image/background/coupangplay.jpg` },
	{ name: 'Crunchyroll', url: 'https://crunchyroll.com', tags: ['OTT'], icon: `${process.env.PWD}/image/icon/crunchyroll.png`, logo: `${process.env.PWD}/image/logo/crunchyroll.png`, widecapsule: `${process.env.PWD}/image/widecapsule/crunchyroll.png`, capsule: `${process.env.PWD}/image/capsule/crunchyroll.png`, background: `${process.env.PWD}/image/background/crunchyroll.png` },
	{ name: 'Netflix', url: 'https://netflix.com', tags: ['OTT'], icon: `${process.env.PWD}/image/icon/netflix.ico`, background: `${process.env.PWD}/image/background/netflix.jpg`, widecapsule: `${process.env.PWD}/image/widecapsule/netflix.jpg`, logo: `${process.env.PWD}/image/logo/netflix.png`, capsule: `${process.env.PWD}/image/capsule/netflix.jpg` },
	{ name: 'Laftel', url: 'https://laftel.net/profile', tags: ['OTT'], icon: `${process.env.PWD}/image/icon/laftel.png`, logo: `${process.env.PWD}/image/logo/laftel.png`, widecapsule: `${process.env.PWD}/image/widecapsule/laftel.png`, capsule: `${process.env.PWD}/image/capsule/laftel.png`, background: `${process.env.PWD}/image/background/laftel.png` },
	{ name: 'Watcha', url: 'https://watcha.com/manage_profiles', tags: ['OTT'], icon: `${process.env.PWD}/image/icon/watcha.ico`, background: `${process.env.PWD}/image/background/watcha.png`, capsule: `${process.env.PWD}/image/capsule/watcha.png`, widecapsule: `${process.env.PWD}/image/widecapsule/watcha.png`, logo: `${process.env.PWD}/image/logo/watcha.png` },
	{ name: 'Wavve', url: 'https://www.wavve.com', tags: ['OTT'], icon: `${process.env.PWD}/image/icon/wavve.ico`, background: `${process.env.PWD}/image/background/wavve.png`, capsule: `${process.env.PWD}/image/capsule/wavve.png`, widecapsule: `${process.env.PWD}/image/widecapsule/wavve.png`, logo: `${process.env.PWD}/image/logo/wavve.png` },
	{ name: 'Tubi', url: 'https://www.tubitv.com', tags: ['OTT'], icon: `${process.env.PWD}/image/icon/tubi.webp`, logo: `${process.env.PWD}/image/logo/tubi.png`, capsule: `${process.env.PWD}/image/capsule/tubi.png`, widecapsule: `${process.env.PWD}/image/widecapsule/tubi.png`, background: `${process.env.PWD}/image/background/tubi.png` },
	{ name: 'Twitter Analytics', url: 'https://analytics.twitter.com', tags: ['Dashboard'], icon: `${process.env.PWD}/image/icon/twitter.ico`, background: `${process.env.PWD}/image/background/twitteranalytics.png`, capsule: `${process.env.PWD}/image/capsule/twitteranalytics.png`, widecapsule: `${process.env.PWD}/image/widecapsule/twitteranalytics.png`, logo: `${process.env.PWD}/image/logo/twitteranalytics.png` },
	{ name: 'Twitch Dashboard', url: 'https://dashboard.twitch.tv/stream-manager', tags: ['Dashboard'], icon: `${process.env.PWD}/image/icon/twitch.png`, logo: `${process.env.PWD}/image/logo/twitch.png`, capsule: `${process.env.PWD}/image/capsule/twitch.png`, widecapsule: `${process.env.PWD}/image/widecapsule/twitch.png`, background: `${process.env.PWD}/image/background/twitch.png` },
	{ name: 'YouTube Studio', url: 'https://studio.youtube.com', tags: ['Dashboard'], icon: `${process.env.PWD}/image/icon/youtube.png`, logo: `${process.env.PWD}/image/logo/youtubestudio.png`, capsule: `${process.env.PWD}/image/capsule/youtubestudio.png`, widecapsule: `${process.env.PWD}/image/widecapsule/youtubestudio.png`, background: `${process.env.PWD}/image/background/youtubestudio.png` },
	{ name: 'Restream.io', url: 'https://app.restream.io', tags: ['Dashboard'], icon: `${process.env.PWD}/image/icon/restream.ico`, background: `${process.env.PWD}/image/background/restream.png`, capsule: `${process.env.PWD}/image/capsule/restream.png`, widecapsule: `${process.env.PWD}/image/widecapsule/restream.png`, logo: `${process.env.PWD}/image/logo/restream.png` },
	{ name: 'Twitter', url: 'https://twitter.com', tags: ['SNS', 'Social'], icon: `${process.env.PWD}/image/icon/twitter.ico`, background: `${process.env.PWD}/image/background/twitter.png`, capsule: `${process.env.PWD}/image/capsule/twitter.png`, widecapsule: `${process.env.PWD}/image/widecapsule/twitter.png`, logo: `${process.env.PWD}/image/logo/twitter.png` },
	{ name: 'MahjongSoul[EN]', url: 'https://mahjongsoul.game.yo-star.com/', tags: ['MahjongSoul'], icon: `${process.env.PWD}/image/icon/mahjongsoul.png` },
	{ name: 'MahjongSoul[KR]', url: 'https://mahjongsoul.game.yo-star.com/kr/index.html', tags: ['MahjongSoul'], icon: `${process.env.PWD}/image/icon/mahjongsoul.png` },
	{ name: 'MahjongSoul[JP]', url: 'https://game.mahjongsoul.com/index.html', tags: ['MahjongSoul'], icon: `${process.env.PWD}/image/icon/mahjongsoul.png` },
	{ name: 'Gmail', url: 'https://gmail.com', tags: ['Email'], icon: `${process.env.PWD}/image/icon/gmail.ico` },
	{ name: '网易免费邮箱(Netease Free Email)', url: 'https://email.163.com', tags: ['Email'], icon: `${process.env.PWD}/image/icon/neteasemail.ico` },
	{ name: 'Geolocation(Netflix)', url: 'https://geolocation.onetrust.com/cookieconsentpub/v1/geo/location', tags: ['geolocation'], icon: `${process.env.PWD}/image/icon/netflix.ico` }
];

export async function __main__ () {
	const outFiles = fs.readdirSync(outPath);
	for (let i = 0; i < outFiles?.length; i++) {
		const filename = outFiles[i];
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		if (filename == 'kiosk.out') {
			for (let j = 0; j < PAGE_URLS?.length; j++) {
				const { name, url, tags, icon, background, widecapsule, logo, capsule } = PAGE_URLS[j];
				const appid = getShortcutAppID({ AppName: name, exe });
				AddShortcut({ appid, AppName: name, exe, StartDir, LaunchOptions: `PAGE_URL="${url}" %command%`, tags, icon: icon ?? '' });
				if (background) {
					setBackground({
						appid,
						path: background
					});
				}
				if (widecapsule) {
					setWideCapsule({
						appid,
						path: widecapsule
					});
				}
				if (capsule) {
					setCapsule({
						appid,
						path: capsule
					});
				}
				if (logo) {
					setLogo({
						appid,
						path: logo
					});
				}
				for (let k = 0; k < tags?.length; k++) {
					const tag = tags[k];
					if (!tag) continue;
					await AddToCats(appid, tag);
				}
			}
		}
	}
}

// https://stackoverflow.com/questions/4981891/node-js-equivalent-of-pythons-if-name-main
if (typeof require !== 'undefined' && require.main === module) {
	__main__();
}
