const escapeHtml = value => String(value ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const number = (n, digits = 2) => Number.isFinite(n) ? n.toLocaleString('vi-VN', { minimumFractionDigits: digits, maximumFractionDigits: digits }) : '—';
const clock = value => Number.isFinite(Date.parse(value)) ? new Intl.DateTimeFormat('vi-VN', { timeZone: 'Asia/Ho_Chi_Minh', hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit' }).format(new Date(value)) : 'Chưa có mốc nguồn';
export const vietnamDay = value => new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Ho_Chi_Minh', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date(value));
export function selectNews(items, topic, now = Date.now()) {
  const rows = items.filter(item => item.topic === topic && Number.isFinite(Date.parse(item.publishedAt)) && Date.parse(item.publishedAt) <= now + 300000).sort((a, b) => b.publishedAt.localeCompare(a.publishedAt));
  const today = rows.filter(item => vietnamDay(item.publishedAt) === vietnamDay(now));
  return { today: today.length, rows: (today.length ? today : rows).slice(0, 12) };
}

export function createMarketWire() {
  const $ = id => document.getElementById(id);
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const tickers = [...document.querySelectorAll('[data-ticker]')];
  let data = null, topic = 'gold', items = [], index = 0, paused = false, busy = false, lastSuccess = 0, signature = '', pending = null;
  let focusHeld = false, hoverHeld = false;
  const card = $('news');

  function tickerContent(id, content, pixelsPerSecond) {
    const ticker = $(id), track = ticker.querySelector('.ticker-track');
    if (ticker.matches(':focus-within')) { ticker.pendingContent = [id, content, pixelsPerSecond]; return; }
    if (track.dataset.content === content) return;
    // Keep the animated element in place as prices change; only replace its children.
    track.dataset.content = content;
    track.innerHTML = `<div class="ticker-group">${content}</div><div class="ticker-group" aria-hidden="true" inert>${content}</div>`;
    const width = track.firstElementChild.getBoundingClientRect().width;
    track.style.setProperty('--ticker-duration', Math.max(28, width / pixelsPerSecond) + 's');
  }
  tickers.forEach(ticker => {
    const button = ticker.querySelector('[data-ticker-pause]');
    button.addEventListener('click', () => {
      const stopped = ticker.classList.toggle('is-paused');
      button.setAttribute('aria-pressed', String(stopped));
      button.textContent = stopped ? '▶' : 'Ⅱ';
      button.setAttribute('aria-label', `${stopped ? 'Chạy' : 'Tạm dừng'} ${ticker.id === 'price-ticker' ? 'thanh giá' : 'dòng tin'}`);
    });
    ticker.addEventListener('focusout', () => setTimeout(() => {
      if (!ticker.matches(':focus-within') && ticker.pendingContent) {
        const args = ticker.pendingContent; ticker.pendingContent = null; tickerContent(...args);
      }
    }, 0));
  });

  function updateMarket(market) {
    const values = [];
    const add = (label, value, unit, resource, change, limit = 1200000) => {
      if (!Number.isFinite(value)) return;
      const old = resource?.status !== 'ok' || !resource.updatedAt || Date.now() - Date.parse(resource.updatedAt) > limit;
      const delta = Number.isFinite(change) ? `<span class="wire-change ${change > 0 ? 'positive' : change < 0 ? 'negative' : ''}">${change > 0 ? '▲ +' : change < 0 ? '▼ ' : ''}${number(change / 1e6, 2)} tr</span>` : '';
      values.push(`<a class="price-tick${old ? ' old-quote' : ''}" href="#market" title="${escapeHtml(resource?.source)} · ${clock(resource?.updatedAt)}${old ? ' · mốc nguồn cũ / bản lưu' : ''}"><span class="tick-symbol">${label}</span><strong>${number(value, unit === 'đ/USD' ? 0 : 2)}</strong><small>${unit}</small>${delta}<span class="tick-stamp">${old ? 'MỐC CŨ · ' : ''}${clock(resource?.updatedAt)}</span></a>`);
    };
    add('XAU/USD', market?.gold?.price, 'USD/oz', market?.gold, null, 180000);
    add('XAG/USD', market?.silver?.price, 'USD/oz', market?.silver, null, 180000);
    const quotes = market?.domestic?.quotes || [];
    for (const q of quotes.slice(0, 8)) add(q.name.replace('Vàng miếng ', '').replace('Nhẫn ', 'NHẪN '), q.sell / 1e6, 'tr/lượng · bán', market.domestic, q.change);
    add('USD/VND', market?.fx?.sell, 'đ/USD', market?.fx, null, market?.fx?.precision === 'day' ? 172800000 : 129600000);
    tickerContent('price-ticker', values.join('') || '<span class="wire-placeholder">Đang kết nối bảng giá vàng, bạc và tỷ giá…</span>', 36);
    $('price-ticker').querySelector('.ticker-label small').textContent = values.length ? 'MỐC TỪ NGUỒN' : 'ĐANG KẾT NỐI';
  }

  function renderBottom() {
    const gold = selectNews(data?.items || [], 'gold');
    const content = gold.rows.map(item => `<a class="headline-tick" href="${escapeHtml(item.url)}" target="_blank" rel="noopener noreferrer"><span class="wire-bullet"></span><b>${clock(item.publishedAt)}${item.status === 'stale' ? ' · BẢN LƯU' : ''}</b><span>${escapeHtml(item.title)}</span><small>${escapeHtml(item.source)} ↗</small></a>`).join('');
    tickerContent('news-ticker', content || '<a class="headline-tick" href="#news">Chưa nhận được bản tin vàng từ RSS. Mở bàn tin để kiểm tra nguồn và thử lại.</a>', 44);
    $('bottom-wire-label').textContent = gold.today ? 'TIN VÀNG HÔM NAY' : 'TIN VÀNG GẦN NHẤT';
  }

  function motionState() {
    const stopped = paused || reduced.matches;
    $('news-pause').textContent = stopped ? '▶ Tự chuyển' : 'Ⅱ Tạm dừng';
    $('news-pause').setAttribute('aria-pressed', String(stopped));
    $('news-pause').disabled = reduced.matches || items.length < 2;
    $('news-motion-hint').textContent = reduced.matches ? 'Đã giảm chuyển động · dùng nút Trước / Sau để đọc tin.' : paused ? 'Đang dừng tự chuyển · bạn có thể đọc từng tin.' : 'Tự chuyển mỗi 7 giây · dừng khi rê chuột hoặc đặt con trỏ vào ô tin.';
  }
  function setIndex(next, animate = true) {
    if (!items.length) return;
    const previous = index;
    index = (next + items.length) % items.length;
    const stage = $('news-stage'), height = stage.clientHeight;
    const wrap = animate && !reduced.matches && next === items.length && previous === items.length - 1;
    const singleStep = Math.abs(index - previous) === 1 || wrap;
    $('news-reel').dataset.wrap = String(wrap);
    $('news-reel').style.transition = animate && singleStep && !reduced.matches ? 'transform .65s cubic-bezier(.22,.68,.24,1)' : 'none';
    $('news-reel').style.transform = `translateY(-${(wrap ? items.length : index) * height}px)`;
    [...$('news-reel').children].forEach((node, i) => { node.inert = i !== index; node.setAttribute('aria-hidden', String(i !== index)); });
    $('news-position').textContent = `${String(index + 1).padStart(2, '0')} / ${String(items.length).padStart(2, '0')}`;
    $('news-progress').style.width = `${(index + 1) / items.length * 100}%`;
    for (const node of document.querySelectorAll('[data-news-index]')) {
      const active = Number(node.dataset.newsIndex) === index;
      node.classList.toggle('selected', active); node.setAttribute('aria-pressed', String(active));
      const queue = $('news-queue');
      if (active && node.offsetTop < queue.scrollTop) queue.scrollTop = node.offsetTop;
      else if (active && node.offsetTop + node.offsetHeight > queue.scrollTop + queue.clientHeight) queue.scrollTop = node.offsetTop + node.offsetHeight - queue.clientHeight;
    }
  }
  function renderNews(force = false) {
    if ((focusHeld || hoverHeld) && !force) { pending = data; return; }
    const selection = selectNews(data?.items || [], topic);
    const nextSignature = JSON.stringify([topic, vietnamDay(Date.now()), selection.today, selection.rows, data?.sources]);
    if (nextSignature === signature && !force) return;
    signature = nextSignature;
    const activeId = items[index]?.id;
    items = selection.rows;
    index = Math.max(0, items.findIndex(item => item.id === activeId));
    const source = data?.sources?.find(row => row.topic === topic);
    $('news-scope').textContent = selection.today ? `${selection.today} TIN HÔM NAY · GIỜ VIỆT NAM` : items.length ? 'TIN GẦN NHẤT · CHƯA CÓ TIN HÔM NAY' : 'CHỜ BẢN TIN TỪ NGUỒN';
    $('news-source-state').textContent = source ? `${source.name} · ${source.status === 'ok' ? 'đã kiểm tra ' : source.status === 'stale' ? 'bản lưu · kiểm tra thành công ' : 'tạm mất kết nối'}${source.fetchedAt ? clock(source.fetchedAt) : ''}` : busy ? 'Đang kết nối nguồn RSS…' : 'Chưa kết nối được RSS · bấm Làm mới tin';
    $('news-reel').innerHTML = items.map((item, i) => `<article class="news-story" style="--story-index:${i}" ${i !== index ? 'inert aria-hidden="true"' : 'aria-hidden="false"'}><div class="story-meta"><span class="story-category">${topic === 'gold' ? 'VÀNG & KIM LOẠI QUÝ' : 'FED & LÃI SUẤT'}</span><time datetime="${escapeHtml(item.publishedAt)}">${clock(item.publishedAt)}</time>${item.status === 'stale' ? '<span class="tag neutral">Bản lưu</span>' : ''}</div><a class="story-title" href="${escapeHtml(item.url)}" target="_blank" rel="noopener noreferrer">${escapeHtml(item.title)}<span aria-hidden="true"> ↗</span></a><div class="story-byline"><span class="story-source-mark">${topic === 'gold' ? 'V' : 'F'}</span><span>${escapeHtml(item.source)}<small>Tiêu đề từ RSS · đọc bài đầy đủ tại nguồn</small></span></div></article>`).join('');
    // One extra inert slide keeps the last-to-first movement to a single upward step.
    if (items.length > 1) {
      const clone = $('news-reel').firstElementChild.cloneNode(true);
      clone.inert = true; clone.setAttribute('aria-hidden', 'true'); $('news-reel').appendChild(clone);
    }
    $('news-empty').hidden = items.length > 0;
    $('news-stage').hidden = !items.length;
    $('news-position').textContent = items.length ? '' : '00 / 00';
    $('news-progress').style.width = items.length ? '' : '0%';
    $('news-queue').innerHTML = items.map((item, i) => `<button class="news-queue-item" data-news-index="${i}" aria-pressed="false"><time>${clock(item.publishedAt)}</time><span>${escapeHtml(item.title)}</span><b>↗</b></button>`).join('') || '<p class="muted">Bản tin sẽ xuất hiện khi nguồn RSS phản hồi.</p>';
    for (const id of ['news-prev', 'news-next', 'news-pause']) $(id).disabled = items.length < 2 || (id === 'news-pause' && reduced.matches);
    $('news-empty').textContent = source?.status === 'unavailable' ? 'Nguồn RSS đang tạm gián đoạn. Bấm Làm mới tin để thử lại.' : 'Chưa có bản tin phù hợp từ nguồn. Bạn có thể mở trang RSS bên dưới.';
    setIndex(index, false); motionState();
    renderBottom();
  }
  function validNews(value) {
    if (!Array.isArray(value?.items) || !Array.isArray(value?.sources)) return false;
    value.items = value.items.filter(item => {
      try {
        const url = new URL(item.url);
        const hosts = item.sourceId === 'vietstock-gold' ? ['vietstock.vn', 'www.vietstock.vn'] : item.sourceId === 'fed-policy' ? ['federalreserve.gov', 'www.federalreserve.gov'] : [];
        return url.protocol === 'https:' && hosts.includes(url.hostname) && !url.username && !url.password && typeof item.title === 'string' && Number.isFinite(Date.parse(item.publishedAt));
      } catch { return false; }
    });
    return true;
  }
  async function refreshNews() {
    if (busy) return;
    busy = true; $('news-refresh').disabled = true;
    try {
      const response = await fetch('/api/news', { cache: 'no-store', signal: AbortSignal.timeout(15000) });
      if (!response.ok) throw new Error('News unavailable');
      const next = await response.json();
      if (!validNews(next)) throw new Error('Invalid news');
      // A failed provider must not discard the last usable headlines from that provider.
      for (const source of next.sources) if (source.status === 'unavailable') {
        const previous = data?.sources.find(row => row.id === source.id);
        const cached = (data?.items || []).filter(item => item.sourceId === source.id && Date.now() - Date.parse(item.checkedAt) < 86400000);
        if (cached.length) { Object.assign(source, previous, { status: 'stale' }); next.items.push(...cached.map(item => ({ ...item, status: 'stale' }))); }
      }
      data = next; lastSuccess = Date.now();
      try { localStorage.setItem('aurum-news-v1', JSON.stringify(data)); } catch {}
    } catch {
      if (data) { data.items.forEach(item => { item.status = 'stale'; }); data.sources.forEach(source => { source.status = 'stale'; }); }
      else $('news-source-state').textContent = 'Chưa kết nối được RSS · bấm Làm mới tin để thử lại';
    } finally { busy = false; $('news-refresh').disabled = false; renderNews(); }
  }
  $('news-prev').addEventListener('click', () => setIndex(index - 1));
  $('news-reel').addEventListener('transitionend', event => {
    if (event.target !== $('news-reel') || event.propertyName !== 'transform' || $('news-reel').dataset.wrap !== 'true') return;
    $('news-reel').dataset.wrap = 'false';
    $('news-reel').style.transition = 'none';
    $('news-reel').style.transform = `translateY(-${index * $('news-stage').clientHeight}px)`;
  });
  $('news-next').addEventListener('click', () => setIndex(index + 1));
  $('news-pause').addEventListener('click', () => { paused = !paused; motionState(); });
  $('news-refresh').addEventListener('click', refreshNews);
  $('news-queue').addEventListener('click', event => { const button = event.target.closest('[data-news-index]'); if (button) setIndex(Number(button.dataset.newsIndex)); });
  $('news-filters').addEventListener('click', event => {
    const button = event.target.closest('[data-news-topic]'); if (!button) return;
    topic = button.dataset.newsTopic; index = 0;
    $('news-filters').querySelectorAll('button').forEach(node => { node.classList.toggle('selected', node === button); node.setAttribute('aria-pressed', String(node === button)); });
    renderNews(true);
  });
  const flush = () => { if (!focusHeld && !hoverHeld && pending) { pending = null; renderNews(); } };
  card.addEventListener('pointerenter', event => { if (event.pointerType !== 'touch') hoverHeld = true; });
  card.addEventListener('pointerleave', () => { hoverHeld = false; flush(); });
  card.addEventListener('focusin', () => { focusHeld = true; });
  card.addEventListener('focusout', () => setTimeout(() => { focusHeld = card.contains(document.activeElement); flush(); }, 0));
  reduced.addEventListener('change', motionState);
  new ResizeObserver(() => setIndex(index, false)).observe($('news-stage'));
  setInterval(() => { if (!document.hidden && !paused && !reduced.matches && !hoverHeld && !focusHeld && items.length > 1) setIndex(index + 1); }, 7000);
  setInterval(() => { if (!document.hidden) refreshNews(); }, 300000);
  document.addEventListener('visibilitychange', () => { if (!document.hidden && Date.now() - lastSuccess > 300000) refreshNews(); });
  window.addEventListener('online', refreshNews);
  try {
    const cached = JSON.parse(localStorage.getItem('aurum-news-v1'));
    if (validNews(cached)) {
      cached.items = cached.items.filter(item => Date.now() - Date.parse(item.checkedAt) < 86400000).map(item => ({ ...item, status: 'stale' }));
      cached.sources.forEach(source => { source.status = 'stale'; }); data = cached;
    }
  } catch {}
  renderNews(); refreshNews();
  return { updateMarket, refreshNews, newsSources: () => data?.sources || [] };
}
