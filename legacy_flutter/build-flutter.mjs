import { spawnSync } from 'node:child_process';
import { copyFile, readdir, readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const args = ['build', 'web', '--release', '--no-web-resources-cdn', '--base-href', '/'];
const windows = process.platform === 'win32';
const result = spawnSync(
  windows ? (process.env.ComSpec || 'cmd.exe') : 'flutter',
  windows ? ['/d', '/s', '/c', `flutter ${args.join(' ')}`] : args,
  { cwd: root, stdio: 'inherit' },
);
if (result.error || result.status !== 0) {
  console.error(result.error?.message || 'Flutter web build failed. Install Flutter 3.44.7 or compatible and add it to PATH.');
  process.exit(result.status || 1);
}

const output = path.join(root, 'build', 'web');
await copyFile(path.join(root, 'cloudflare', '_headers'), path.join(output, '_headers'));
for (const required of ['index.html', 'flutter_bootstrap.js', 'main.dart.js', 'manifest.json']) {
  await stat(path.join(output, required));
}
const html = await readFile(path.join(output, 'index.html'), 'utf8');
if (html.includes('$FLUTTER_BASE_HREF')) throw new Error('Flutter base URL was not resolved.');

let fileCount = 0;
let totalBytes = 0;
async function checkFiles(directory) {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const target = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      await checkFiles(target);
    } else {
      const { size } = await stat(target);
      if (size > 25 * 1024 * 1024) throw new Error(`Cloudflare asset exceeds 25 MiB: ${target}`);
      fileCount++;
      totalBytes += size;
    }
  }
}
await checkFiles(output);
if (fileCount > 1000) throw new Error('Build exceeds the 1,000-file Pages dashboard upload limit; use Wrangler.');
console.log(`Cloudflare bundle ready: build/web (${fileCount} files, ${(totalBytes / 1024 / 1024).toFixed(1)} MiB).`);
