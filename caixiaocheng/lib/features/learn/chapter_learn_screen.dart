import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/db/database_helper.dart';
import '../../providers/app_state.dart';
import '../../data/models/chapter.dart';
import '../../data/models/knowledge_card.dart';
import '../../widgets/circle_progress.dart';
import '../../widgets/orange_mascot.dart';
import '../../widgets/knowledge_swipe_card.dart';
import 'quiz_screen.dart';

class ChapterLearnScreen extends StatefulWidget {
  final Chapter chapter;
  const ChapterLearnScreen({super.key, required this.chapter});

  @override
  State<ChapterLearnScreen> createState() => _ChapterLearnScreenState();
}

class _ChapterLearnScreenState extends State<ChapterLearnScreen> {
  final _db = DatabaseHelper.instance;
  List<KnowledgeCard> _cards = [];
  int _index = 0;
  final Set<String> _readInSession = {};
  int _earned = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getCards(widget.chapter.id);
    setState(() {
      _cards = list;
      _loading = false;
    });
  }

  /// 右滑/懂了
  Future<void> _gotIt() async {
    if (_index >= _cards.length) return;
    final card = _cards[_index];
    final e = await context.read<AppState>().recordCard(card.id, 'got', card.points);
    _earned += e;
    _readInSession.add(card.id);
    _next();
  }

  /// 左滑/没懂
  Future<void> _review() async {
    if (_index >= _cards.length) return;
    final card = _cards[_index];
    await context.read<AppState>().recordCard(card.id, 'review', 0);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('已加入待复习，稍后再来看一遍 💪'),
      backgroundColor: AppTheme.primary,
      duration: Duration(seconds: 1),
    ));
    _next();
  }

  void _next() {
    setState(() => _index++);
    if (_index >= _cards.length) {
      // 已到末尾，触发弹窗引导测验
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final readCount = _readInSession.length;
    final progress = _cards.isEmpty ? 0.0 : readCount / _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.chapter.coverEmoji} ${widget.chapter.title}'),
      ),
      body: SafeArea(
        child: _index < _cards.length
            ? _cardFlow(readCount, progress)
            : _quizIntro(readCount),
      ),
    );
  }

  Widget _cardFlow(int readCount, double progress) {
    final card = _cards[_index];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              CircleProgress(progress: progress, size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('第 ${_index + 1} / ${_cards.length} 张',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(widget.chapter.subtitle,
                        style: const TextStyle(
                            color: AppTheme.ink2, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('右滑「懂了」+${card.points}积分 · 左滑「没懂」进复习',
                        style: const TextStyle(
                            color: AppTheme.primaryDark, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Dismissible(
              key: ValueKey(card.id),
              confirmDismiss: (dir) async {
                if (dir == DismissDirection.startToEnd) {
                  await _gotIt();
                } else {
                  await _review();
                }
                return true;
              },
              background: const SwipeBackground(right: true),
              secondaryBackground: const SwipeBackground(right: false),
              child: KnowledgeCardView(card: card),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _review,
                  icon: const Icon(Icons.replay, color: AppTheme.primaryDark),
                  label: const Text('没懂',
                      style: TextStyle(color: AppTheme.primaryDark)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _gotIt,
                  icon: const Icon(Icons.check),
                  label: Text('懂了 +${card.points}'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quizIntro(int readCount) {
    final passed = context.read<AppState>().passedChapters.contains(widget.chapter.id);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OrangeMascot(
              size: 110,
              mood: passed ? MascotMood.celebrate : MascotMood.happy),
          const SizedBox(height: 16),
          Text(passed ? '本章已通关，要复习一下吗？' : '本章卡片看完啦！',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink)),
          const SizedBox(height: 8),
          Text(
            passed
                ? '多看几遍，知识会更牢固 🍊'
                : '本章共 ${_cards.length} 张卡，本次新「懂了」$readCount 张${_earned > 0 ? '，获得 $_earned 积分' : ''}。\n接下来是 ${widget.chapter.requiredQuizCount} 道闯关题，答对 80% 就能解锁下一章！',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, height: 1.7, color: AppTheme.ink2),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(chapter: widget.chapter),
              ),
            ),
            icon: const Icon(Icons.flag_outlined),
            label: Text(passed ? '复习闯关测验' : '开始闯关测验'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('先回首页'),
          ),
        ],
      ),
    );
  }
}
