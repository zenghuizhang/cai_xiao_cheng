import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/orange_mascot.dart';
import '../../widgets/circle_progress.dart';
import '../learn/chapter_learn_screen.dart';
import '../learn/review_screen.dart';
import '../daily/daily_challenge_screen.dart';
import '../about/about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = state.totalCards == 0 ? 1 : state.totalCards;
    final progress = state.cardsRead / total;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _header(context, state),
            const SizedBox(height: 16),
            _rankCard(context, state, progress),
            const SizedBox(height: 18),
            _dailyBanner(context),
            const SizedBox(height: 14),
            if (state.reviewCount > 0) ...[
              _reviewBanner(context, state.reviewCount),
              const SizedBox(height: 18),
            ],
            _growthTree(context, state),
            const SizedBox(height: 18),
            const Text('学习路径',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink)),
            const SizedBox(height: 10),
            ...state.chapters.map((c) => _chapterTile(context, state, c)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              ),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('关于与免责声明'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppState state) {
    return Row(
      children: [
        const OrangeMascot(size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink)),
              const Text('今天也要慢慢来，比较快 🍊',
                  style: TextStyle(color: AppTheme.ink2, fontSize: 13)),
            ],
          ),
        ),
        CircleProgress(
            progress: state.totalPoints / 2000,
            size: 52,
            label: 'Lv${state.currentLevel}'),
      ],
    );
  }

  Widget _rankCard(BuildContext context, AppState state, double progress) {
    final color = AppTheme.levelColor[state.currentLevel] ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
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
              const Text('当前段位',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Text('积分 ${state.totalPoints}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Text(state.rankTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '已读 ${state.cardsRead} / ${state.totalCards} 张知识卡 · 通关 ${state.chaptersPassed} / 4 章',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _dailyBanner(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0DE),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DailyChallengeScreen())),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.local_fire_department,
                    color: Colors.white, size: 28),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('每日 3 分钟早餐挑战',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.ink)),
                    Text('3 道判断题，连签有奖励 🔥',
                        style: TextStyle(color: AppTheme.ink2, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewBanner(BuildContext context, int count) {
    return Material(
      color: const Color(0xFFFDEBD9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ReviewScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.warnSoft,
                child: const Icon(Icons.history_edu,
                    color: AppTheme.primaryDark, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('待复习 $count 张',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.ink)),
                    const Text('左滑没懂的卡片，再刷一遍更牢 🔁',
                        style:
                            TextStyle(color: AppTheme.ink2, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _growthTree(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌳 认知成长树',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink)),
              const Spacer(),
              Text('${state.unlockedFruits.length}/4 个果实',
                  style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _TreePainter(state)),
                ),
                ..._fruitPositions(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _fruitPositions(BuildContext context, AppState state) {
    const positions = [
      Offset(30, 28),
      Offset(100, 8),
      Offset(180, 28),
      Offset(250, 8),
    ];
    final fruitMeta = {
      'C1': ('🍊', '看懂通胀'),
      'C2': ('🥝', '分清工具'),
      'C3': ('🍋', '掌握定投'),
      'C4': ('🍎', '识破骗局'),
    };
    final widgets = <Widget>[];
    for (int i = 0; i < state.chapters.length; i++) {
      final c = state.chapters[i];
      final unlocked = state.unlockedFruits.contains(c.id);
      final pos = positions[i];
      widgets.add(Positioned(
        left: pos.dx,
        top: pos.dy,
        child: GestureDetector(
          onTap: unlocked
              ? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('果实「${fruitMeta[c.id]!.$2}」已收获！'),
                    backgroundColor: AppTheme.success,
                    duration: const Duration(seconds: 2),
                  ))
              : null,
          child: Column(
            children: [
              Text(unlocked ? fruitMeta[c.id]!.$1 : '🔒',
                  style: TextStyle(fontSize: unlocked ? 34 : 22)),
              if (unlocked)
                Text(fruitMeta[c.id]!.$2,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.ink2,
                        fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget _chapterTile(
      BuildContext context, AppState state, chapter) {
    final unlocked = state.isChapterUnlocked(chapter);
    final passed = state.passedChapters.contains(chapter.id);
    final color = Color(chapter.colorValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: unlocked ? Colors.white : const Color(0xFFF2EEE6),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: unlocked
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChapterLearnScreen(chapter: chapter)))
              : () => _lockedHint(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? color.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(unlocked ? chapter.coverEmoji : '🔒',
                      style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Lv${chapter.level} · ${chapter.title}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: unlocked ? AppTheme.ink : AppTheme.ink2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (passed)
                            const Icon(Icons.check_circle,
                                color: AppTheme.success, size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(chapter.subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.ink2)),
                      const SizedBox(height: 4),
                      Text(
                        passed
                            ? '已通关 · 可随时复习'
                            : (unlocked
                                ? '约 ${chapter.estimatedMinutes} 分钟 · ${chapter.requiredQuizCount} 道闯关题'
                                : '通关上一章后解锁'),
                        style: TextStyle(
                            fontSize: 11,
                            color: unlocked
                                ? AppTheme.primaryDark
                                : AppTheme.ink2),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: unlocked ? AppTheme.primary : AppTheme.ink2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _lockedHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('先通关上一章，这章就解锁啦，别急 🍊'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6) return '夜深了，早点休息';
    if (h < 11) return '早上好呀';
    if (h < 14) return '中午好';
    if (h < 18) return '下午好';
    return '晚上好';
  }
}

/// 成长树绘制：树干 + 四根树枝（对应 4 章），已通关的枝上结果实高亮。
class _TreePainter extends CustomPainter {
  final AppState state;
  _TreePainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final trunk = Paint()
      ..color = const Color(0xFFB98A5B)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final leafPaint = Paint()..color = const Color(0xFFCDE8C0);

    // 地面
    final ground = Paint()..color = const Color(0xFFF0E6D8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.height - 16, size.width, 16),
          const Radius.circular(8)),
      ground,
    );

    // 树干
    canvas.drawLine(
      Offset(size.width / 2, size.height - 16),
      Offset(size.width / 2, size.height - 70),
      trunk,
    );
    // 树冠（随通过章节数长大）
    final passed = state.chaptersPassed.clamp(0, 4);
    final canopyR = 26.0 + passed * 6.0;
    canvas.drawCircle(
        Offset(size.width / 2, size.height - 86), canopyR, leafPaint);

    // 四根树枝
    final branchPaint = Paint()
      ..color = const Color(0xFFB98A5B)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final branchEnds = [
      Offset(55, 48),
      Offset(125, 28),
      Offset(205, 48),
      Offset(275, 28),
    ];
    final base = Offset(size.width / 2, size.height - 70);
    for (int i = 0; i < branchEnds.length; i++) {
      final unlocked = i < passed;
      branchPaint.color =
          unlocked ? const Color(0xFF9F7347) : const Color(0xFFD8CBB8);
      canvas.drawLine(base, branchEnds[i], branchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) =>
      old.state.chaptersPassed != state.chaptersPassed;
}
