import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/orange_mascot.dart';
import '../../widgets/glossary_sheet.dart';
import '../about/about_screen.dart';
import '../books/bookshelf_screen.dart';
import '../risk/risk_quiz_screen.dart';

/// 我的：虚拟认知本金、段位进度、市场暴跌演练、全部词条、重置与关于。
class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final assets = state.virtualAssets;
    final levelColor = AppTheme.levelColor[state.currentLevel] ?? AppTheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 虚拟认知本金
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [levelColor, levelColor.withOpacity(0.72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const OrangeMascot(size: 48, mood: MascotMood.happy),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.rankTitle,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900)),
                            Text('Lv${state.currentLevel} · 积分 ${state.totalPoints}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (state.riskProfile != null) ...[
                    const SizedBox(height: 12),
                    _riskChip(state.riskProfile!),
                  ],
                  const SizedBox(height: 16),
                  const Text('我的「认知本金」（纯虚拟，非真实货币）',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: assets.toDouble()),
                    duration: const Duration(milliseconds: 600),
                    builder: (_, v, __) => Text(
                      '¥${v.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '每学懂一点，认知本金就涨一点——真正值钱的是你脑子里的判断力。',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 成就统计
            Row(
              children: [
                _stat('已读卡片', '${state.cardsRead}/80'),
                const SizedBox(width: 10),
                _stat('通关章节', '${state.chaptersPassed}/4'),
                const SizedBox(width: 10),
                _stat('连续打卡', '${state.streak}天'),
              ],
            ),
            const SizedBox(height: 18),

            // 市场暴跌演练
            _CrashCard(used: state.crashUsed),
            const SizedBox(height: 18),

            const Text('工具箱',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink)),
            const SizedBox(height: 10),
            _toolTile(
              context,
              icon: Icons.fact_check_outlined,
              title: '风险测评',
              subtitle: state.riskProfile == null
                  ? '5 分钟了解自己的投资性格'
                  : '当前画像：${AppState.riskProfileMeta(state.riskProfile!).$2}（可重测）',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RiskQuizScreen())),
            ),
            _toolTile(
              context,
              icon: Icons.menu_book,
              title: '经典书架',
              subtitle: '16 本投资经典，大白话导读',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BookshelfScreen())),
            ),
            _toolTile(
              context,
              icon: Icons.menu_book_outlined,
              title: '全部词条（一句话读懂）',
              subtitle: '231 个金融词，用大白话讲给你听',
              onTap: () => GlossarySheet.open(context),
            ),
            _toolTile(
              context,
              icon: Icons.info_outline,
              title: '关于与免责声明',
              subtitle: '这是一个教学 App，不碰你的钱',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            _toolTile(
              context,
              icon: Icons.refresh,
              title: '重置学习进度',
              subtitle: '清空积分、通关与打卡记录（内容不会删）',
              danger: true,
              onTap: () => _confirmReset(context),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text('财小橙 · 慢慢来，比较快 🍊',
                  style: TextStyle(color: AppTheme.ink2, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _riskChip(String type) {
    final (emoji, name, desc) = AppState.riskProfileMeta(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$emoji $name · $desc',
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.line),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryDark)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppTheme.ink2)),
          ],
        ),
      ),
    );
  }

  Widget _toolTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      bool danger = false}) {
    final color = danger ? AppTheme.danger : AppTheme.primaryDark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.ink2),
        onTap: onTap,
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('重置学习进度？'),
        content: const Text('积分、通关章节、打卡记录都会清空，但已下载的课程内容还在。确定吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('再想想')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定重置',
                  style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppState>().reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('已重置，又是一个全新的开始 🌱'),
          backgroundColor: AppTheme.primary,
        ));
      }
    }
  }
}

/// 「市场暴跌演练」按钮：点一下虚拟本金 −20%，配上安抚文案。
/// 目的是让新手提前体验账面下跌的感受，建立“波动 ≠ 永久亏损”的认知。
class _CrashCard extends StatefulWidget {
  final bool used;
  const _CrashCard({required this.used});

  @override
  State<_CrashCard> createState() => _CrashCardState();
}

class _CrashCardState extends State<_CrashCard> {
  bool _used = false;

  @override
  void initState() {
    super.initState();
    _used = widget.used;
  }

  @override
  void didUpdateWidget(covariant _CrashCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 重置进度后，父级传入的 used 变了，同步本地状态
    if (oldWidget.used != widget.used) _used = widget.used;
  }

  Future<void> _crash() async {
    final first = await context.read<AppState>().markCrash();
    setState(() => _used = true);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Text('📉', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('市场突然暴跌 20%',
                style: TextStyle(
                    color: AppTheme.danger, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '你的虚拟认知本金，一夜之间少了五分之一。\n\n'
              '先深呼吸——这只是演练。真实世界里，市场下跌时人最容易做两件错事：'
              '恐慌割肉、或者再也不敢投资。',
              style: TextStyle(height: 1.7, fontSize: 14, color: AppTheme.ink),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.greenSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🍊 '),
                  Expanded(
                    child: Text(
                      '记住三件事：\n'
                      '1. 账面浮亏不是真亏，除非你在低位卖出；\n'
                      '2. 定投的人，下跌时同样的钱能买到更多份额；\n'
                      '3. 用 3–5 年用不到的闲钱投资，才睡得着觉。',
                      style: TextStyle(
                          height: 1.7,
                          fontSize: 13,
                          color: Color(0xFF2E7D4F),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            if (first) ...[
              const SizedBox(height: 10),
              const Text('（完成暴跌演练，去看看首页小树有什么变化～）',
                  style: TextStyle(fontSize: 11, color: AppTheme.ink2)),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('我记住了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('心理演练',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.danger,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              const Text('🔥 提前体验一次暴跌',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '真到市场大跌那天才慌就晚了。点一下红色按钮，'
            '感受“本金 −20%”是什么感觉，顺便学会正确的应对姿势。',
            style: TextStyle(fontSize: 13, height: 1.7, color: AppTheme.ink2),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _used ? null : _crash,
              icon: const Icon(Icons.trending_down),
              label: Text(_used ? '已体验过暴跌，你很冷静 ✓' : '模拟市场暴跌 −20%'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.danger.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
