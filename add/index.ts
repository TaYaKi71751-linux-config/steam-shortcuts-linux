import fs from 'fs';
import path, { basename, parse } from 'path';
import { TrimShortcuts } from '../util/Shortcut';

const tsDirectory = path.join(
	`${process.env.PWD}`,
	'add'
);
let tsFiles = fs.readdirSync(tsDirectory);

tsFiles = tsFiles
	.filter((filename) => (filename.endsWith('.ts')))
	.filter((filename) => (!basename(filename).startsWith('index')));
(async () => {
	for (let i = 0; i < tsFiles?.length; i++) {
		const filename = tsFiles[i];
		const tsFilePath = path.join(tsDirectory, parse(filename).name);
		const { __main__ } = require(tsFilePath);
		await __main__();
	}
	TrimShortcuts();
})();
