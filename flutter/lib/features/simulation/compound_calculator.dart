// 复利计算器：一次性投入复利终值 + 通胀购买力对照（纯本地计算）。
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/finance_math.dart';
import '../../providers/app_state.dart';

class CompoundCalculator extends StatefulWidget {
  const CompoundCalculator({super.key});

  @override
  State<CompoundCalculator> createState() => _CompoundCalculatorState();
}

class _CompoundCalculatorState extends State<CompoundCalculator> {
  double _principal = 100000;
  double _annual = 5;
  double _years = 20;
  static const double _inflation = 3; // 教学参考通胀率

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final principal = _principal.round();
    final annual = _annual;
    final years = _years.round();

    final fv = FinanceMath.lumpSum(
        principal: principal.toDouble(), annualRate: annual, years: years);
    final gain = fv - principal;
    final pp = FinanceMath.purchasingPower(
        money: fv, inflation: _inflation, years: years);
    final doubleYears = FinanceMath.doubleYears(annual);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.riskProfile != null) ...[
          _riskHint(state.riskProfile!),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Text('$years 年后复利终值',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fv),
                duration: const Duration(milliseconds: 500),
                builder: (_, v, __) => Text(
                  '¥${_fmt(v.round())}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '本金 ¥${_fmt(principal)} · 收益 ¥${_fmt(gain.round())}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _slider(
                  label: '一次性投入本金',
                  value: _principal,
                  min: 1000,
                  max: 1000000,
                  divisions: 999,
                  suffix: '元',
                  onChanged: (v) => setState(() => _principal = v),
                ),
                _slider(
                  label: '假设年化收益率',
                  value: _annual,
                  min: 0,
                  max: 15,
                  divisions: 30,
                  suffix: '%',
                  onChanged: (v) => setState(() => _annual = v),
                ),
                _slider(
                  label: '年数',
                  value: _years,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  suffix: '年',
                  onChanged: (v) => setState(() => _years = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 通胀对照：复利 vs 通胀赛跑
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warnSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💸 通胀在偷偷偷钱',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDark)),
              const SizedBox(height: 8),
              Text(
                '同样的钱放 20 年，物价按 $_inflation% 通胀上涨，'
                '$years 年后这笔钱的购买力约等于今天的\n'
                '¥${_fmt(pp.round())}',
                style: const TextStyle(
                    fontSize: 14, height: 1.7, color: Color(0xFF7A4A1F)),
              ),
              const SizedBox(height: 8),
              Text(
                '所以钱不能只躺着——至少要跑赢通胀，才叫没亏。',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚡ 72 法则',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 6),
                Text(
                  annual <= 0
                      ? '年化 0% 时钱不会翻倍，只会被通胀吃掉。'
                      : '按 $annual% 年化，本金约 ${doubleYears.toStringAsFixed(1)} 年翻倍。'
                          '72 ÷ 年化收益，就是翻倍年数。',
                  style: const TextStyle(
                      fontSize: 13, height: 1.7, color: AppTheme.ink2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.warnSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🧮 计算逻辑（本地、无网络）',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDark)),
              SizedBox(height: 6),
              Text(
                '复利终值 = 本金 × (1 + 月利率)^总月数\n'
                '购买力 = 终值 ÷ (1 + 通胀率)^年数\n'
                '按年化固定的理想模型计算。',
                style: TextStyle(
                    fontSize: 12, height: 1.7, color: Color(0xFF7A4A1F)),
              ),
              SizedBox(height: 6),
              Text(
                '⚠️ 年化收益率仅为假设，真实市场有涨有跌，结果不代表预测、不构成投资建议。',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riskHint(String type) {
    final (emoji, name, _) = AppState.riskProfileMeta(type);
    final alloc = AppState.riskAllocation(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('📋', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '你是$emoji「$name」：建议股债配置 $alloc（教学参考）',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D6B3D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    final display = suffix == '元'
        ? '${value.round()} 元'
        : suffix == '%'
            ? '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}%'
            : '${value.round()} 年';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppTheme.ink)),
            Text(display,
                style: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 17)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primary,
          inactiveColor: AppTheme.line,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _fmt(int v) =>
      v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
