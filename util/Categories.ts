import fs from 'fs';
import * as VDF from 'vdf-parser';

const path = require('path');
const steamCategoriesModulePath = path.dirname(require.resolve('steam-categories'));
const levelup = require(require.resolve('levelup', { paths: [steamCategoriesModulePath] }));
const leveldown = require(require.resolve('leveldown', { paths: [steamCategoriesModulePath] }));
const encode = require(require.resolve('encoding-down', { paths: [steamCategoriesModulePath] }));
const iconv = require(require.resolve('iconv-lite', { paths: [steamCategoriesModulePath] }));

const levelDBPaths = [
	path.join(process.env.HOME, '.steam', 'steam', 'config', 'htmlcache', 'Default', 'Local Storage', 'leveldb'),
];

const userdataPath = path.join(process.env.HOME, '.steam', 'steam', 'userdata');
// Supply leveldb path and Steam3 ID of user whose collections to edit
const managedCategoryIds = new Set<string>();
const preservedCategoryIds = new Set(['favorite', 'hidden']);

function isInitializableCollectionError(error: unknown): boolean {
	const message = error instanceof Error ? error.message : `${error}`;
	return (
		(error instanceof Error && error.name === 'NotFoundError') ||
		message.includes('Key not found in database') ||
		message.includes('LOCK: No such file or directory') ||
		message.includes('No Steam collection namespaces found') ||
		message.includes('NotFound')
	);
}

function collectionId(cat: string): string {
	return `uc-${cat.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}`;
}

function addIndexedValue(values: Record<string, string>, value: string): Record<string, string> {
	const output = Object.assign({}, values);
	if (Object.values(output).includes(value)) return output;
	output[`${Object.keys(output).length}`] = value;
	return output;
}

function keyPrefix(user_id: string): string {
	return `_https://steamloopback.host\u0000\u0001U${user_id}-cloud-storage-namespace`;
}

function serializeCollections(collections: Record<string, any>): string {
	const output = Object.fromEntries(Object.entries(collections).map(([key, collection]) => ([
		key,
		Object.assign({}, collection, {
			value: typeof collection.value === 'string' ? collection.value : JSON.stringify(collection.value)
		})
	])));
	return `00${iconv.encode(JSON.stringify(output), 'utf16le').toString('hex')}`;
}

function unserializeCollections(input: string): Record<string, any> {
	const transformed = input.substr(0, 2) === '01'
		? input.slice(2).match(/.{1,2}/g)?.join('00').concat('00') ?? ''
		: input.slice(2);
	const decoded = iconv.decode(Buffer.from(transformed, 'hex'), 'utf16le');
	const parsed = JSON.parse(decoded);
	const entries = Array.isArray(parsed) ? parsed : Object.entries(parsed);
	return Object.fromEntries(entries.map(([key, collection]: [string, any]) => ([
		key,
		Object.assign({}, collection, {
			value: typeof collection.value === 'string' ? JSON.parse(collection.value) : collection.value
		})
	])));
}

function putLevelValue(db: any, key: string, value: string, opts?: Record<string, string>): Promise<void> {
	return new Promise((resolve, reject) => {
		db.put(key, value, opts ?? {}, (error: Error | undefined) => {
			if (error) reject(error);
			else resolve();
		});
	});
}

function getLevelValue(db: any, key: string, opts?: Record<string, string>): Promise<string> {
	return new Promise((resolve, reject) => {
		db.get(key, opts ?? {}, (error: Error | undefined, value: string) => {
			if (error) reject(error);
			else resolve(value);
		});
	});
}

function closeLevelDB(db: any): Promise<void> {
	return new Promise((resolve, reject) => {
		if (!db || db.isClosed()) {
			resolve();
			return;
		}
		db.close((error: Error | undefined) => {
			if (error) reject(error);
			else resolve();
		});
	});
}

function removeLevelDBLock(levelDBPath: string): void {
	const lockPath = path.join(levelDBPath, 'LOCK');
	if (fs.existsSync(lockPath)) {
		fs.unlinkSync(lockPath);
	}
}

async function initializeCollections(levelDBPath: string, user_id: string): Promise<void> {
	fs.mkdirSync(levelDBPath, { recursive: true });
	removeLevelDBLock(levelDBPath);

	const db = levelup(encode(leveldown(levelDBPath), { valueEncoding: 'hex' }));
	const prefix = keyPrefix(user_id);
	try {
		await putLevelValue(db, `${prefix}s`, '\u0000[["0"]]', { valueEncoding: 'utf-8' });
		await putLevelValue(db, `${prefix}-0`, serializeCollections({}));
	} finally {
		await closeLevelDB(db);
	}
}

function collectionEntry(id: string, name: string, appid: number): any {
	return {
		key: `user-collections.${id}`,
		timestamp: Math.ceil(Date.now() / 1000),
		value: {
			id,
			name,
			added: [appid]
		},
		conflictResolutionMethod: 'custom',
		strMethodId: 'union-collections'
	};
}

function normalizeCollectionKey(key: string): string {
	return key.replace(/^user-collections\./, '').toLowerCase();
}

function shouldKeepCategory(id: string): boolean {
	return managedCategoryIds.has(id) || preservedCategoryIds.has(id);
}

function localConfigPath(user_id: string): string {
	return path.join(userdataPath, user_id, 'config', 'localconfig.vdf');
}

function cloudStoragePath(user_id: string): string {
	return path.join(userdataPath, user_id, 'config', 'cloudstorage');
}

function ensureSteamLocalConfig(config: any): any {
	config.UserLocalConfigStore = Object.assign({}, config.UserLocalConfigStore);
	config.UserLocalConfigStore.Software = Object.assign({}, config.UserLocalConfigStore.Software);
	config.UserLocalConfigStore.Software.Valve = Object.assign({}, config.UserLocalConfigStore.Software.Valve);
	config.UserLocalConfigStore.Software.Valve.Steam = Object.assign({}, config.UserLocalConfigStore.Software.Valve.Steam);
	return config;
}

function readLocalConfig(user_id: string): any {
	const configPath = localConfigPath(user_id);
	if (!fs.existsSync(configPath)) {
		return ensureSteamLocalConfig({});
	}

	const inBuffer = fs.readFileSync(configPath);
	if (!inBuffer.length) {
		return ensureSteamLocalConfig({});
	}
	return ensureSteamLocalConfig(VDF.parse(`${inBuffer}`, { types: false, arrayify: false }));
}

function readLocalCollections(config: any): Record<string, any> {
	const rawCollections = config.UserLocalConfigStore.Software.Valve.Steam['user-collections'];
	if (!rawCollections) return {};
	const parsed = typeof rawCollections === 'string'
		? JSON.parse(rawCollections.replace(/\\"/g, '"'))
		: rawCollections;
	const entries = Array.isArray(parsed) ? parsed : Object.entries(parsed);
	return Object.fromEntries(entries.map(([key, collection]: [string, any]) => {
		const id = normalizeCollectionKey(key);
		const value = collection.value
			? (typeof collection.value === 'string' ? JSON.parse(collection.value) : collection.value)
			: collection;
		return [
			id,
			{
				name: value.name ?? collection.name ?? id,
				id: value.id ?? collection.id ?? id,
				added: [...new Set(value.added ?? collection.added ?? [])],
				removed: [...new Set(value.removed ?? collection.removed ?? [])]
			}
		];
	}));
}

function writeLocalCollections(config: any, collections: Record<string, any>): any {
	const output = Object.fromEntries(Object.entries(collections).map(([key, collection]) => ([
		normalizeCollectionKey(key),
		{
			name: collection.name ?? normalizeCollectionKey(key),
			id: collection.id ?? normalizeCollectionKey(key),
			added: [...new Set(collection.added ?? [])],
			removed: [...new Set(collection.removed ?? [])]
		}
	])));
	config.UserLocalConfigStore.Software.Valve.Steam['user-collections'] = JSON.stringify(output).replace(/"/g, '\\"');
	return config;
}

function writeLocalConfig(user_id: string, config: any): void {
	const configPath = localConfigPath(user_id);
	if (!fs.existsSync(path.dirname(configPath))) {
		fs.mkdirSync(path.dirname(configPath), { recursive: true });
	}
	fs.writeFileSync(configPath, VDF.stringify(config, { pretty: true, indent: '\t' }));
}

async function addToCatsForUser(levelDBPath: string, user_id: string, appid: number, cat: string): Promise<void> {
	if (!fs.existsSync(levelDBPath)) {
		throw new Error(`LOCK: No such file or directory ${levelDBPath}`);
	}
	removeLevelDBLock(levelDBPath);
	let db: any;
	const prefix = keyPrefix(user_id);
	try {
		db = levelup(encode(leveldown(levelDBPath), { valueEncoding: 'hex' }));
		const namespacesValue = await getLevelValue(db, `${prefix}s`, { valueEncoding: 'utf-8' });
		const namespaceIds = JSON.parse(namespacesValue.slice(1)).map(([id]: [string]) => id);
		const namespaceId = namespaceIds.slice(-1)[0];
		if (!namespaceId) throw new Error('No Steam collection namespaces found');

		const id = collectionId(cat);
		const collectionKey = `user-collections.${id}`;
		const collectionsKey = `${prefix}-${namespaceId}`;
		const collections = unserializeCollections(await getLevelValue(db, collectionsKey));
		const collection = collections[collectionKey];
		if (!collection) {
			collections[collectionKey] = collectionEntry(id, cat, appid);
		} else {
			collection.value = collection.value ?? { id, name: cat, added: [] };
			collection.value.id = collection.value.id ?? id;
			collection.value.name = collection.value.name ?? cat;
			collection.value.added = collection.value.added ?? [];
			if (Array.isArray(collection.value.appids)) {
				collection.value.added.push(...collection.value.appids);
				delete collection.value.appids;
			}
			if (!collection.value.added.includes(appid)) {
				collection.value.added.push(appid);
			}
			collection.value.added = [...new Set(collection.value.added)];
		}
		await putLevelValue(db, collectionsKey, serializeCollections(collections));
	} finally {
		await closeLevelDB(db);
	}
}

function addToLocalConfig(user_id: string, appid: number, cat: string): void {
	const config = readLocalConfig(user_id);
	const collections = readLocalCollections(config);
	const id = collectionId(cat);
	const collection = collections[id];

	if (!collection) {
		collections[id] = {
			name: cat,
			id,
			added: [appid],
			removed: []
		};
	} else {
		collection.id = collection.id ?? id;
		collection.name = collection.name ?? cat;
		collection.added = collection.added ?? [];
		collection.removed = collection.removed ?? [];
		if (!collection.added.includes(appid)) {
			collection.added.push(appid);
		}
		collection.added = [...new Set(collection.added)];
		collection.removed = collection.removed.filter((removedAppid: number) => removedAppid !== appid);
	}

	writeLocalCollections(config, collections);
	writeLocalConfig(user_id, config);
}

function ensureFavoriteInLocalConfig(user_id: string): void {
	const config = readLocalConfig(user_id);
	const collections = readLocalCollections(config);
	if (!collections.favorite) {
		collections.favorite = {
			name: 'Favorite',
			id: 'favorite',
			added: [],
			removed: []
		};
		writeLocalCollections(config, collections);
		writeLocalConfig(user_id, config);
	}
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
		const entry = entries[entryIndex][1];
		const value = entry.value && typeof entry.value === 'string' ? JSON.parse(entry.value) : entry.value;
		value.id = value.id ?? id;
		value.name = value.name ?? cat;
		value.added = value.added ?? [];
		value.removed = value.removed ?? [];
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

async function pruneCatsForUser(levelDBPath: string, user_id: string): Promise<void> {
	if (!fs.existsSync(levelDBPath)) return;
	removeLevelDBLock(levelDBPath);

	let db: any;
	const prefix = keyPrefix(user_id);
	let keptCount = 0;
	let removedCount = 0;
	try {
		db = levelup(encode(leveldown(levelDBPath), { valueEncoding: 'hex' }));
		const namespacesValue = await getLevelValue(db, `${prefix}s`, { valueEncoding: 'utf-8' });
		const namespaceIds = JSON.parse(namespacesValue.slice(1)).map(([id]: [string]) => id);
		for (const namespaceId of namespaceIds) {
			const collectionsKey = `${prefix}-${namespaceId}`;
			const collections = unserializeCollections(await getLevelValue(db, collectionsKey));
			let changed = false;
			for (const key of Object.keys(collections)) {
				const id = normalizeCollectionKey(key);
				if (!shouldKeepCategory(id)) {
					delete collections[key];
					changed = true;
					removedCount++;
					console.log(`Prune Steam category '${id}' from ${levelDBPath}`);
				} else {
					keptCount++;
				}
			}
			if (changed) {
				await putLevelValue(db, collectionsKey, serializeCollections(collections));
			}
		}
	} catch (error) {
		if (!isInitializableCollectionError(error)) {
			throw error;
		}
	} finally {
		await closeLevelDB(db);
	}
	console.log(`Prune Steam categories in ${levelDBPath}: kept ${keptCount}, removed ${removedCount}`);
}

function pruneLocalConfig(user_id: string): void {
	const configPath = localConfigPath(user_id);
	if (!fs.existsSync(configPath)) return;

	const config = readLocalConfig(user_id);
	const collections = readLocalCollections(config);
	const keptCollections: Record<string, any> = {};
	let removedCount = 0;
	for (const key of Object.keys(collections)) {
		const id = normalizeCollectionKey(key);
		if (shouldKeepCategory(id)) {
			keptCollections[id] = collections[key];
		} else {
			console.log(`Prune Steam category '${id}' from ${configPath}`);
			removedCount++;
		}
	}
	writeLocalCollections(config, keptCollections);
	writeLocalConfig(user_id, config);
	console.log(`Prune Steam categories in ${configPath}: kept ${Object.keys(keptCollections).length}, removed ${removedCount}`);
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

function addToSharedConfig(user_id: string, appid: number, cat: string): void {
	const sharedConfigPath = path.join(userdataPath, user_id, '7', 'remote', 'sharedconfig.vdf');
	const sharedConfigDir = path.dirname(sharedConfigPath);
	if (!fs.existsSync(sharedConfigDir)) {
		fs.mkdirSync(sharedConfigDir, { recursive: true });
	}

	let config: any = { UserRoamingConfigStore: {} };
	if (fs.existsSync(sharedConfigPath)) {
		const inBuffer = fs.readFileSync(sharedConfigPath);
		if (inBuffer.length) {
			config = VDF.parse(`${inBuffer}`, { types: false, arrayify: false });
		}
	}

	config.UserRoamingConfigStore = Object.assign({}, config.UserRoamingConfigStore);
	config.UserRoamingConfigStore.Software = Object.assign({}, config.UserRoamingConfigStore.Software);
	config.UserRoamingConfigStore.Software.Valve = Object.assign({}, config.UserRoamingConfigStore.Software.Valve);
	config.UserRoamingConfigStore.Software.Valve.Steam = Object.assign({}, config.UserRoamingConfigStore.Software.Valve.Steam);
	config.UserRoamingConfigStore.Software.Valve.Steam.Apps = Object.assign({}, config.UserRoamingConfigStore.Software.Valve.Steam.Apps);
	config.UserRoamingConfigStore.Software.Valve.Steam.Apps[`${appid}`] = Object.assign({}, config.UserRoamingConfigStore.Software.Valve.Steam.Apps[`${appid}`]);
	config.UserRoamingConfigStore.Software.Valve.Steam.Apps[`${appid}`].tags = addIndexedValue(
		Object.assign({}, config.UserRoamingConfigStore.Software.Valve.Steam.Apps[`${appid}`].tags),
		cat
	);

	fs.writeFileSync(sharedConfigPath, VDF.stringify(config, { pretty: true, indent: '\t' }));
}

function pruneSharedConfig(user_id: string): void {
	const sharedConfigPath = path.join(userdataPath, user_id, '7', 'remote', 'sharedconfig.vdf');
	if (!fs.existsSync(sharedConfigPath)) return;

	const inBuffer = fs.readFileSync(sharedConfigPath);
	if (!inBuffer.length) return;

	const config: any = VDF.parse(`${inBuffer}`, { types: false, arrayify: false });
	const apps = config.UserRoamingConfigStore?.Software?.Valve?.Steam?.Apps;
	if (!apps) return;

	let keptCount = 0;
	let removedCount = 0;
	for (const app of Object.values(apps) as any[]) {
		if (!app?.tags) continue;
		const keptTags = Object.values(app.tags).filter((tag) => (
			typeof tag === 'string' && managedCategoryIds.has(normalizeCollectionKey(collectionId(tag)))
		));
		removedCount += Object.keys(app.tags).length - keptTags.length;
		keptCount += keptTags.length;
		if (keptTags.length) {
			app.tags = Object.fromEntries(keptTags.map((tag, index) => ([`${index}`, tag])));
		} else {
			delete app.tags;
		}
	}

	fs.writeFileSync(sharedConfigPath, VDF.stringify(config, { pretty: true, indent: '\t' }));
	console.log(`Prune Steam tags in ${sharedConfigPath}: kept ${keptCount}, removed ${removedCount}`);
}

export async function AddToCats(appid: number, cat: string) {
	managedCategoryIds.add(collectionId(cat));
	const user_ids = fs.readdirSync(userdataPath);
	for (const user_id of user_ids) {
		ensureFavoriteInLocalConfig(user_id);
		ensureFavoriteInCloudStorage(user_id);
		addToLocalConfig(user_id, appid, cat);
		addToCloudStorage(user_id, appid, cat);
		addToSharedConfig(user_id, appid, cat);
		for (const levelDBPath of levelDBPaths) {
			try {
				await addToCatsForUser(levelDBPath, user_id, appid, cat);
			} catch (error) {
				if (isInitializableCollectionError(error)) {
					console.warn(`Initialize Steam categories for user ${user_id} at ${levelDBPath}: Steam cloud collection metadata was not found.`);
					await initializeCollections(levelDBPath, user_id);
					await addToCatsForUser(levelDBPath, user_id, appid, cat);
				} else {
					console.error(`Failed to add appid ${appid} to category "${cat}" for user ${user_id} at ${levelDBPath}:`, error);
					throw error;
				}
			}
		}
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
		pruneLocalConfig(user_id);
		pruneCloudStorage(user_id);
		pruneSharedConfig(user_id);
		for (const levelDBPath of levelDBPaths) {
			await pruneCatsForUser(levelDBPath, user_id);
		}
	}
}
