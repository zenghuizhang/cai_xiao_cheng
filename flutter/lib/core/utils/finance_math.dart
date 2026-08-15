import 'dart:math';

/// 金融计算工具类（纯本地、无网络）。
///
/// 所有结果均为【假设收益率下的数学推演】，不构成任何投资建议、不代表对未来的预测。
class FinanceMath {
  FinanceMath._();

  /// 复利终值（一次性本金）。
  ///
  /// 公式：FV = PV * (1 + r)^n
  ///   PV = 初始本金
  ///   r  = 期利率（这里是月利率 = 年化/12）
  ///   n  = 期数（月数）
  static double lumpSum({
    required double principal,
    required double annualRate,
    required int years,
  }) {
    final r = annualRate / 100 / 12;
    final n = years * 12;
    return principal * pow(1 + r, n);
  }

  /// 定投（普通年金）终值 —— 每月月末投入固定金额。
  ///
  /// 年金终值公式：
  ///   FV = PMT * [ ((1 + r)^n - 1) / r ]
  /// 其中：
  ///   PMT = 每月投入金额
  ///   r   = 月利率 = 年化收益率 / 12
  ///   n   = 总月数 = 年数 * 12
  ///
  /// 当 r == 0（年化 0%）时分母为 0，退化为简单求和 FV = PMT * n。
  static double dcaFutureValue({
    required double monthly,
    required double annualRate,
    required int years,
  }) {
    final r = annualRate / 100 / 12;
    final n = years * 12;
    if (r == 0) return monthly * n;
    return monthly * ((pow(1 + r, n) - 1) / r);
  }

  /// 定投 + 初始本金合并终值。
  static double totalFutureValue({
    required double principal,
    required double monthly,
    required double annualRate,
    required int years,
  }) {
    return lumpSum(
          principal: principal,
          annualRate: annualRate,
          years: years,
        ) +
        dcaFutureValue(
          monthly: monthly,
          annualRate: annualRate,
          years: years,
        );
  }

  /// 生成分月/分年序列，供收益曲线展示。
  /// 返回每年年末一条记录：(年, 总资产, 累计本金)。
  static List<YearPoint> dcaYearlySeries({
    required double principal,
    required double monthly,
    required double annualRate,
    required int years,
  }) {
    final r = annualRate / 100 / 12;
    final List<YearPoint> out = [];
    double balance = principal;
    double paidIn = principal;
    out.add(YearPoint(0, round2(balance), round2(paidIn)));
    for (int y = 1; y <= years; y++) {
      for (int m = 0; m < 12; m++) {
        // 先按现有余额计息，再投入当月定投（月末投入口径）
        balance = balance * (1 + r) + monthly;
        paidIn += monthly;
      }
      out.add(YearPoint(y, round2(balance), round2(paidIn)));
    }
    return out;
  }

  /// 通胀后的购买力：现在的 money 在 years 年后相当于今天多少钱。
  /// 实际购买力 = money / (1 + inflation)^years
  static double purchasingPower({
    required double money,
    required double inflation,
    required int years,
  }) {
    return money / pow(1 + inflation / 100, years);
  }

  /// 72 法则：资金翻倍约需年数 ≈ 72 / 年化收益率(%)。
  static double doubleYears(double annualRatePct) {
    if (annualRatePct <= 0) return double.infinity;
    return 72 / annualRatePct;
  }

  static double round2(double v) {
    if (v.isNaN || v.isInfinite) return 0;
    return (v * 100).roundToDouble() / 100;
  }
}

class YearPoint {
  final int year;
  final double total;
  final double principal;
  const YearPoint(this.year, this.total, this.principal);
  double get gain => total - principal;
}
