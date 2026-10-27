import { icons } from './icons.js';
import { createMarketWire } from './market-wire.js';
import { premium, projection, vaultTotals, fresh, alertValue, parseVaultBackup } from './domain.js';

const $ = id => document.getElementById(id);
const nf = (value, decimals = 0) => Number.isFinite(value) ? value.toLocaleString('vi-VN', { minimumFractionDigits: decimals, maximumFractionDigits: decimals }) : '—';
const usd = value => Number.isFinite(value) ? '$' + value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '—';
const vnd = value => Number.isFinite(value) ? nf(value) + ' đ' : '—';
const compact = value => !Number.isFinite(value) ? '—' : Math.abs(value) >= 1e9 ? nf(value / 1e9, 2) + ' tỷ' : Math.abs(value) >= 1e6 ? nf(value / 1e6, 2) + ' triệu' : vnd(value);
const esc = value => String(value).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const dateTime = value => Number.isFinite(Date.parse(value)) ? new Intl.DateTimeFormat('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh', day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' }).format(new Date(value)) : 'Chưa có mốc nguồn';
const KEY = { vault: 'aurum-web-vault-v1', alerts: 'aurum-web-alerts-v1', plan: 'aurum-web-plan-v1', market: 'aurum-web-market-v1' };
let storageFailed = false;
function read(key, fallback) { try { return JSON.parse(localStorage.getItem(key)) ?? fallback; } catch { return fallback; } }
function save(key, value) { try { localStorage.setItem(key, JSON.stringify(value)); return true; } catch { storageFailed = true; toast('Trình duyệt chưa cho phép lưu dữ liệu. Hãy sao lưu két vàng trước khi đóng trang.'); return false; } }
let market = null, history = null, filter = 'all', busy = false, historyRequest = 0;
const marketWire = createMarketWire();
let historyDays = 30, historySymbol = 'XAUUSD';
let vault = read(KEY.vault, null);
let alerts = read(KEY.alerts, []);
if (!Array.isArray(alerts)) alerts = [];

function migrateVault() {
  try {
    let old = JSON.parse(localStorage.getItem('flutter.aurum_vault_items_v1'));
    if (typeof old === 'string') old = JSON.parse(old);
    if (!Array.isArray(old)) return [];
    return old.flatMap(item => {
      const unit = typeof item.unit === 'number' ? ['chi', 'phan', 'luong', 'gram'][item.unit] : item.unit;
      const factor = { chi: 1, phan: .1, luong: 10, gram: 1 / 3.75 }[unit];
      const quantity = Number(item.quantity) * factor;
      const price = Number(item.buyPricePerUnit) / factor;
      if (!(quantity > 0 && price > 0)) return [];
      const isSjc = item.productType === 'barSjc' || item.productType === 1;
      return [{ id: String(item.id || crypto.randomUUID()), title: String(item.title || 'Giao dịch đã lưu'), product: isSjc ? 'SJL1L10' : (item.brand === 'sjc' || item.brand === 0) ? 'SJ9999' : 'other', quantity, price, date: String(item.purchaseDate || '').slice(0, 10) }];
    });
  } catch { return []; }
}
if (!Array.isArray(vault)) { vault = migrateVault(); if (vault.length) save(KEY.vault, vault); }
const quotes = () => market?.domestic?.quotes || [];
const quote = code => quotes().find(q => q.code === code);
function toast(text) { const node = document.createElement('div'); node.className = 'toast'; node.textContent = text; $('toast-region').appendChild(node); setTimeout(() => node.remove(), 6500); }
function change(node, value, suffix = '') { node.className = 'change' + (value > 0 ? ' positive' : value < 0 ? ' negative' : ''); node.textContent = Number.isFinite(value) ? (value > 0 ? '↗ +' : value < 0 ? '↘ ' : '') + nf(value) + suffix : '—'; }
function meta(resource, limit) {
  if (!resource?.updatedAt) return `${resource?.source || 'Nguồn'} · chưa có dữ liệu`;
  return `${resource.source} · ${dateTime(resource.updatedAt)}${resource.status === 'stale' ? ' · bản lưu' : fresh(resource, Date.now(), limit) ? '' : ' · mốc nguồn cũ'}`;
}
function cachedMarket() {
  const last = read(KEY.market, null);
  if (!last?.gold && !last?.domestic) return null;
  for (const key of ['gold', 'silver', 'domestic', 'fx']) if (last[key]) last[key].status = 'stale';
  return last;
}
function mergeMarket(previous, next) {
  if (!previous) return next;
  for (const key of ['gold', 'silver', 'domestic', 'fx']) {
    if (next[key]?.status === 'unavailable' && previous[key]?.updatedAt) next[key] = { ...previous[key], status: 'stale', error: next[key].error };
  }
  return next;
}

async function refreshMarket(manual = false) {
  if (busy) return;
  busy = true;
  $('refresh-button').disabled = true;
  try {
    const response = await fetch('/api/market', { cache: 'no-store', signal: AbortSignal.timeout(15000) });
    if (!response.ok) throw new Error('Market unavailable');
    const data = await response.json();
    if (!data.gold || !data.domestic || !data.fx) throw new Error('Unexpected response');
    market = mergeMarket(market, data);
    save(KEY.market, market);
    renderMarket();
    evaluateAlerts();
    if (manual) toast('Đã kiểm tra lại các nguồn. Mốc cập nhật của từng nguồn được giữ nguyên.');
  } catch {
    if (market) for (const key of ['gold', 'silver', 'domestic', 'fx']) if (market[key]) market[key].status = 'stale';
    renderMarket(true);
    if (manual) toast('Chưa kết nối được nguồn. Đang giữ bản dữ liệu gần nhất nếu có.');
  } finally { busy = false; $('refresh-button').disabled = false; }
}

function renderMarket(offline = false) {
  marketWire.updateMarket(market);
  const sjc = quote('SJL1L10'), ring = quote('SJ9999');
  $('gold-value').textContent = usd(market?.gold?.price);
  $('sjc-value').textContent = sjc ? nf(sjc.sell / 1e6, 2) : '—';
  $('ring-value').textContent = ring ? nf(ring.sell / 1e7, 2) : '—';
  $('gold-meta').textContent = meta(market?.gold, 180);
  $('sjc-meta').textContent = meta(market?.domestic, 1200);
  $('ring-meta').textContent = meta(market?.domestic, 1200);
  change($('sjc-change'), sjc?.change, ' đ');
  change($('ring-change'), Number.isFinite(ring?.change) ? ring.change / 10 : NaN, ' đ/chỉ');
  const p = premium(market?.gold?.price, market?.fx?.sell, sjc?.sell);
  $('premium-value').textContent = p ? (p.amount >= 0 ? '+' : '') + nf(p.amount / 1e6, 2) : '—';
  $('premium-percent').textContent = p ? (p.percent > 0 ? '+' : '') + nf(p.percent, 1) + '%' : '—';
  $('premium-meta').textContent = p ? `Thế giới ≈ ${compact(p.world)} / lượng${market.fx.rateType === 'daily-reference' ? ' · tỷ giá ngày' : ''}` : 'Cần giá thế giới, SJC và tỷ giá';
  $('fx-value').textContent = nf(market?.fx?.sell);
  $('fx-buy').textContent = nf(market?.fx?.buy);
  $('fx-transfer').textContent = nf(market?.fx?.transfer);
  $('fx-meta').textContent = meta(market?.fx, market?.fx?.precision === 'day' ? 172800 : 129600);
  $('silver-value').textContent = usd(market?.silver?.price);
  document.querySelector('.context-row:has(.silver) small').textContent = meta(market?.silver, 180);
  $('ratio-value').textContent = market?.gold?.price && market?.silver?.price ? nf(market.gold.price / market.silver.price, 2) : '—';
  const available = [market?.gold, market?.domestic, market?.fx].filter(item => item?.updatedAt).length;
  const allFresh = fresh(market?.gold, Date.now(), 180) && fresh(market?.domestic) && fresh(market?.fx, Date.now(), 172800);
  $('connection-state').textContent = offline ? 'Đang mất kết nối' : allFresh ? 'Đang nhận dữ liệu thật' : available ? 'Một số nguồn đang chậm' : 'Chưa nhận được dữ liệu';
  $('connection-dot').className = 'status-dot' + (allFresh && !offline ? ' ok' : available ? '' : ' error');
  $('updated-time').textContent = market?.servedAt ? 'Kiểm tra nguồn: ' + dateTime(market.servedAt) : 'Tự kiểm tra mỗi 30 giây';
  $('data-banner').hidden = !offline && allFresh && !storageFailed;
  if (!$('data-banner').hidden) $('data-banner').textContent = storageFailed ? 'Trình duyệt không lưu được dữ liệu. Hãy sao lưu két vàng trước khi đóng trang.' : offline ? 'Chưa kết nối được nguồn. Các số còn hiển thị là bản lưu, không phải giá mới. Trang sẽ tự thử lại.' : available ? 'Một số nguồn chậm hoặc đang dùng bản lưu. Xem mốc cập nhật dưới từng thẻ; giá có thể giữ nguyên khi thị trường đóng cửa.' : 'Đang chờ dữ liệu thực từ nguồn. Không sử dụng giá mô phỏng thay thế.';
  renderQuotes(); renderInsights(); renderPlan(); renderVault(); renderSources();
}

function renderInsights() {
  const sjc = quote('SJL1L10');
  const p = premium(market?.gold?.price, market?.fx?.sell, sjc?.sell);
  const list = [];
  if (p) list.push(['Đọc phần chênh lệch trong giá', `SJC cao hơn giá thế giới quy đổi khoảng <strong>${compact(p.amount)} / lượng</strong> (${nf(p.percent, 1)}%). Đây là phép so sánh giá, chưa gồm thuế và phí.`]);
  else list.push(['Đợi đủ dữ liệu để so sánh', 'Cần giá vàng thế giới, tỷ giá và giá SJC từ nguồn trước khi tính chênh lệch.']);
  if (sjc) list.push(['Nhìn cả chiều mua lại', `Chênh mua–bán SJC là <strong>${compact(sjc.sell - sjc.buy)} / lượng</strong>. Giá mua lại cần tăng khoảng ${nf((sjc.sell / sjc.buy - 1) * 100, 2)}% để bằng giá mua hiện tại, chưa tính phí.`]);
  else list.push(['So sánh chi phí ra–vào', 'Khi mua, xem giá bán ra. Khi cần bán, giá mua vào mới là mốc tham chiếu cho tài sản của bạn.']);
  const form = new FormData($('planner-form'));
  const budget = Number(form.get('income')) * Number(form.get('percent')) / 100;
  const chosen = quote(form.get('product'));
  list.push(['Giữ kế hoạch vừa với ngân sách', chosen ? `Với ngân sách bạn chọn <strong>${compact(budget)} / tháng</strong>, lượng mua tham chiếu là ${nf(budget / (chosen.sell / 10), 3)} chỉ. Có thể điều chỉnh kế hoạch ngay bên dưới.` : 'Đặt ngân sách và thời gian tích lũy. Công cụ sẽ quy đổi theo giá bán thực tế khi nguồn phản hồi.']);
  $('insights-list').innerHTML = list.map(([title, text], index) => `<article class="insight"><span class="insight-index">0${index + 1}</span><div><h3>${title}</h3><p>${text}</p></div></article>`).join('');
}

function filteredQuotes() {
  const fold = value => value.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replaceAll('đ', 'd');
  const search = fold($('market-search').value.trim());
  return quotes().filter(row => (filter === 'all' || row.type === filter) && fold(row.brand + ' ' + row.name).includes(search));
}
function renderQuotes() {
  const rows = filteredQuotes();
  const divisor = $('unit-select').value === 'chi' ? 1e7 : 1e6;
  $('quote-count').textContent = quotes().length;
  $('quote-rows').innerHTML = rows.length ? rows.map(row => `<tr><td><div class="product-cell"><span class="brand-monogram ${row.brand === 'PNJ' ? 'pnj' : row.brand === 'DOJI' ? 'doji' : ''}">${esc(row.brand === 'Bảo Tín' ? 'BT' : row.brand.slice(0, 3))}</span><div><strong>${esc(row.name)}</strong><small>${row.type === 'ring' ? 'Nhẫn / vàng 24K' : 'Vàng miếng'} · ${esc(row.brand)}</small></div></div></td><td class="numeric">${nf(row.buy / divisor, 2)}</td><td class="numeric sell-price">${nf(row.sell / divisor, 2)}</td><td class="numeric spread-price">${nf((row.sell - row.buy) / divisor, 2)}</td><td class="numeric ${row.change > 0 ? 'positive' : row.change < 0 ? 'negative' : 'muted'}">${row.change > 0 ? '↗ +' : row.change < 0 ? '↘ ' : ''}${nf(row.change / divisor, 3)}</td></tr>`).join('') : `<tr><td colspan="5" class="empty-cell">${quotes().length ? 'Không có sản phẩm khớp bộ lọc.' : 'Chưa có dữ liệu từ nguồn. Bảng giá sẽ tự thử lại.'}</td></tr>`;
  $('table-meta').textContent = market?.domestic?.updatedAt ? `vang.today · mốc bảng ${dateTime(market.domestic.updatedAt)} · biến động do nguồn công bố${market.domestic.status !== 'ok' ? ' · BẢN LƯU' : ''}` : 'Nguồn tổng hợp: vang.today · khoảng 5 phút';
}

async function loadHistory() {
  const seq = ++historyRequest;
  $('chart-change').textContent = 'Đang lấy lịch sử…';
  try {
    const response = await fetch(`/api/history?symbol=${historySymbol}&days=${historyDays}`, { cache: 'no-store', signal: AbortSignal.timeout(15000) });
    const data = await response.json();
    if (seq !== historyRequest) return;
    if (!response.ok || !data.points?.length) throw new Error('No history');
    history = data;
    renderChart();
  } catch {
    if (seq !== historyRequest) return;
    history = null;
    $('chart-value').textContent = '—';
    $('chart-change').textContent = 'Chưa lấy được lịch sử';
    $('price-chart').innerHTML = '<div class="chart-empty">Nguồn lịch sử tạm thời chưa phản hồi.<br>Hãy thử Làm mới sau ít phút.</div>';
  }
}

function renderChart() {
  if (!history?.points?.length) return;
  const points = history.points, isWorld = history.symbol === 'XAUUSD';
  const first = points[0], last = points.at(-1);
  const fmt = value => isWorld ? usd(value) : nf(value / 1e6, 2) + ' triệu';
  $('chart-value').textContent = fmt(last.price);
  $('chart-unit').textContent = isWorld ? 'USD / oz' : 'đồng / lượng';
  const diff = (last.price / first.price - 1) * 100;
  $('chart-change').className = 'change ' + (diff >= 0 ? 'positive' : 'negative');
  $('chart-change').textContent = `${diff >= 0 ? '↗ +' : '↘ '}${nf(diff, 2)}% trong ${history.days} ngày`;
  $('chart-source').textContent = `Lịch sử ngày · vang.today${history.status === 'stale' ? ' · BẢN LƯU' : ''}`;
  $('chart-caption').textContent = 'Điểm ngày hiện tại chưa chốt · có thể khác giá spot';
  const host = $('price-chart'), width = Math.max(host.clientWidth, 270), height = host.clientHeight || 229;
  const pad = { left: 17, right: 59, top: 13, bottom: 28 };
  let min = Math.min(...points.map(p => p.price)), max = Math.max(...points.map(p => p.price));
  const margin = Math.max((max - min) * .18, max * .001);
  min -= margin; max += margin;
  const start = Date.parse(first.date), end = Date.parse(last.date);
  const x = p => pad.left + (end > start ? (Date.parse(p.date) - start) / (end - start) : .5) * (width - pad.left - pad.right);
  const y = price => pad.top + (max - price) / (max - min) * (height - pad.top - pad.bottom);
  const path = points.map((p, i) => `${i ? 'L' : 'M'}${x(p).toFixed(2)} ${y(p.price).toFixed(2)}`).join(' ');
  const bottom = height - pad.bottom;
  const area = `${path} L${x(last).toFixed(2)} ${bottom} L${x(first).toFixed(2)} ${bottom} Z`;
  let grid = '';
  for (let i = 0; i < 4; i++) {
    const price = min + (max - min) * i / 3, yy = y(price);
    grid += `<line x1="${pad.left}" x2="${width - pad.right + 3}" y1="${yy}" y2="${yy}" stroke="#303640" stroke-width=".6" stroke-dasharray="2 4"/><text x="${width - pad.right + 11}" y="${yy + 3}" fill="#7b8492" font-size="8" font-family="inherit">${isWorld ? nf(price) : nf(price / 1e6, 1)}</text>`;
  }
  const indices = [...new Set(Array.from({ length: Math.min(6, points.length) }, (_, i) => Math.round(i * (points.length - 1) / (Math.min(6, points.length) - 1 || 1))))];
  for (const i of indices) grid += `<text x="${x(points[i])}" y="${height - 7}" text-anchor="middle" fill="#768191" font-size="7" font-family="inherit">${points[i].date.slice(8)}/${points[i].date.slice(5, 7)}</text>`;
  host.innerHTML = `<svg viewBox="0 0 ${width} ${height}" aria-hidden="true"><defs><linearGradient id="price-fill" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#d8b96f" stop-opacity=".20"/><stop offset="100%" stop-color="#d8b96f" stop-opacity="0"/></linearGradient></defs>${grid}<path d="${area}" fill="url(#price-fill)"/><path d="${path}" fill="none" stroke="#e6c67c" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><line id="chart-crosshair" x1="${x(last)}" x2="${x(last)}" y1="${pad.top}" y2="${bottom}" stroke="#b29a6444" stroke-dasharray="3 4"/><circle id="chart-point" cx="${x(last)}" cy="${y(last.price)}" r="3.5" fill="#eccf8b" stroke="#746748" stroke-width="4" stroke-opacity=".35"/></svg><div class="chart-tooltip" hidden></div>`;
  host.setAttribute('aria-label', `${points.length} điểm giá thật từ ${first.date} đến ${last.date}. Giá gần nhất ${fmt(last.price)}.`);
  const tooltip = host.querySelector('.chart-tooltip');
  host.onpointermove = event => {
    const xx = event.clientX - host.getBoundingClientRect().left;
    const point = points.reduce((a, b) => Math.abs(x(a) - xx) < Math.abs(x(b) - xx) ? a : b);
    tooltip.hidden = false;
    tooltip.style.left = Math.max(64, Math.min(width - 64, x(point))) + 'px';
    tooltip.style.top = Math.max(0, y(point.price) - 47) + 'px';
    tooltip.innerHTML = `${point.date.slice(8)}/${point.date.slice(5, 7)}/${point.date.slice(0, 4)}<strong>${fmt(point.price)}</strong>`;
    const line = host.querySelector('#chart-crosshair'), dot = host.querySelector('#chart-point');
    line.setAttribute('x1', x(point)); line.setAttribute('x2', x(point)); dot.setAttribute('cx', x(point)); dot.setAttribute('cy', y(point.price));
  };
  host.onpointerleave = () => { tooltip.hidden = true; };
}

function renderPlan() {
  const data = new FormData($('planner-form'));
  const income = Number(data.get('income')), percent = Number(data.get('percent')), years = Number(data.get('years')), growth = Number(data.get('growth'));
  const product = quote(data.get('product'));
  $('plan-percent').textContent = `${nf(percent)}% thu nhập`;
  $('plan-budget').innerHTML = `${nf(income * percent / 100)} <small>đ</small>`;
  const result = projection({ income, percent, years, growth, sellPerChi: product?.sell / 10, buyPerChi: product?.buy / 10 });
  $('plan-monthly-chi').textContent = result ? `≈ ${nf(result.monthlyQuantity, 3)} chỉ theo giá bán hiện tại${fresh(market?.domestic) ? '' : ' · giá lưu / chậm'}` : 'Chờ giá bán thực tế để quy đổi';
  $('plan-capital').textContent = compact(income * percent / 100 * years * 12);
  $('plan-future').textContent = result ? compact(result.value) : 'Chờ giá mua lại';
  if (result) {
    const maximum = Math.max(...result.points.map(p => p.value), 1);
    $('projection-bars').innerHTML = result.points.map(point => `<span style="height:${Math.max(2, point.value / maximum * 100)}%" title="Năm ${point.year}: ${compact(point.value)} · mô phỏng"></span>`).join('');
  } else $('projection-bars').innerHTML = '';
}

function renderVault() {
  const totals = vaultTotals(vault, quotes());
  const values = [['Tổng khối lượng', nf(totals.quantity, 3) + ' chỉ', ''], ['Vốn đã ghi nhận', compact(totals.invested), ''], [`Bán lại tham chiếu · ${totals.valued}/${vault.length} món${fresh(market?.domestic) ? '' : ' · giá lưu / chậm'}`, totals.valued ? compact(totals.market) : '—', 'gold-text'], ['Lãi / lỗ phần được định giá', totals.valued ? (totals.profit > 0 ? '+' : '') + compact(totals.profit) : '—', totals.profit >= 0 ? 'positive' : 'negative']];
  $('vault-summary').innerHTML = vault.length ? `<div class="vault-stats">${values.map(([label, value, css]) => `<div class="vault-stat"><span>${label}</span><strong class="${css}">${value}</strong></div>`).join('')}</div>` : '';
  $('vault-content').innerHTML = !vault.length ? '<div class="vault-empty"><span class="icon-tile"><i data-icon="vault"></i></span><div><strong>Mỗi khoản tích lũy đều xứng đáng được ghi lại.</strong>Thêm giao dịch đầu tiên để theo dõi giá vốn và giá trị bán lại từ bảng giá thật.</div></div>' : `<div class="table-scroll"><table class="vault-table"><thead><tr><th>GIAO DỊCH</th><th class="numeric">KHỐI LƯỢNG</th><th class="numeric">GIÁ VỐN / CHỈ</th><th class="numeric">BÁN LẠI THAM CHIẾU</th><th></th></tr></thead><tbody>${vault.map(item => `<tr><td><strong>${esc(item.title)}</strong><small class="muted" style="display:block;margin-top:4px">${esc(item.date)} · ${esc(quote(item.product)?.name || 'Chưa ghép nguồn định giá')}</small></td><td class="numeric">${nf(item.quantity, 3)} chỉ</td><td class="numeric">${vnd(item.price)}</td><td class="numeric gold-text">${quote(item.product)?.buy ? compact(item.quantity * quote(item.product).buy / 10) : 'Chưa có giá phù hợp'}</td><td class="numeric"><button class="icon-button" data-delete-vault="${esc(item.id)}" aria-label="Xóa ${esc(item.title)}"><i data-icon="trash"></i></button></td></tr>`).join('')}</tbody></table></div>`;
  icons($('vault-content'));
}

function renderAlerts() {
  $('alert-count').textContent = alerts.filter(a => !a.triggeredAt).length;
  $('notification-dot').hidden = !alerts.some(a => a.triggeredAt);
  $('alert-list').innerHTML = !alerts.length ? '<div class="alert-empty"><span class="empty-icon"><i data-icon="bell"></i></span><p>Đặt một mức giá bạn quan tâm.<br>Để thị trường tự nhắc bạn nhìn lại.</p><button class="button secondary" id="empty-add-alert"><i data-icon="plus"></i>Tạo cảnh báo đầu tiên</button></div>' : `<div class="alert-items">${alerts.map(alert => `<article class="alert-item"><span class="status-dot ${alert.triggeredAt ? '' : 'ok'}"></span><div><h3>${alert.product === 'XAU' ? 'Vàng thế giới' : alert.product === 'SJ9999' ? 'Nhẫn SJC 9999' : 'Vàng miếng SJC'}</h3><p>${alert.direction === 'below' ? '≤' : '≥'} ${nf(alert.threshold, alert.product === 'XAU' ? 2 : 0)} ${alert.product === 'XAU' ? 'USD / oz' : alert.product === 'SJ9999' ? 'đ / chỉ' : 'đ / lượng'}</p><p>${alert.triggeredAt ? 'Đã chạm ngưỡng · ' + dateTime(alert.triggeredAt) : 'Đang theo dõi · khi trang mở'}</p></div><button class="icon-button" data-delete-alert="${esc(alert.id)}" aria-label="Xóa cảnh báo"><i data-icon="x"></i></button></article>`).join('')}</div>`;
  icons($('alert-list'));
  $('empty-add-alert')?.addEventListener('click', openAlert);
}
function evaluateAlerts() {
  let changed = false;
  for (const alert of alerts) {
    const value = alertValue(alert, market);
    if (!alert.triggeredAt && value !== null && (alert.direction === 'below' ? value <= alert.threshold : value >= alert.threshold)) {
      alert.triggeredAt = new Date().toISOString(); changed = true;
      toast(`Đã chạm ngưỡng ${alert.product === 'XAU' ? 'vàng thế giới' : 'SJC'}: ${nf(value, alert.product === 'XAU' ? 2 : 0)}. Hãy kiểm tra lại giá tại nguồn.`);
    }
  }
  if (changed) { save(KEY.alerts, alerts); renderAlerts(); }
}

function renderSources() {
  $('source-details').innerHTML = [
    ['Giá spot vàng & bạc', market?.gold, 180, 'Gold API miễn phí, không cần khóa; nhà cung cấp công bố cập nhật khoảng 30 giây. Giá theo USD / troy ounce. Mốc nguồn là lúc Gold API lấy được giá.'],
    ['Bảng giá Việt Nam & lịch sử', market?.domestic, 1200, 'vang.today là nguồn tổng hợp độc lập, không phải API trực tiếp của SJC/DOJI/PNJ. Khoảng 5 phút/lần; giá gốc đồng/lượng. Biểu đồ là các điểm giá theo ngày, ngày hiện tại chưa chốt. Biến động bảng do nguồn công bố, không mặc định là 24 giờ.'],
    ['Tỷ giá USD / VND', market?.fx, 172800, 'Ưu tiên tỷ giá USD bán ra trong XML công khai Vietcombank, chỉ lấy tối đa mỗi 5 phút. Nếu không truy cập được, dùng Currency API theo ngày và ghi rõ nguồn dự phòng. Không phải giá giao dịch ngoại tệ tức thời.'],
  ].map(([title, resource, limit, description]) => `<article class="source-detail"><h3>${title}<span class="tag ${fresh(resource, Date.now(), limit) ? 'gold-tag' : 'neutral'}">${fresh(resource, Date.now(), limit) ? 'Đã kết nối' : resource?.updatedAt ? 'Bản lưu / chậm' : 'Chưa có dữ liệu'}</span></h3><p>${description}</p><p>${esc(meta(resource, limit))}</p><a href="${resource?.sourceUrl || (title.includes('spot') ? 'https://gold-api.com/faqs' : title.includes('Việt') ? 'https://www.vang.today/vi/api' : 'https://www.vietcombank.com.vn')}" target="_blank" rel="noopener noreferrer">Tài liệu / nguồn dữ liệu ↗</a></article>`).join('');
  $('source-details').innerHTML += `<article class="source-detail"><h3>Bàn tin RSS & dòng tin cuối trang</h3><p>Vietstock: vàng và kim loại quý. Federal Reserve: thông cáo chính sách tiền tệ, giữ tiêu đề tiếng Anh của nguồn. Chỉ hiển thị tiêu đề, giờ đăng và link bài gốc; kiểm tra mỗi 5 phút, chuyển tin mỗi 7 giây. Không có tin hôm nay sẽ ghi rõ tin gần nhất.</p>${marketWire.newsSources().map(source => `<p>${esc(source.name)} · ${source.status === 'ok' ? 'kiểm tra thành công' : source.status === 'stale' ? 'bản lưu · kiểm tra thành công trước đó' : 'tạm mất kết nối'}${source.fetchedAt ? ' ' + dateTime(source.fetchedAt) : ''}</p>`).join('')}<a href="https://vietstock.vn/rss" target="_blank" rel="noopener noreferrer">Vietstock RSS ↗</a> · <a href="https://www.federalreserve.gov/feeds/feeds.htm" target="_blank" rel="noopener noreferrer">Federal Reserve RSS ↗</a></article>`;
}

function openVault() {
  const form = $('vault-form'); form.reset();
  form.elements.date.value = new Date().toLocaleDateString('en-CA', { timeZone: 'Asia/Ho_Chi_Minh' });
  form.elements.price.value = quote(form.elements.product.value)?.sell / 10 || '';
  $('vault-dialog').showModal();
}
function openAlert() {
  const form = $('alert-form'); form.reset();
  form.elements.threshold.value = market?.gold?.price ? Math.floor(market.gold.price * .99) : '';
  $('alert-dialog').showModal();
}
function download(name, type, text) { const url = URL.createObjectURL(new Blob([text], { type })); const link = document.createElement('a'); link.href = url; link.download = name; link.click(); setTimeout(() => URL.revokeObjectURL(url), 1000); }

icons();
$('today').textContent = new Intl.DateTimeFormat('vi-VN', { weekday: 'short', day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'Asia/Ho_Chi_Minh' }).format(new Date());
const savedPlan = read(KEY.plan, null);
if (savedPlan) for (const [name, value] of Object.entries(savedPlan)) if ($('planner-form').elements[name]) $('planner-form').elements[name].value = value;
$('planner-form').addEventListener('submit', event => event.preventDefault());
$('planner-form').addEventListener('input', () => { renderPlan(); renderInsights(); save(KEY.plan, Object.fromEntries(new FormData($('planner-form')))); });
$('market-search').addEventListener('input', renderQuotes);
$('unit-select').addEventListener('change', renderQuotes);
$('market-filters').addEventListener('click', event => { const button = event.target.closest('[data-filter]'); if (!button) return; filter = button.dataset.filter; $('market-filters').querySelectorAll('button').forEach(node => node.classList.toggle('selected', node === button)); renderQuotes(); });
$('chart-period').addEventListener('click', event => { const button = event.target.closest('[data-days]'); if (!button) return; historyDays = Number(button.dataset.days); $('chart-period').querySelectorAll('button').forEach(node => { node.classList.toggle('selected', node === button); node.setAttribute('aria-pressed', String(node === button)); }); loadHistory(); });
$('chart-symbol').addEventListener('change', event => { historySymbol = event.target.value; loadHistory(); });
$('refresh-button').addEventListener('click', () => { refreshMarket(true); loadHistory(); marketWire.refreshNews(); });
for (const id of ['sources-button', 'footer-sources']) $(id).addEventListener('click', () => { renderSources(); $('sources-dialog').showModal(); });
for (const id of ['add-alert', 'header-alert']) $(id).addEventListener('click', openAlert);
$('add-vault').addEventListener('click', openVault);
$('vault-product').addEventListener('change', event => { $('vault-form').elements.price.value = quote(event.target.value)?.sell / 10 || ''; });
$('alert-form').elements.product.addEventListener('change', event => { const code = event.target.value; const value = code === 'XAU' ? market?.gold?.price : quote(code)?.sell / (code === 'SJ9999' ? 10 : 1); $('alert-form').elements.threshold.value = value ? Math.floor(value * .99) : ''; });
$('vault-form').addEventListener('submit', event => {
  event.preventDefault(); const data = new FormData(event.target);
  const quantity = Number(data.get('quantity')), price = Number(data.get('price'));
  if (!(quantity > 0 && quantity <= 1e6 && price > 0 && price <= 1e10)) return;
  vault.push({ id: crypto.randomUUID(), title: String(data.get('title')).trim().slice(0, 100) || 'Khoản tích lũy', product: String(data.get('product')), quantity, price, date: String(data.get('date')) });
  save(KEY.vault, vault); renderVault(); $('vault-dialog').close(); toast('Đã ghi nhận giao dịch vào két vàng trên trình duyệt này.');
});
$('alert-form').addEventListener('submit', event => {
  event.preventDefault(); const data = new FormData(event.target), threshold = Number(data.get('threshold'));
  if (!(threshold > 0 && threshold <= 1e10)) return;
  alerts.push({ id: crypto.randomUUID(), product: String(data.get('product')), direction: String(data.get('direction')), threshold, triggeredAt: null });
  save(KEY.alerts, alerts); renderAlerts(); $('alert-dialog').close(); toast('Đã thêm cảnh báo. Giữ trang mở để theo dõi.'); evaluateAlerts();
});
document.addEventListener('click', event => {
  const close = event.target.closest('[data-close]'); if (close) $(close.dataset.close).close();
  const delVault = event.target.closest('[data-delete-vault]');
  if (delVault && confirm('Xóa giao dịch này khỏi két vàng trên trình duyệt?')) { vault = vault.filter(item => item.id !== delVault.dataset.deleteVault); save(KEY.vault, vault); renderVault(); }
  const delAlert = event.target.closest('[data-delete-alert]');
  if (delAlert) { alerts = alerts.filter(alert => alert.id !== delAlert.dataset.deleteAlert); save(KEY.alerts, alerts); renderAlerts(); }
  if ($('sidebar').classList.contains('open') && !event.target.closest('#sidebar, #menu-toggle')) $('sidebar').classList.remove('open');
});
$('export-prices').addEventListener('click', () => {
  if (!quotes().length) return toast('Chưa có dữ liệu giá để xuất.');
  const rows = [['san_pham', 'mua_vnd_luong', 'ban_vnd_luong', 'chenh_vnd_luong', 'nguon', 'moc_bang_gia'], ...filteredQuotes().map(row => [row.name, row.buy, row.sell, row.sell - row.buy, 'vang.today', market.domestic.updatedAt])];
  download('aurum-bang-gia.csv', 'text/csv;charset=utf-8', '\uFEFF' + rows.map(row => row.map(cell => '"' + String(cell).replaceAll('"', '""') + '"').join(',')).join('\r\n'));
});
$('export-vault').addEventListener('click', () => download('aurum-ket-vang.json', 'application/json', JSON.stringify({ schemaVersion: 1, exportedAt: new Date().toISOString(), transactions: vault }, null, 2)));
const importButton = document.createElement('button');
importButton.className = 'text-button'; importButton.id = 'import-vault'; importButton.textContent = 'Khôi phục';
$('export-vault').before(importButton);
const importInput = document.createElement('input');
importInput.type = 'file'; importInput.accept = '.json,application/json'; importInput.hidden = true; importInput.id = 'vault-import';
document.body.appendChild(importInput);
importButton.addEventListener('click', () => importInput.click());
importInput.addEventListener('change', async () => {
  try {
    const file = importInput.files[0]; if (!file) return;
    if (file.size > 2000000) throw new Error('Too large');
    const items = parseVaultBackup(JSON.parse(await file.text()));
    const ids = new Set(vault.map(item => item.id));
    const added = items.filter(item => { if (ids.has(item.id)) return false; ids.add(item.id); return true; });
    vault.push(...added); save(KEY.vault, vault); renderVault(); toast(`Đã khôi phục ${added.length} giao dịch. Các giao dịch hiện có được giữ lại.`);
  } catch { toast('File sao lưu chưa đúng định dạng AurumSentinel hoặc chứa giao dịch không hợp lệ.'); }
  finally { importInput.value = ''; }
});
$('menu-toggle').addEventListener('click', () => $('sidebar').classList.toggle('open'));
document.querySelectorAll('.nav-item[href]').forEach(link => link.addEventListener('click', () => { document.querySelectorAll('.nav-item[href]').forEach(item => { item.classList.toggle('active', item === link); item.removeAttribute('aria-current'); }); link.setAttribute('aria-current', 'page'); $('sidebar').classList.remove('open'); }));
new ResizeObserver(() => requestAnimationFrame(renderChart)).observe($('price-chart'));
market = cachedMarket();
renderMarket(); renderAlerts();
refreshMarket(); loadHistory();
setInterval(() => { if (!document.hidden) refreshMarket(); }, 30000);
setInterval(() => { if (!document.hidden) loadHistory(); }, 300000);
document.addEventListener('visibilitychange', () => { if (!document.hidden) refreshMarket(); });
window.addEventListener('online', () => refreshMarket());
