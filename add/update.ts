import path from 'path';
import fs from 'fs';
import { AddShortcut } from '../util/Shortcut';
import { execSync } from 'child_process';

const StartDir:string = `${process.cwd()}`;

[{ AppName: '[steam-shortcuts][Git] Pull TaYaKi71751/steam-shortcuts', exe: `${execSync('which git').toString().split('\n')[0]}`, StartDir, LaunchOptions: '%command% pull' },
	{ AppName: '[steam-shortcuts][Bash] build bins', exe: `${execSync('which bash').toString().split('\n')[0]}`, StartDir, LaunchOptions: `${execSync('which env').toString().split('\n')[0]} && %command% ./build.sh` },
	{ AppName: '[steam-shortcuts][pnpm] Add Steam Shortcuts', exe: `${execSync('which pnpm').toString().split('\n')[0]}`, StartDir, LaunchOptions: `${execSync('which env').toString().split('\n')[0]} && ${execSync('which pnpm').toString().split('\n')[0]} i && ${execSync('which pnpm').toString().split('\n')[0]} add:steam` }]
	.forEach((opts) => {
		AddShortcut(opts);
	});
