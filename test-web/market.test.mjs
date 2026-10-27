import test from 'node:test';
import assert from 'node:assert/strict';
import { createMarketApi, parseDomestic, parseMetal, parseVcb, parseHistory } from '../server/worker.mjs';
import { premium, projection, vaultTotals, alertValue, parseVaultBackup } from '../web/domain.js';

const stamp = '2026-10-27T08:00:00.000Z';
const domestic = { success: true, timestamp: Date.parse(stamp) / 1000, prices: { SJL1L10: { buy: 139000000, sell: 142000000, currency: 'VND', change_sell: 300000 }, SJ9999: { buy: 135000000, sell: 139000000, currency: 'VND', change_sell: 0 } } };
const xml = '<ExrateList><DateTime>10/27/2026 3:00:00 PM</DateTime><Exrate CurrencyCode="USD" Buy="25,610.00" Transfer="25,640.00" Sell="26,020.00" /></ExrateList>';
const request = path => new Request('https://aurum.example' + path);

test('quy đổi troy ounce sang lượng và tính premium đúng chiều', () => {
  const result = premium(4000, 26000, 140e6);
  assert.ok(Math.abs(result.world - 4000 * 26000 / 31.1034768 * 37.5) < .001);
  assert.equal(result.amount, 140e6 - result.world);
  assert.equal(premium(0, 26000, 140e6), null);
});
test('DCA không tăng giá vẫn tính chi phí mua–bán và mua cuối tháng', () => {
  const result = projection({ income: 15e6, percent: 20, years: 1, growth: 0, sellPerChi: 10e6, buyPerChi: 9e6 });
  assert.equal(result.invested, 36e6);
  assert.ok(Math.abs(result.quantity - 3.6) < 1e-10);
  assert.ok(Math.abs(result.value - 32.4e6) < .01);
  assert.equal(result.monthlyQuantity, .3);
});
test('mô phỏng tăng trưởng âm không tạo NaN và không hứa lợi nhuận', () => {
  const result = projection({ income: 15e6, percent: 20, years: 5, growth: -20, sellPerChi: 10e6, buyPerChi: 9e6 });
  assert.ok(Number.isFinite(result.value)); assert.ok(result.value < result.invested);
  assert.equal(projection({ income: 1, percent: 20, years: 1, growth: -100, sellPerChi: 10, buyPerChi: 9 }), null);
});
test('két vàng định giá theo mua vào, phần chưa có nguồn không thành lãi giả', () => {
  const result = vaultTotals([{ quantity: 2, price: 9e6, product: 'SJC' }, { quantity: 1, price: 8e6, product: 'unknown' }], [{ code: 'SJC', buy: 100e6, sell: 105e6 }]);
  assert.equal(result.market, 20e6); assert.equal(result.invested, 26e6); assert.equal(result.profit, 2e6); assert.equal(result.complete, false);
});
test('parser giữ nguyên đồng/lượng, bỏ giá đảo chiều, không nhận giá mô phỏng', () => {
  const data = parseDomestic(domestic);
  assert.equal(data.quotes[1].sell, 139e6); assert.equal(data.updatedAt, stamp);
  assert.throws(() => parseDomestic({ success: true, timestamp: 0, prices: { SJL1L10: { buy: 20, sell: 10, currency: 'VND' } } }));
  assert.throws(() => parseMetal({ symbol: 'XAG', price: 10, updatedAt: stamp }, 'XAU'));
});
test('Vietcombank XML dùng đúng AM/PM, dấu ngăn cách và múi giờ Việt Nam', () => {
  const fx = parseVcb(xml);
  assert.equal(fx.sell, 26020); assert.equal(fx.transfer, 25640); assert.equal(fx.updatedAt, stamp);
  assert.equal(parseVcb(xml.replace('3:00:00 PM', '12:00:00 AM')).updatedAt, '2026-10-26T17:00:00.000Z');
  assert.throws(() => parseVcb('<html>not XML</html>'));
});
test('lịch sử chỉ dùng quan sát thực có giá, sắp xếp ngày và không tự bù điểm', () => {
  const result = parseHistory({ success: true, history: [{ date: '2026-10-27', prices: { XAUUSD: { buy: 4000 } } }, { date: '2026-10-26', prices: { XAUUSD: { buy: 0 } } }, { date: '2026-10-25', prices: { XAUUSD: { buy: 3900 } } }] }, 'XAUUSD', 7);
  assert.deepEqual(result.points, [{ date: '2026-10-25', price: 3900 }, { date: '2026-10-27', price: 4000 }]);
  assert.equal(result.granularity, 'daily');
});
test('cảnh báo không kích hoạt theo giá cũ và đổi đúng nhẫn/lượng sang chỉ', () => {
  const recent = new Date().toISOString();
  assert.equal(alertValue({ product: 'XAU' }, { gold: { status: 'stale', price: 4000, updatedAt: recent } }), null);
  assert.equal(alertValue({ product: 'SJ9999' }, { domestic: { status: 'ok', updatedAt: recent, quotes: [{ code: 'SJ9999', sell: 139e6 }] } }), 13.9e6);
});

function fixtureFetcher(log, shouldFail = () => false) {
  return async url => {
    log.push(url); await Promise.resolve();
    if (shouldFail()) throw new Error('network down');
    if (url.includes('gold-api.com')) return Response.json({ symbol: url.endsWith('XAG') ? 'XAG' : 'XAU', price: url.endsWith('XAG') ? 53 : 4000, updatedAt: stamp });
    if (url.includes('vietcombank')) return new Response(xml);
    if (url.includes('vang.today')) return Response.json(domestic);
    throw new Error('Unexpected upstream');
  };
}
test('nhiều người mở trang chia sẻ cache; một lượt đồng thời chỉ gọi nguồn một lần', async () => {
  const log = [];
  const api = createMarketApi({ fetcher: fixtureFetcher(log), now: () => Date.parse(stamp) });
  const [a, b] = await Promise.all([api(request('/api/market')), api(request('/api/market'))]);
  assert.equal(a.status, 200); assert.equal(b.status, 200); assert.equal(log.length, 4);
  await api(request('/api/market')); assert.equal(log.length, 4);
});
test('mất nguồn giữ giá cũ với nhãn stale và giữ nguyên timestamp nguồn', async () => {
  const log = []; let down = false, clock = Date.parse(stamp);
  const api = createMarketApi({ fetcher: fixtureFetcher(log, () => down), now: () => clock });
  await api(request('/api/market'));
  down = true; clock += 301000;
  const result = await (await api(request('/api/market'))).json();
  assert.equal(result.gold.price, 4000); assert.equal(result.gold.status, 'stale'); assert.equal(result.gold.updatedAt, stamp);
  assert.equal(result.domestic.status, 'stale'); assert.equal(result.fx.status, 'stale');
});
test('lỗi lần đầu không tự tạo giá và không làm mất các nguồn còn tốt', async () => {
  const api = createMarketApi({ fetcher: async url => url.includes('/XAU') ? Promise.reject(new Error('down')) : fixtureFetcher([])(url) });
  const result = await (await api(request('/api/market'))).json();
  assert.equal(result.gold.status, 'unavailable'); assert.equal(result.gold.price, undefined); assert.equal(result.domestic.status, 'ok');
});
test('route API chặn truy vấn tùy ý, không trở thành proxy công khai', async () => {
  const api = createMarketApi({ fetcher: () => { throw new Error('must not fetch'); } });
  assert.equal((await api(request('/api/history?symbol=https://example.com&days=7'))).status, 400);
  assert.equal((await api(request('/api/history?symbol=XAUUSD&days=999'))).status, 400);
  assert.equal((await api(request('/api/nope'))).status, 404);
  assert.equal(await api(request('/dashboard')), null);
});
test('sao lưu chỉ nhận giao dịch có khối lượng, giá và ngày hợp lệ', () => {
  const row = { id: 'one', title: 'Tích sản', product: 'SJ9999', quantity: 2, price: 10000000, date: '2026-10-27' };
  assert.deepEqual(parseVaultBackup({ schemaVersion: 1, transactions: [row] }), [row]);
  assert.throws(() => parseVaultBackup({ schemaVersion: 1, transactions: [{ ...row, quantity: -2 }] }));
  assert.throws(() => parseVaultBackup({ schemaVersion: 1, transactions: [{ ...row, price: Infinity }] }));
  assert.throws(() => parseVaultBackup({ transactions: [row] }));
});
