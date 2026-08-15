/**
 * 数值/货币格式化工具。
 * 虚拟金额仅用于认知展示，非真实货币。
 */

/** 千分位格式化整数部分，保留指定小数位。 */
export function formatNumber(v, decimals = 0) {
  if (v == null || isNaN(v)) return '0'
  const fixed = Number(v).toFixed(decimals)
  const [intPart, decPart] = fixed.split('.')
  const grouped = intPart.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  return decPart ? `${grouped}.${decPart}` : grouped
}

/** 元货币格式：1,234,567 元。 */
export function formatYuan(v, decimals = 0) {
  return `${formatNumber(v, decimals)} 元`
}

/**
 * 中文大额缩写：≥1万 用「x.xx万」，≥1亿 用「x.xx亿」。
 * 用于虚拟资产、累计本金等大数字的紧凑展示。
 */
export function formatWan(v) {
  if (v == null || isNaN(v)) return '0'
  const n = Number(v)
  if (Math.abs(n) >= 1e8) return `${round2Str(n / 1e8)} 亿`
  if (Math.abs(n) >= 1e4) return `${round2Str(n / 1e4)} 万`
  return formatNumber(n, 0)
}

/** 百分比格式：8.3% / -12.4%。 */
export function formatPercent(v, decimals = 1) {
  if (v == null || isNaN(v)) return '0%'
  const s = Number(v) > 0 ? '+' : ''
  return `${s}${Number(v).toFixed(decimals)}%`
}

/** 紧凑两位小数（去尾部多余零）。 */
function round2Str(v) {
  return (Math.round(v * 100) / 100).toString()
}

/** 带正负号的金额（盈亏展示）：+1,234 / -560。 */
export function formatSigned(v, decimals = 0) {
  if (v == null || isNaN(v)) return '0'
  const s = Number(v) > 0 ? '+' : ''
  return `${s}${formatNumber(v, decimals)}`
}

export default {
  formatNumber,
  formatYuan,
  formatWan,
  formatPercent,
  formatSigned,
}
