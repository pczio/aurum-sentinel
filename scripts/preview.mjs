import { createServer } from 'node:http';
import { createReadStream } from 'node:fs';
import { access, stat } from 'node:fs/promises';
import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createMarketApi } from '../server/worker.mjs';

const root = fileURLToPath(new URL('../dist/', import.meta.url));
const host = '127.0.0.1';
let port = Number(process.env.AURUM_PORT || 8787);
if (!Number.isInteger(port) || port < 1024 || port > 65000) throw new Error('Invalid preview port');
let url = `http://${host}:${port}/`;
const firstPort = port;
const handleApi = createMarketApi();
const shouldOpen = process.argv.includes('--open');
const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.wasm': 'application/wasm',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

try {
  await Promise.all(['index.html', 'app.js'].map(name => access(path.join(root, name))));
} catch {
  console.error('Chua co ban build. Hay chay npm run build trong thu muc cloudflare_mvp.');
  process.exit(1);
}

function openBrowser() {
  if (!shouldOpen) return;
  const command = process.platform === 'win32' ? 'rundll32.exe' : process.platform === 'darwin' ? 'open' : 'xdg-open';
  const args = process.platform === 'win32' ? ['url.dll,FileProtocolHandler', url] : [url];
  const child = spawn(command, args, { windowsHide: true, stdio: 'ignore', detached: true });
  child.on('error', () => console.log(`Hay mo trinh duyet tai ${url}`));
  child.unref();
}

const server = createServer(async (request, response) => {
  if (!['GET', 'HEAD'].includes(request.method)) {
    response.writeHead(405, { Allow: 'GET, HEAD' }).end();
    return;
  }

  try {
    const pathname = decodeURIComponent(new URL(request.url, url).pathname);
    const apiResponse = await handleApi(new Request(new URL(request.url, url), { method: request.method }));
    if (apiResponse) {
      response.writeHead(apiResponse.status, Object.fromEntries(apiResponse.headers));
      response.end(Buffer.from(await apiResponse.arrayBuffer()));
      return;
    }
    if (pathname.startsWith('/_') || pathname.includes('/.')) {
      response.writeHead(404).end('Not found');
      return;
    }
    if (pathname.includes('\\') || pathname.includes('\0')) {
      response.writeHead(400).end('Invalid path');
      return;
    }
    let target = path.resolve(root, `.${pathname}`);
    const relative = path.relative(root, target);
    if (relative.startsWith('..') || path.isAbsolute(relative)) {
      response.writeHead(403).end('Forbidden');
      return;
    }
    try {
      if ((await stat(target)).isDirectory()) target = path.join(target, 'index.html');
      if (!(await stat(target)).isFile()) throw new Error('Not a file');
    } catch {
      if (!request.headers.accept?.includes('text/html')) {
        response.writeHead(404).end('Not found');
        return;
      }
      target = path.join(root, 'index.html');
    }

    response.writeHead(200, {
      'Content-Type': types[path.extname(target)] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
      'X-Content-Type-Options': 'nosniff',
      'X-AurumSentinel-Preview': '2',
    });
    if (request.method === 'HEAD') response.end();
    else createReadStream(target).on('error', () => response.destroy()).pipe(response);
  } catch {
    response.writeHead(400).end('Bad request');
  }
});

server.on('error', async error => {
  if (error.code === 'EADDRINUSE') {
    try {
      const response = await fetch(url, { signal: AbortSignal.timeout(3000) });
      if (response.headers.get('x-aurumsentinel-preview') === '2') {
        console.log(`AurumSentinel dang chay: ${url}`);
        openBrowser();
        return;
      }
    } catch {}
    if (port - firstPort < 10) {
      port++;
      url = `http://${host}:${port}/`;
      server.listen(port, host);
      return;
    }
    console.error('Chua tim duoc cong trong. Hay dong cua so chay app cu va thu lai.');
  } else console.error(error.message);
  process.exitCode = 1;
});

server.listen(port, host, () => {
  console.log(`AurumSentinel: ${url}`);
  console.log('Giu cua so nay mo khi dung app. Nhan Ctrl+C de dung.');
  openBrowser();
});
