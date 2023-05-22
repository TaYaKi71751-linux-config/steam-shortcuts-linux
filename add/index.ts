import fs from 'fs';
import path, { parse } from 'path';

const tsDirectory = path.join(
	`${process.env.PWD}`,
	'add'
);

const tsFiles = fs.readdirSync(tsDirectory);

tsFiles
	.filter((filename) => (filename.endsWith('.ts')))
	.forEach((filename) => {
		const tsFilePath = path.join(tsDirectory, parse(filename).name);
		require(tsFilePath);
	});
