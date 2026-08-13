// 复习队列：待复习知识卡卡片流，右滑「这次懂了」出队，左滑「再想想」留队。
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/database_helper.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/knowledge_card.dart';
import '../../providers/app_state.dart';
import '../../widgets/circle_progress.dart';
import '../../widgets/knowledge_swipe_card.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _db = DatabaseHelper.instance;
  List<KnowledgeCard> _cards = [];
  int _index = 0;
  int _mastered = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getReviewCards();
    setState(() {
      _cards = list;
      _loading = false;
    });
  }

  /// 右滑/懂了：移出队列 +5 积分
  Future<void> _gotIt() async {
    if (_index >= _cards.length) return;
    final card = _cards[_index];
    await context.read<AppState>().recordReview(card.id, mastered: true);
    _mastered++;
    _next();
  }

  /// 左滑/没懂：留在队列，下次再战
  Future<void> _again() async {
    if (_index >= _cards.length) return;
    final card = _cards[_index];
    await context.read<AppState>().recordReview(card.id, mastered: false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('没关系，再看一遍更牢 💪'),
      backgroundColor: AppTheme.primary,
      duration: Duration(seconds: 1),
    ));
    _next();
  }

  void _next() {
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(title: const Text('待复习')),
      body: SafeArea(
        child: _cards.isEmpty
            ? _emptyView()
            : _index < _cards.length
                ? _cardFlow()
                : _doneView(),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 14),
          const Text('全部掌握啦',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink)),
          const SizedBox(height: 8),
          const Text('没有待复习的卡片，去学点新知识吧',
              style: TextStyle(color: AppTheme.ink2, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('去学习',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _doneView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏁', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 14),
          Text('本轮复习完成',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.ink)),
          const SizedBox(height: 8),
          Text('共复习 ${_cards.length} 张，这次搞懂了 $_mastered 张',
              style: const TextStyle(color: AppTheme.ink2, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('完成',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _cardFlow() {
    final card = _cards[_index];
    final progress = _index / _cards.length;
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
                    Text('复习 ${_index + 1} / ${_cards.length} 张',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    const Text('右滑「这次懂了」+5 积分 · 左滑「再想想」',
                        style: TextStyle(
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
                  await _again();
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
                  onPressed: _again,
                  icon: const Icon(Icons.replay, color: AppTheme.primaryDark),
                  label: const Text('再想想',
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
                  label: const Text('这次懂了 +5'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
