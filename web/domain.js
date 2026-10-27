export const OUNCE_GRAMS = 31.1034768;
export const LUONG_GRAMS = 37.5;
export function premium(goldUsd, usdVnd, domesticSell) {
  if (![goldUsd, usdVnd, domesticSell].every(x => Number.isFinite(x) && x > 0)) return null;
  const world = goldUsd * usdVnd * LUONG_GRAMS / OUNCE_GRAMS;
  return { world, amount: domesticSell - world, percent: (domesticSell / world - 1) * 100 };
}
export function projection({ income, percent, years, growth, sellPerChi, buyPerChi }) {
  const budget = income * percent / 100;
  const months = Math.round(years * 12);
  if (![income, percent, years, growth, sellPerChi, buyPerChi].every(Number.isFinite) || income < 0 || percent < 0 || percent > 100 || years <= 0 || years > 50 || growth <= -100 || sellPerChi <= 0 || buyPerChi <= 0) return null;
  const monthly = (1 + growth / 100) ** (1 / 12);
  let quantity = 0;
  const points = [];
  for (let month = 1; month <= months; month++) {
    const multiplier = monthly ** month;
    quantity += budget / (sellPerChi * multiplier);
    if (month % 12 === 0) points.push({ year: month / 12, value: quantity * buyPerChi * multiplier, invested: budget * month });
  }
  return { budget, months, quantity, monthlyQuantity: budget / sellPerChi, invested: budget * months, value: quantity * buyPerChi * monthly ** months, points };
}
export function vaultTotals(items, quotes) {
  let invested = 0, market = 0, quantity = 0, valuedCost = 0, valued = 0;
  for (const item of items) {
    invested += item.quantity * item.price;
    quantity += item.quantity;
    const quote = quotes.find(q => q.code === item.product);
    if (quote?.buy > 0) {
      market += item.quantity * quote.buy / 10;
      valuedCost += item.quantity * item.price;
      valued++;
    }
  }
  return { invested, market, quantity, valued, profit: market - valuedCost, complete: valued === items.length };
}
export function fresh(resource, now = Date.now(), maxSeconds = 1200) {
  if (!resource || resource.status !== 'ok') return false;
  const age = now - Date.parse(resource.updatedAt);
  return Number.isFinite(age) && age >= -60000 && age <= maxSeconds * 1000;
}
export function alertValue(alert, market) {
  if (alert.product === 'XAU') return fresh(market?.gold, Date.now(), 180) ? market.gold.price : null;
  if (!fresh(market?.domestic)) return null;
  const quote = market.domestic.quotes?.find(q => q.code === alert.product);
  return quote ? quote.sell / (alert.product === 'SJ9999' ? 10 : 1) : null;
}
export function parseVaultBackup(data) {
  if (data?.schemaVersion !== 1 || !Array.isArray(data.transactions) || data.transactions.length > 5000) throw new Error('Invalid backup');
  return data.transactions.map(item => {
    if (!item || typeof item.id !== 'string' || !item.id || item.id.length > 100 || typeof item.title !== 'string' || !item.title.trim() || item.title.length > 100 || !Number.isFinite(item.quantity) || item.quantity <= 0 || item.quantity > 1e6 || !Number.isFinite(item.price) || item.price <= 0 || item.price > 1e10 || !/^\d{4}-\d{2}-\d{2}$/.test(item.date) || !Number.isFinite(Date.parse(item.date))) throw new Error('Invalid transaction');
    return { id: item.id, title: item.title.trim(), product: typeof item.product === 'string' ? item.product : 'other', quantity: item.quantity, price: item.price, date: item.date };
  });
}
