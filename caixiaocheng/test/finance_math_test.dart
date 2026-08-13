// 单元测试：定投/复利/通胀等纯本地金融计算逻辑。
// 这些数字只是固定假设下的数学结果，不代表任何预测或投资建议。
import 'package:flutter_test/flutter_test.dart';
import 'package:caixiaocheng/core/utils/finance_math.dart';

void main() {
  group('定投终值（普通年金）', () {
    test('月投1000、年化8%、5年 ≈ 73,418（累计本金60,000）', () {
      final fv = FinanceMath.dcaFutureValue(
          monthly: 1000, annualRate: 8, years: 5);
      expect(fv, closeTo(73476.9, 100));
      // 累计本金
      expect(1000 * 5 * 12, 60000);
    });

    test('月投1000、年化8%、30年 ≈ 149万（时间+复利的威力）', () {
      final fv = FinanceMath.dcaFutureValue(
          monthly: 1000, annualRate: 8, years: 30);
      // 解析公式：PMT * [((1+r)^n - 1)/r] ≈ 1,490,359
      expect(fv, closeTo(1490359, 2000));
    });

    test('年化0%时退化为简单求和（分母为0的边界）', () {
      final fv = FinanceMath.dcaFutureValue(
          monthly: 500, annualRate: 0, years: 10);
      expect(fv, 500 * 12 * 10);
    });
  });

  group('一次性复利', () {
    test('10万元、年化5%、10年 ≈ 164,701', () {
      final fv = FinanceMath.lumpSum(
          principal: 100000, annualRate: 5, years: 10);
      expect(fv, closeTo(164701, 200));
    });
  });

  group('72法则 & 通胀购买力', () {
    test('72/8 ≈ 9年翻倍', () {
      expect(FinanceMath.doubleYears(8), closeTo(9, 0.1));
    });

    test('100元按3%通胀20年后购买力 ≈ 55.37元', () {
      final p = FinanceMath.purchasingPower(
          money: 100, inflation: 3, years: 20);
      expect(p, closeTo(55.37, 0.5));
    });
  });

  group('逐年序列', () {
    test('第0年=初始本金，末年与终值公式一致', () {
      final series = FinanceMath.dcaYearlySeries(
          principal: 0, monthly: 1000, annualRate: 8, years: 5);
      expect(series.first.year, 0);
      expect(series.first.total, 0);
      expect(series.last.year, 5);
      expect(series.last.total,
          closeTo(
              FinanceMath.dcaFutureValue(
                  monthly: 1000, annualRate: 8, years: 5),
              1));
      // 累计本金 = 月投 × 月数
      expect(series.last.principal, 1000 * 60);
    });
  });
}
