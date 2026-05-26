import fs from 'fs';

const path = require('path');

const userdataPath = path.join(process.env.HOME, '.steam', 'steam', 'userdata');
const managedCategoryIds = new Set<string>();
const preservedCategoryIds = new Set(['favorite', 'hidden']);

function collectionId(cat: string): string {
	return `uc-${cat.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}`;
}

function normalizeCollectionKey(key: string): string {
	return key.replace(/^user-collections\./, '').toLowerCase();
}

function shouldKeepCategory(id: string): boolean {
	return managedCategoryIds.has(id) || preservedCategoryIds.has(id);
}

function cloudStoragePath(user_id: string): string {
	return path.join(userdataPath, user_id, 'config', 'cloudstorage');
}

function nextCloudStorageVersion(entries: [string, any][]): string {
	const versions = entries
		.map(([, entry]) => Number(entry?.version))
		.filter((version) => Number.isFinite(version));
	return `${versions.length ? Math.max(...versions) + 1 : Math.ceil(Date.now() / 1000)}`;
}

function cloudStorageCollectionEntry(id: string, name: string, appid: number, version: string): any {
	return {
		key: `user-collections.${id}`,
		timestamp: Math.ceil(Date.now() / 1000),
		value: JSON.stringify({
			id,
			name,
			added: [appid],
			removed: []
		}),
		version,
		conflictResolutionMethod: 'custom',
		strMethodId: 'union-collections'
	};
}

function cloudStorageCollectionValue(entry: any, id: string, name: string): any {
	if (!entry?.value) return { id, name, added: [], removed: [] };
	const value = typeof entry.value === 'string' ? JSON.parse(entry.value) : entry.value;
	return value ?? { id, name, added: [], removed: [] };
}

function writeCloudStorageEntries(filePath: string, entries: [string, any][]): void {
	fs.writeFileSync(filePath, JSON.stringify(entries));
}

function readCloudStorageEntries(filePath: string): [string, any][] {
	return fs.existsSync(filePath) && fs.readFileSync(filePath).length
		? JSON.parse(`${fs.readFileSync(filePath)}`)
		: [];
}

function findCloudStorageCollectionFile(storagePath: string, key: string): string {
	const files = fs.readdirSync(storagePath)
		.filter((filename) => filename.startsWith('cloud-storage-namespace-') && filename.endsWith('.json'))
		.sort();
	for (const filename of files) {
		const filePath = path.join(storagePath, filename);
		const entries = readCloudStorageEntries(filePath);
		if (entries.some(([entryKey]) => entryKey === key || entryKey.startsWith('user-collections.'))) {
			return filePath;
		}
	}
	return path.join(storagePath, files.find((filename) => filename === 'cloud-storage-namespace-1.json') ?? 'cloud-storage-namespace-1.json');
}

function addToCloudStorage(user_id: string, appid: number, cat: string): void {
	const storagePath = cloudStoragePath(user_id);
	if (!fs.existsSync(storagePath)) {
		fs.mkdirSync(storagePath, { recursive: true });
	}

	const id = collectionId(cat);
	const key = `user-collections.${id}`;
	const filePath = findCloudStorageCollectionFile(storagePath, key);
	const entries = readCloudStorageEntries(filePath);
	const version = nextCloudStorageVersion(entries);
	if (!entries.some(([entryKey]) => entryKey === 'collection-bootstrap-complete')) {
		entries.push(['collection-bootstrap-complete', {
			key: 'collection-bootstrap-complete',
			timestamp: Math.ceil(Date.now() / 1000),
			value: 'true',
			version
		}]);
	}

	const entryIndex = entries.findIndex(([entryKey]) => entryKey === key);
	if (entryIndex < 0) {
		entries.push([key, cloudStorageCollectionEntry(id, cat, appid, version)]);
	} else {
		const entry = entries[entryIndex][1] ?? {};
		const value = cloudStorageCollectionValue(entry, id, cat);
		value.id = value.id ?? id;
		value.name = value.name ?? cat;
		value.added = Array.isArray(value.added) ? value.added : [];
		value.removed = Array.isArray(value.removed) ? value.removed : [];
		if (!value.added.includes(appid)) {
			value.added.push(appid);
		}
		value.added = [...new Set(value.added)];
		value.removed = value.removed.filter((removedAppid: number) => removedAppid !== appid);
		entry.key = key;
		entry.timestamp = Math.ceil(Date.now() / 1000);
		entry.value = JSON.stringify(value);
		entry.version = version;
		entry.conflictResolutionMethod = entry.conflictResolutionMethod ?? 'custom';
		entry.strMethodId = entry.strMethodId ?? 'union-collections';
		delete entry.is_deleted;
		entries[entryIndex][1] = entry;
	}

	writeCloudStorageEntries(filePath, entries);
	const savedEntries = readCloudStorageEntries(filePath);
	const saved = savedEntries.some(([entryKey]) => entryKey === key);
	console.log(`Add Steam cloud category '${cat}' (${id}) to ${filePath}: ${saved ? 'saved' : 'missing after write'}`);
}

function ensureFavoriteInCloudStorage(user_id: string): void {
	const storagePath = cloudStoragePath(user_id);
	if (!fs.existsSync(storagePath)) {
		fs.mkdirSync(storagePath, { recursive: true });
	}

	const key = 'user-collections.favorite';
	const filePath = findCloudStorageCollectionFile(storagePath, key);
	const entries = readCloudStorageEntries(filePath);
	if (entries.some(([entryKey]) => entryKey === key)) return;

	const version = nextCloudStorageVersion(entries);
	entries.push([key, {
		key,
		timestamp: Math.ceil(Date.now() / 1000),
		value: JSON.stringify({
			id: 'favorite',
			name: '즐겨찾기',
			added: [],
			removed: []
		}),
		version,
		conflictResolutionMethod: 'custom',
		strMethodId: 'union-collections'
	}]);
	writeCloudStorageEntries(filePath, entries);
	console.log(`Initialize Steam favorite category in ${filePath}`);
}

function readCloudStorageCollections(filePath: string): Record<string, any> {
	const inBuffer = fs.readFileSync(filePath);
	if (!inBuffer.length) return {};

	const parsed = JSON.parse(`${inBuffer}`);
	const entries = Array.isArray(parsed) ? parsed : Object.entries(parsed);
	return Object.fromEntries(entries
		.filter(([key]: [string, any]) => key.startsWith('user-collections.'))
		.map(([key, collection]: [string, any]) => ([
			key,
			Object.assign({}, collection, {
				value: collection.value && typeof collection.value === 'string'
					? JSON.parse(collection.value)
					: collection.value
			})
		])));
}

function writeCloudStorageCollections(filePath: string, keepCollectionKeys: Set<string>): void {
	const parsed = JSON.parse(`${fs.readFileSync(filePath)}`);
	const entries = Array.isArray(parsed) ? parsed : Object.entries(parsed);
	const output = entries.filter(([key]: [string, any]) => (
		!key.startsWith('user-collections.') || keepCollectionKeys.has(key)
	));
	writeCloudStorageEntries(filePath, output as [string, any][]);
}

function pruneCloudStorage(user_id: string): void {
	const storagePath = cloudStoragePath(user_id);
	if (!fs.existsSync(storagePath)) return;

	for (const filename of fs.readdirSync(storagePath)) {
		if (!filename.startsWith('cloud-storage-namespace-') || !filename.endsWith('.json')) continue;

		const filePath = path.join(storagePath, filename);
		const collections = readCloudStorageCollections(filePath);
		const keepCollectionKeys = new Set<string>();
		let removedCount = 0;
		let keptCount = 0;

		for (const [key, collection] of Object.entries(collections)) {
			const id = normalizeCollectionKey(collection.value?.id ?? key);
			const name = collection.value?.name ?? id;
			if (shouldKeepCategory(id)) {
				keepCollectionKeys.add(key);
				keptCount++;
			} else {
				console.log(`Prune Steam cloud category '${name}' (${id}) from ${filePath}`);
				removedCount++;
			}
		}

		if (removedCount) {
			writeCloudStorageCollections(filePath, keepCollectionKeys);
		}
		console.log(`Prune Steam cloud categories in ${filePath}: kept ${keptCount}, removed ${removedCount}`);
	}
}

export async function AddToCats(appid: number, cat: string) {
	managedCategoryIds.add(collectionId(cat));
	const user_ids = fs.readdirSync(userdataPath);
	for (const user_id of user_ids) {
		ensureFavoriteInCloudStorage(user_id);
		addToCloudStorage(user_id, appid, cat);
	}
}

export async function PruneUnmanagedCats() {
	console.log(`Prune Steam categories: ${managedCategoryIds.size} managed categories`);
	if (!managedCategoryIds.size) {
		console.warn('Skip pruning Steam categories: no managed categories were registered in this run.');
		return;
	}

	const user_ids = fs.readdirSync(userdataPath);
	for (const user_id of user_ids) {
		pruneCloudStorage(user_id);
	}
}
