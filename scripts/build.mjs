import { copyFile, mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const output = path.join(root, 'dist');
await mkdir(output, { recursive: true });
const assets = ['index.html', 'styles.css', 'app.js', 'domain.js', 'icons.js', 'favicon.svg', 'manifest.json'];
for (const name of assets) await copyFile(path.join(root, 'web', name), path.join(output, name));
await copyFile(path.join(root, 'cloudflare', '_headers'), path.join(output, '_headers'));
await copyFile(path.join(root, 'server', 'worker.mjs'), path.join(output, '_worker.js'));
await writeFile(path.join(output, '_routes.json'), JSON.stringify({ version: 1, include: ['/api/*'], exclude: [] }, null, 2));
await writeFile(path.join(output, '.assetsignore'), '_worker.js\n_routes.json\n');
let bytes = 0;
for (const name of assets) bytes += (await readFile(path.join(output, name))).length;
console.log(`AurumSentinel Web ready: dist/ (${assets.length} browser assets, ${(bytes / 1024).toFixed(1)} KiB) + live market API.`);
console.log('Run npm start or double-click Mo-AurumSentinel.cmd.');