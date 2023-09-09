import fs from 'fs';
import path, { basename, parse } from 'path';
import { TrimShortcuts } from '../util/Shortcut';

const tsDirectory = path.join(
	`${process.env.PWD}`,
	'add'
);
const tsFiles = fs.readdirSync(tsDirectory);

tsFiles
	.filter((filename) => (filename.endsWith('.ts')))
	.filter((filename) => (!basename(filename).startsWith('index')))
	.forEach((filename) => {
		const tsFilePath = path.join(tsDirectory, parse(filename).name);
		require(tsFilePath);
	});

TrimShortcuts();
