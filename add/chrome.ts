import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';

const outPath = path.join(
	`${process.env.PWD}`,
	'out',
	'chrome'
);
const PAGE_URLS = [
	{ name: 'Twitch', url: 'https://twitch.tv' },
	{ name: 'YouTube TV', url: 'https://youtube.com/tv' },
	{ name: 'bilibili', url: 'https://bilibili.com' },
	{ name: '[OTT]Coupang Play', url: 'https://coupangplay.com/profiles' },
	{ name: '[OTT]Crunchyroll', url: 'https://crunchyroll.com' },
	{ name: '[OTT]Netflix', url: 'https://netflix.com' },
	{ name: '[OTT]Laftel', url: 'https://laftel.net/profile' },
	{ name: '[OTT]Watcha', url: 'https://watcha.com/manage_profiles' },
	{ name: '[OTT]Wavve', url: 'https://www.wavve.com' },
	{ name: '[OTT]Tubi', url: 'https://www.tubitv.com' },
	{ name: '[Dashboard]Twitter Analytics', url: 'https://analytics.twitter.com' },
	{ name: '[Dashboard]Twitch Dashboard', url: 'https://dashboard.twitch.tv/stream-manager' },
	{ name: '[Dashboard]YouTube Studio', url: 'https://studio.youtube.com' },
	{ name: '[Social]Twitter', url: 'https://twitter.com' }
];

const outFiles = fs.readdirSync(outPath);
outFiles
	.forEach((filename) => {
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		const AppName = '[Flatpak][Chrome]' + (function () {
			switch (filename) {
			case 'kiosk.out': return '[kiosk]';
			}
		})();
		if (filename == 'kiosk.out') {
			PAGE_URLS
				.forEach(({ name, url }) => {
					AddShortcut({ AppName: AppName + name, exe, StartDir, LaunchOptions: `PAGE_URL="${url}" %command%` });
				});
		}
	});
