const URLS = {
  gold: 'https://api.gold-api.com/price/XAU',
  silver: 'https://api.gold-api.com/price/XAG',
  domestic: 'https://www.vang.today/api/prices',
  fx: 'https://portal.vietcombank.com.vn/Usercontrols/TVPortal.TyGia/pXML.aspx?b=10',
  fxBackup: 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json',
};

const PRODUCTS = {
  SJL1L10: ['SJC', 'Vàng miếng SJC 9999', 'bar'],
  SJ9999: ['SJC', 'Nhẫn SJC 9999', 'ring'],
  DOHNL: ['DOJI', 'DOJI Hà Nội', 'bar'],
  DOHCML: ['DOJI', 'DOJI TP. Hồ Chí Minh', 'bar'],
  BT9999NTT: ['Bảo Tín', 'Bảo Tín 9999', 'ring'],
  PQHNVM: ['PNJ', 'PNJ Hà Nội', 'bar'],
  PQHN24NTT: ['PNJ', 'PNJ 24K', 'ring'],
  BTSJC: ['Bảo Tín', 'Bảo Tín SJC', 'bar'],
  VNGSJC: ['VN Gold', 'VN Gold SJC', 'bar'],
  VIETTINMSJC: ['Viettin', 'Viettin SJC', 'bar'],
};

function positive(value) {
  const number = Number(value);
  if (!Number.isFinite(number) || number <= 0) throw new Error('Invalid price');
  return number;
}

function iso(value) {
  const date = new Date(value);
  if (!Number.isFinite(date.getTime())) throw new Error('Invalid timestamp');
  return date.toISOString();
}

export function parseMetal(data, symbol) {
  if (data.symbol !== symbol) throw new Error('Unexpected metal');
  return { symbol, price: positive(data.price), currency: 'USD', unit: 'troy-oz', updatedAt: iso(data.updatedAt) };
}

export function parseDomestic(data) {
  if (data.success !== true || !data.prices || !Number.isFinite(Number(data.timestamp))) throw new Error('Invalid domestic response');
  const quotes = [];
  for (const [code, [brand, name, type]] of Object.entries(PRODUCTS)) {
    const row = data.prices[code];
    if (!row || row.currency !== 'VND') continue;
    try {
      const buy = positive(row.buy);
      const sell = positive(row.sell);
      if (buy > sell) continue;
      quotes.push({ code, brand, name, type, buy, sell, unit: 'VND/luong', change: Number.isFinite(Number(row.change_sell)) ? Number(row.change_sell) : null });
    } catch {}
  }
  if (!quotes.length) throw new Error('No usable domestic prices');
  return { quotes, updatedAt: iso(Number(data.timestamp) * 1000), source: 'vang.today', sourceUrl: 'https://www.vang.today/vi/api', cadence: 'Khoảng 5 phút', precision: 'snapshot' };
}

export function parseVcb(xml) {
  const tag = xml.match(/<Exrate\b[^>]*\bCurrencyCode="USD"[^>]*\/?>/i)?.[0];
  const time = xml.match(/<DateTime>([^<]+)<\/DateTime>/i)?.[1]?.trim();
  const parts = time?.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4}) (\d{1,2}):(\d{2}):(\d{2})\s*(AM|PM)$/i);
  if (!tag || !parts) throw new Error('Invalid Vietcombank XML');
  let hour = Number(parts[4]) % 12 + (parts[7].toUpperCase() === 'PM' ? 12 : 0);
  const stamp = `${parts[3]}-${parts[1].padStart(2, '0')}-${parts[2].padStart(2, '0')}T${String(hour).padStart(2, '0')}:${parts[5]}:${parts[6]}+07:00`;
  const rate = attribute => positive(tag.match(new RegExp(`\\b${attribute}="([^"]+)"`, 'i'))?.[1]?.replaceAll(',', ''));
  return { buy: rate('Buy'), transfer: rate('Transfer'), sell: rate('Sell'), updatedAt: iso(stamp), source: 'Vietcombank', sourceUrl: 'https://www.vietcombank.com.vn/vi-VN/KHCN/Cong-cu-tien-ich/Ty-gia', cadence: 'Lấy dữ liệu tối đa mỗi 5 phút', rateType: 'bank-sell' };
}

export function parseHistory(data, symbol, days) {
  if (!data.success || !Array.isArray(data.history)) throw new Error('Invalid history response');
  const points = data.history.flatMap(row => {
    const quote = row.prices?.[symbol];
    const price = Number(symbol === 'XAUUSD' ? quote?.buy : quote?.sell);
    if (!/^\d{4}-\d{2}-\d{2}$/.test(row.date) || !Number.isFinite(price) || price <= 0) return [];
    return [{ date: row.date, price }];
  }).sort((a, b) => a.date.localeCompare(b.date));
  if (!points.length) throw new Error('No historical observations');
  return { symbol, days, points: [...new Map(points.map(point => [point.date, point])).values()], source: 'vang.today', sourceUrl: 'https://www.vang.today/vi/api', granularity: 'daily', unit: symbol === 'XAUUSD' ? 'USD/oz' : 'VND/luong' };
}

export function createMarketApi({ fetcher = globalThis.fetch, now = Date.now } = {}) {
  const memory = new Map();
  const inflight = new Map();

  async function read(url, ttl, format = 'json') {
    const response = await fetcher(url, { headers: { Accept: format === 'json' ? 'application/json' : 'application/xml,text/xml,*/*' }, signal: AbortSignal.timeout(10000), cf: { cacheTtl: ttl, cacheEverything: true } });
    if (!response.ok) throw new Error(`Upstream ${response.status}`);
    const text = await response.text();
    if (text.length > 1500000) throw new Error('Response too large');
    return format === 'json' ? JSON.parse(text) : text;
  }

  async function resource(key, ttl, loader, sourceName) {
    const cached = memory.get(key);
    if (cached && now() - cached.savedAt < ttl * 1000) return cached.value;
    if (inflight.has(key)) return inflight.get(key);
    const pending = (async () => {
      try {
        const data = await loader();
        const value = { ...data, status: 'ok', fetchedAt: new Date(now()).toISOString() };
        memory.set(key, { savedAt: now(), value });
        return value;
      } catch {
        if (cached && now() - cached.savedAt < 86400000) return { ...cached.value, status: 'stale', error: 'Nguồn tạm thời chưa phản hồi. Đây là bản lưu trước đó.' };
        return { status: 'unavailable', source: sourceName, error: 'Chưa lấy được dữ liệu từ nguồn. Sẽ tự thử lại.' };
      } finally { inflight.delete(key); }
    })();
    inflight.set(key, pending);
    return pending;
  }

  const metal = (key, symbol) => resource(key, 30, async () => ({ ...parseMetal(await read(URLS[key], 30), symbol), source: 'Gold API', sourceUrl: 'https://gold-api.com', cadence: 'Khoảng 30 giây' }), 'Gold API');
  const domestic = () => resource('domestic', 300, async () => parseDomestic(await read(URLS.domestic, 300)), 'vang.today');
  const fx = () => resource('fx', 300, async () => {
    try { return parseVcb(await read(URLS.fx, 300, 'text')); }
    catch {
      const backup = await resource('fxBackup', 21600, async () => {
        const data = await read(URLS.fxBackup, 21600);
        if (!/^\d{4}-\d{2}-\d{2}$/.test(data.date)) throw new Error('Invalid FX date');
        return { buy: null, transfer: null, sell: positive(data.usd?.vnd), updatedAt: iso(`${data.date}T00:00:00Z`), source: 'Currency API', sourceUrl: 'https://github.com/fawazahmed0/exchange-api', cadence: 'Nguồn dự phòng theo ngày', rateType: 'daily-reference', precision: 'day' };
      }, 'Currency API');
      if (backup.status !== 'ok') throw new Error('No FX');
      return backup;
    }
  }, 'Vietcombank');

  function json(body, status = 200) {
    return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' } });
  }

  return async function handleApi(request) {
    const url = new URL(request.url);
    if (!url.pathname.startsWith('/api/')) return null;
    if (request.method !== 'GET') return json({ error: 'Method not allowed' }, 405);
    if (url.pathname === '/api/health') return json({ app: 'AurumSentinel', version: 2, ok: true });
    if (url.pathname === '/api/market') {
      const [gold, silver, vietnam, currency] = await Promise.all([metal('gold', 'XAU'), metal('silver', 'XAG'), domestic(), fx()]);
      return json({ servedAt: new Date(now()).toISOString(), refreshSeconds: 30, gold, silver, domestic: vietnam, fx: currency });
    }
    if (url.pathname === '/api/history') {
      const symbol = url.searchParams.get('symbol') || 'XAUUSD';
      const days = Number(url.searchParams.get('days') || 30);
      if (!['XAUUSD', 'SJL1L10', 'SJ9999'].includes(symbol) || ![7, 14, 30].includes(days)) return json({ error: 'Chỉ hỗ trợ XAUUSD, SJL1L10, SJ9999 và 7, 14, 30 ngày.' }, 400);
      const result = await resource(`history:${symbol}:${days}`, 300, async () => parseHistory(await read(`${URLS.domestic}?type=${symbol}&days=${days}`, 300), symbol, days), 'vang.today');
      return json(result, result.status === 'unavailable' ? 503 : 200);
    }
    return json({ error: 'Not found' }, 404);
  };
}

const handleApi = createMarketApi();
export default {
  async fetch(request, env) {
    return await handleApi(request) || env.ASSETS.fetch(request);
  },
};
