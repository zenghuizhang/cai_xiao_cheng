/**
 * 金融计算工具（纯本地、无网络）—— 移植自 Flutter FinanceMath。
 *
 * 所有结果均为【假设收益率下的数学推演】，
 * 不构成任何投资建议、不代表对未来的预测。
 */

/** 保留两位小数；NaN / Infinity 归零。 */
export function round2(v) {
  if (v == null || isNaN(v) || !isFinite(v)) return 0
  return Math.round(v * 100) / 100
}

/**
 * 复利终值（一次性本金）。
 * FV = PV * (1 + r)^n，r = 年化/12，n = 年数*12
 */
export function lumpSum({ principal, annualRate, years }) {
  const r = annualRate / 100 / 12
  const n = years * 12
  return principal * Math.pow(1 + r, n)
}

/**
 * 定投（普通年金）终值 —— 每月月末投入固定金额。
 * FV = PMT * [((1+r)^n - 1) / r]
 * r == 0（年化 0%）时退化为简单求和。
 */
export function dcaFutureValue({ monthly, annualRate, years }) {
  const r = annualRate / 100 / 12
  const n = years * 12
  if (r === 0) return monthly * n
  return monthly * ((Math.pow(1 + r, n) - 1) / r)
}

/** 定投 + 初始本金合并终值。 */
export function totalFutureValue({ principal, monthly, annualRate, years }) {
  return (
    lumpSum({ principal, annualRate, years }) +
    dcaFutureValue({ monthly, annualRate, years })
  )
}

/**
 * 生成逐年序列，供收益曲线展示。
 * 返回每年年末一条：{ year, total, principal, gain }
 * 口径：先按现有余额计息，再投入当月定投（月末投入）。
 */
export function dcaYearlySeries({ principal, monthly, annualRate, years }) {
  const r = annualRate / 100 / 12
  const out = []
  let balance = principal
  let paidIn = principal
  out.push({ year: 0, total: round2(balance), principal: round2(paidIn), gain: round2(balance - paidIn) })
  for (let y = 1; y <= years; y++) {
    for (let m = 0; m < 12; m++) {
      balance = balance * (1 + r) + monthly
      paidIn += monthly
    }
    out.push({
      year: y,
      total: round2(balance),
      principal: round2(paidIn),
      gain: round2(balance - paidIn),
    })
  }
  return out
}

/**
 * 通胀后的购买力：现在的 money 在 years 年后相当于今天多少钱。
 * 实际购买力 = money / (1 + inflation)^years
 */
export function purchasingPower({ money, inflation, years }) {
  return money / Math.pow(1 + inflation / 100, years)
}

/** 72 法则：资金翻倍约需年数 ≈ 72 / 年化收益率(%)。 */
export function doubleYears(annualRatePct) {
  if (annualRatePct <= 0) return Infinity
  return 72 / annualRatePct
}

export default {
  round2,
  lumpSum,
  dcaFutureValue,
  totalFutureValue,
  dcaYearlySeries,
  purchasingPower,
  doubleYears,
}
