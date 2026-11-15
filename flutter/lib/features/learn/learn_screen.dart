import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/orange_mascot.dart';
import '../books/bookshelf_screen.dart';
import 'chapter_learn_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final current = state.currentChapter;
    return Scaffold(
      appBar: AppBar(title: const Text('学习')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _bookshelfBanner(context),
            const SizedBox(height: 12),
            _focusBanner(),
            const SizedBox(height: 18),
            if (current != null) _continueCard(context, state, current),
            const SizedBox(height: 18),
            const Text('全部章节',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink)),
            const SizedBox(height: 10),
            ...state.chapters.map((c) {
              final unlocked = state.isChapterUnlocked(c);
              final passed = state.passedChapters.contains(c.id);
              final color = Color(c.colorValue);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  leading: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? color.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(unlocked ? c.coverEmoji : '🔒',
                        style: const TextStyle(fontSize: 22)),
                  ),
                  title: Text('Lv${c.level} · ${c.title}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  subtitle: Text(
                    passed ? '已通关 ✓' : c.subtitle,
                    style: TextStyle(
                        color: passed
                            ? AppTheme.success
                            : AppTheme.ink2,
                        fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppTheme.primary),
                  onTap: unlocked
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ChapterLearnScreen(chapter: c)))
                      : () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('通关上一章后解锁哦'),
                            backgroundColor: AppTheme.primary,
                          )),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _bookshelfBanner(BuildContext context) {
    final state = context.watch<AppState>();
    return Material(
      color: const Color(0xFFFFEBDC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BookshelfScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('📚', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('经典书架',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.ink)),
                    const SizedBox(height: 2),
                    Text('${state.totalBooks} 本投资经典 · 股票 / 金融市场 / 量化 / 期货',
                        style: const TextStyle(
                            color: AppTheme.primaryDark, fontSize: 12)),
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

  Widget _focusBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🧭', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('本轮强化重点',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink)),
                SizedBox(height: 4),
                Text(
                  '股票与金融市场打基础，量化与期货做进阶，策略研究、回测、风控与交易心理做完整闭环。',
                  style: TextStyle(
                      fontSize: 12, height: 1.6, color: AppTheme.ink2),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

    final passed = state.passedChapters.contains(current.id);
    final color = Color(current.colorValue);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const OrangeMascot(size: 64, mood: MascotMood.think),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(passed ? '全部章节已通关！' : '继续你的学习',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  passed ? '随时复习任意章节' : current.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                    passed
                        ? '你已经完成从市场基础到量化与风控的整条入门路径'
                        : '${current.subtitle} · 当前章节已强化量化、期货与策略研究内容',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryDark,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                ChapterLearnScreen(chapter: current))),
                    child: Text(passed ? '复习第 1 章' : '开始学习 →'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
