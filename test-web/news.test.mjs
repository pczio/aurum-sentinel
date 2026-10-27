import test from 'node:test';
import assert from 'node:assert/strict';
import { createMarketApi, parseRss, NEWS_FEEDS } from '../server/worker.mjs';
import { vietnamDay, selectNews } from '../web/market-wire.js';

const now = Date.parse('2026-10-27T09:00:00Z');
const feed = NEWS_FEEDS[0];
const story = (title = 'Giá vàng tăng trước cuộc họp Fed', url = 'http://vietstock.vn/gold.htm', date = 'Tue, 27 Oct 2026 11:02:01 +0700') => `<item><title><![CDATA[${title}]]></title><link>${url}</link><pubDate>${date}</pubDate><description>Không sao chép nội dung bài báo</description></item>`;
const rss = (...rows) => `<rss version="2.0"><channel>${rows.join('')}</channel></rss>`;
const request = () => new Request('https://aurum.test/api/news');

test('RSS đọc CDATA, entity, múi giờ và chỉ lấy tiêu đề, thời gian, link nguồn', () => {
  const [item] = parseRss(rss(story('Vàng &#38; bạc: Fed &#x2014; lãi suất &quot;mới&quot;')), feed, now);
  assert.equal(item.title, 'Vàng & bạc: Fed — lãi suất "mới"');
  assert.equal(item.publishedAt, '2026-10-27T04:02:01.000Z');
  assert.equal(item.url, 'https://vietstock.vn/gold.htm');
  assert.equal(item.source, 'Vietstock');
  assert.equal(item.description, undefined);
});

test('RSS bỏ link sai host, credentials, javascript, thời gian lỗi/tương lai và DTD', () => {
  const xml = rss(story('Tin vàng hợp lệ trong ngày', 'https://vietstock.vn/gold.htm?utm_source=rss#part'), story('Tiêu đề chứa đường dẫn độc', 'javascript:alert(1)'), story('Sai tên miền của nhà cung cấp', 'https://vietstock.vn.evil.test/x'), story('Không nhận thông tin đăng nhập', 'https://user:pass@vietstock.vn/x'), story('Tin ngày mai không được hiển thị', 'https://vietstock.vn/future', 'Wed, 28 Oct 2026 11:02:01 +0700'), story('Ngày đăng không hợp lệ', 'https://vietstock.vn/invalid', 'invalid'));
  const items = parseRss(xml, feed, now);
  assert.equal(items.length, 1); assert.equal(items[0].url, 'https://vietstock.vn/gold.htm');
  assert.throws(() => parseRss('<!DOCTYPE rss [<!ENTITY x SYSTEM "file:///secret">]>' + xml, feed, now));
  assert.throws(() => parseRss('<html>upstream unavailable</html>', feed, now));
});

test('RSS sắp xếp mới nhất và giữ bài mới khi cùng URL lặp lại', () => {
  const items = parseRss(rss(story('Tiêu đề mới nhất của bài', 'https://vietstock.vn/a'), story('Tiêu đề cũ cùng đường dẫn', 'https://vietstock.vn/a', 'Mon, 26 Oct 2026 11:00:00 +0700'), story('Tiêu đề khác ngày hôm trước', 'https://vietstock.vn/b', 'Mon, 26 Oct 2026 12:00:00 +0700')), feed, now);
  assert.equal(items.length, 2); assert.equal(items[0].title, 'Tiêu đề mới nhất của bài');
});

test('ngày Việt Nam dùng UTC+7, chỉ ưu tiên tin hôm nay và ghi nhận fallback tin cũ', () => {
  assert.equal(vietnamDay('2026-10-26T18:00:00Z'), '2026-10-27');
  const items = [{ topic: 'gold', title: 'Hôm nay', publishedAt: '2026-10-26T18:00:00Z' }, { topic: 'gold', title: 'Hôm qua', publishedAt: '2026-10-26T10:00:00Z' }, { topic: 'macro', title: 'Fed', publishedAt: '2026-10-13T18:00:00Z' }];
  assert.equal(selectNews(items, 'gold', now).today, 1);
  assert.equal(selectNews(items, 'gold', now).rows[0].title, 'Hôm nay');
  assert.equal(selectNews(items, 'macro', now).today, 0);
  assert.equal(selectNews(items, 'macro', now).rows[0].title, 'Fed');
});

test('API RSS dùng whitelist và gộp các yêu cầu đồng thời vào cache 5 phút', async () => {
  const urls = [];
  const api = createMarketApi({ now: () => now, fetcher: async (url, options) => {
    // Regression: workerd's empty default User-Agent receives HTTP 403 from Vietstock.
    assert.match(options.headers['User-Agent'], /^AurumSentinel\//);
    assert.match(options.headers.Accept, /application\/rss\+xml/);
    urls.push(url); await Promise.resolve();
    return new Response(rss(story('Bản tin vàng trong ngày', url.includes('vietstock') ? 'https://vietstock.vn/a' : 'https://www.federalreserve.gov/a')));
  } });
  const responses = await Promise.all([api(request()), api(request()), api(new Request('https://aurum.test/api/news?url=https://evil.test'))]);
  assert.equal(urls.length, 2); assert.deepEqual(urls.sort(), NEWS_FEEDS.map(row => row.url).sort());
  const data = await responses[0].json();
  assert.equal(data.items.length, 1); // identical headline across providers is deduplicated
  assert.equal(data.refreshSeconds, 300); assert.ok(data.sources.every(row => row.status === 'ok'));
});

test('một RSS lỗi không làm mất nguồn còn tốt; bản lưu giữ nguyên giờ đăng và giờ kiểm tra', async () => {
  let time = now, fail = false;
  const api = createMarketApi({ now: () => time, fetcher: async url => {
    if (url.includes('federalreserve') || fail) throw new Error('offline');
    return new Response(rss(story()));
  } });
  const first = await (await api(request())).json();
  assert.equal(first.items.length, 1); assert.equal(first.sources[1].status, 'unavailable');
  time += 301000; fail = true;
  const last = await (await api(request())).json();
  assert.equal(last.items[0].status, 'stale');
  assert.equal(last.items[0].publishedAt, first.items[0].publishedAt);
  assert.equal(last.items[0].checkedAt, first.items[0].checkedAt);
  time += 86400000;
  const expired = await (await api(request())).json();
  assert.equal(expired.items.length, 0); assert.ok(expired.sources.every(row => row.status === 'unavailable'));
});
