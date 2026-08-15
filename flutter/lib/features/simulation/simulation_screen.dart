// Flutter 的 physics 库也导出了一个名为 Simulation 的类（和我们的数据模型重名），
// 这里显式 hide 掉，避免 ambiguous_import。
import 'package:flutter/material.dart' hide Simulation;
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/db/database_helper.dart';
import '../../core/utils/finance_math.dart';
import '../../providers/app_state.dart';
import '../../data/models/simulation.dart';
import 'compound_calculator.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('模拟'),
          bottom: const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.ink2,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: '🎲 模拟人生'),
              Tab(text: '🧮 定投计算器'),
              Tab(text: '📈 复利计算器'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SimLifeList(),
            _Calculator(),
            CompoundCalculator(),
          ],
        ),
      ),
    );
  }
}

class _SimLifeList extends StatefulWidget {
  const _SimLifeList();
  @override
  State<_SimLifeList> createState() => _SimLifeListState();
}

class _SimLifeListState extends State<_SimLifeList> {
  final _db = DatabaseHelper.instance;
  List<Simulation> _sims = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _sims = await _db.getSimulations();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sims.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final s = _sims[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warnSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${s.eraYear} 年',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryDark)),
                    ),
                    const SizedBox(width: 8),
                    Text('初始 ¥${s.initialAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.ink2)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(s.title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink)),
                const SizedBox(height: 6),
                Text(s.background,
                    style: const TextStyle(
                        fontSize: 14, height: 1.7, color: AppTheme.ink2)),
                const SizedBox(height: 12),
                ...s.options.map((o) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _OptionButton(
                        sim: s,
                        option: o,
                        onAfter: () => context.read<AppState>().refresh(),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionButton extends StatefulWidget {
  final Simulation sim;
  final SimOption option;
  final VoidCallback onAfter;
  const _OptionButton(
      {required this.sim, required this.option, required this.onAfter});

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _revealed = false;
  bool _choseThis = false;
  int _earned = 0;

  Future<void> _tap() async {
    if (_revealed) return;
    _earned = await context.read<AppState>().recordSim(
        widget.sim.id, widget.option.key, widget.option.pnlPct);
    setState(() {
      _revealed = true;
      _choseThis = true;
    });
    widget.onAfter();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.option;
    final gain = o.pnlPct >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: _tap,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size.fromHeight(48),
            backgroundColor:
                _choseThis ? AppTheme.cream : null,
            side: BorderSide(
                color: _choseThis ? AppTheme.primary : AppTheme.line,
                width: _choseThis ? 1.5 : 1),
          ),
          child: Text('${o.key}. ${o.text}',
              style: const TextStyle(
                  color: AppTheme.ink, fontWeight: FontWeight.w600)),
        ),
        if (_revealed && _choseThis) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: gain ? AppTheme.greenSoft : const Color(0xFFFDECEA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(o.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Text(
                      gain
                          ? '假设收益 ${o.pnlPct.toStringAsFixed(1)}%'
                          : '假设收益 ${o.pnlPct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: gain
                            ? const Color(0xFF2E7D4F)
                            : const Color(0xFFB4452F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(o.outcome,
                    style: const TextStyle(
                        fontSize: 14, height: 1.7, color: AppTheme.ink)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🍊 '),
                      Expanded(
                        child: Text(o.takeaway,
                            style: const TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryDark)),
                      ),
                    ],
                  ),
                ),
                if (_earned > 0) ...[
                  const SizedBox(height: 8),
                  Text('+$_earned 积分（首次体验奖励）',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 6),
                const Text(
                  '※ 以上为假设性教学场景，不构成任何投资建议。',
                  style: TextStyle(fontSize: 11, color: AppTheme.ink2),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 定投计算器：滑块输入，本地纯 Dart 计算，含公式说明。
class _Calculator extends StatefulWidget {
  const _Calculator();
  @override
  State<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<_Calculator> {
  double _monthly = 1000;
  double _annual = 8;
  double _years = 5;

  @override
  Widget build(BuildContext context) {
    final monthly = _monthly.roundToDouble();
    final annual = _annual;
    final years = _years.round();

    // 定投终值（年末投入口径，见 FinanceMath 文档注释）
    final fv = FinanceMath.dcaFutureValue(
        monthly: monthly, annualRate: annual, years: years);
    final paidIn = monthly * years * 12;
    final gain = fv - paidIn;
    final series = FinanceMath.dcaYearlySeries(
        principal: 0, monthly: monthly, annualRate: annual, years: years);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
              Text('$years 年后预计总额',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fv),
                duration: const Duration(milliseconds: 500),
                builder: (_, v, __) => Text(
                  '¥${v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '累计投入 ¥${paidIn.round()} · 收益 ¥${gain.round()}',
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
                  label: '每月投入',
                  value: _monthly,
                  min: 100,
                  max: 10000,
                  divisions: 99,
                  suffix: '元',
                  onChanged: (v) => setState(() => _monthly = v),
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
                  label: '定投年数',
                  value: _years,
                  min: 1,
                  max: 40,
                  divisions: 39,
                  suffix: '年',
                  onChanged: (v) => setState(() => _years = v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📈 逐年增长',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: AppTheme.ink)),
                const SizedBox(height: 8),
                SizedBox(height: 140, child: _MiniChart(series: series)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legend(AppTheme.primary, '总额'),
                    const SizedBox(width: 16),
                    _legend(AppTheme.ink2, '累计本金'),
                  ],
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
                '定投终值 = 每月投入 × [((1+月利率)^月数 − 1) / 月利率]\n'
                '其中 月利率 = 年化收益率 ÷ 12，月数 = 年数 × 12。\n'
                '按月末投入、年化固定的理想模型计算。',
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

  Widget _legend(Color c, String t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: c),
        const SizedBox(width: 5),
        Text(t, style: const TextStyle(fontSize: 11, color: AppTheme.ink2)),
      ],
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<YearPoint> series;
  const _MiniChart({required this.series});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ChartPainter(series),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<YearPoint> series;
  _ChartPainter(this.series);

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final maxV = series.last.total;
    const minV = 0.0;
    final w = size.width;
    final h = size.height;
    double x(int i) =>
        series.length == 1 ? w / 2 : i * w / (series.length - 1);
    double y(double v) => h - (v - minV) / (maxV - minV) * h;

    // 本金线（灰）
    final principalPaint = Paint()
      ..color = AppTheme.ink2
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final principalPath = Path();
    for (int i = 0; i < series.length; i++) {
      final p = Offset(x(i), y(series[i].principal));
      i == 0 ? principalPath.moveTo(p.dx, p.dy) : principalPath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(principalPath, principalPaint);

    // 总额面积 + 线
    final totalPath = Path();
    for (int i = 0; i < series.length; i++) {
      final p = Offset(x(i), y(series[i].total));
      i == 0 ? totalPath.moveTo(p.dx, p.dy) : totalPath.lineTo(p.dx, p.dy);
    }
    final fillPath = Path.from(totalPath)
      ..lineTo(x(series.length - 1), h)
      ..lineTo(x(0), h)
      ..close();
    canvas.drawPath(
        fillPath, Paint()..color = AppTheme.primary.withOpacity(0.15));
    canvas.drawPath(
        totalPath,
        Paint()
          ..color = AppTheme.primary
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke);

    // 轴标签
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < series.length; i++) {
      if (series.length > 6 && i % 2 != 0 && i != series.length - 1) continue;
      tp.text = TextSpan(
          text: '${series[i].year}',
          style: const TextStyle(fontSize: 9, color: AppTheme.ink2));
      tp.layout();
      tp.paint(canvas, Offset(x(i) - tp.width / 2, h - 12));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.series != series;
}
