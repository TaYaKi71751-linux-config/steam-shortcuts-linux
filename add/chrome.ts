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
	{ name: 'YouTube', url: 'https://youtube.com/tv' },
	{ name: 'bilibili', url: 'https://bilibili.com' },
	{ name: 'Coupang Play', url: 'https://coupangplay.com/profiles' },
	{ name: 'Crunchyroll', url: 'https://crunchyroll.com' },
	{ name: 'Netflix', url: 'https://netflix.com' },
	{ name: 'Laftel', url: 'https://laftel.net/profile' },
	{ name: 'Watcha', url: 'https://watcha.com/manage_profiles' },
	{ name: 'Wavve', url: 'https://www.wavve.com' },
	{ name: 'Tubi', url: 'https://www.tubitv.com' },
	{ name: 'Twitter Analytics', url: 'https://analytics.twitter.com' },
	{ name: 'Twitch Dashboard', url: 'https://dashboard.twitch.tv/stream-manager' },
	{ name: 'YouTube Studio', url: 'https://studio.youtube.com' },
	{ name: 'Twitter', url: 'https://twitter.com' }
];

const outFiles = fs.readdirSync(outPath);
outFiles
	.forEach((filename) => {
		const StartDir = outPath;
		const exe = path.join(outPath, filename);
		if (filename == 'kiosk.out') {
			PAGE_URLS
				.forEach(({ name, url }) => {
					AddShortcut({ AppName: name, exe, StartDir, LaunchOptions: `PAGE_URL="${url}" %command%` });
				});
		}
	});
