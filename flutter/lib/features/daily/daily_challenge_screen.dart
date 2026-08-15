import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/db/database_helper.dart';
import '../../providers/app_state.dart';
import '../../data/models/daily_challenge.dart';
import '../../widgets/orange_mascot.dart';

/// 每日 3 分钟早餐挑战：3 道判断题，连签有积分奖励。
/// 题目来自本地 SQLite（由 assets/data/knowledge_base.json 预置），
/// 按当天日期固定取 3 道，保证同一天反复进入题目一致。
class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final _db = DatabaseHelper.instance;
  List<DailyChallenge> _questions = [];
  int _i = 0;
  int _correct = 0;
  bool? _picked; // 用户本道题的选择（true=对 / false=错）
  bool _loading = true;
  bool _finished = false;
  bool _alreadyDone = false;
  int _earned = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = await _db.isDailyDoneToday();
    final all = await _db.getDailyChallenges();
    // 用“一年中的第几天”作为当日种子，从题库里轮转取 3 道，保证每天不同、当天固定。
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    all.shuffle(Random(dayOfYear));
    final picked = all.take(3).toList();
    setState(() {
      _alreadyDone = done;
      _questions = picked;
      _loading = false;
    });
  }

  void _choose(bool answer) {
    if (_picked != null) return;
    final q = _questions[_i];
    final right = answer == q.answer;
    setState(() {
      _picked = answer;
      if (right) _correct++;
    });
  }

  Future<void> _next() async {
    if (_i < _questions.length - 1) {
      setState(() {
        _i++;
        _picked = null;
      });
    } else {
      final result = await context
          .read<AppState>()
          .recordDaily(_correct, _questions.length);
      setState(() {
        _finished = true;
        _earned = result.$1;
        _streak = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('每日早餐挑战')),
      body: SafeArea(
        child: _finished ? _result() : _question(),
      ),
    );
  }

  Widget _question() {
    final q = _questions[_i];
    final progress = (_i + (_picked != null ? 1 : 0)) / _questions.length;
    final isRight = _picked != null && _picked == q.answer;
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          backgroundColor: AppTheme.line,
          valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 4),
                  Text('第 ${_i + 1} / ${_questions.length} 题 · 判断对错',
                      style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 14),
              Text(q.question,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.6,
                      color: AppTheme.ink)),
              if (_alreadyDone) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warnSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '今天已经打过卡啦，这是复习模式，答题不再重复发积分～',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              _judgeButton(
                label: '✅ 这句话是对的',
                color: AppTheme.success,
                picked: _picked == true,
                revealCorrect: _picked != null && q.answer == true,
                onTap: () => _choose(true),
              ),
              const SizedBox(height: 12),
              _judgeButton(
                label: '❌ 这句话是错的',
                color: AppTheme.danger,
                picked: _picked == false,
                revealCorrect: _picked != null && q.answer == false,
                onTap: () => _choose(false),
              ),
              if (_picked != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRight ? AppTheme.greenSoft : AppTheme.warnSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          OrangeMascot(
                              size: 36,
                              mood: isRight
                                  ? MascotMood.celebrate
                                  : MascotMood.warn),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isRight
                                  ? '答对啦，这个观念很扎实！'
                                  : '哎呀，这是90%新手都会踩的坑哦，记住啦！',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isRight
                                    ? const Color(0xFF2E7D4F)
                                    : const Color(0xFFB4452F),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('💡 ${q.explanation}',
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.7,
                              color: AppTheme.ink)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_picked != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: ElevatedButton(
              onPressed: _next,
              child: Text(_i < _questions.length - 1 ? '下一题' : '领取今日奖励'),
            ),
          ),
      ],
    );
  }

  Widget _judgeButton({
    required String label,
    required Color color,
    required bool picked,
    required bool revealCorrect,
    required VoidCallback onTap,
  }) {
    Color bg = Colors.white;
    Border border = Border.all(color: AppTheme.line);
    if (picked) {
      bg = color.withOpacity(0.12);
      border = Border.all(color: color, width: 1.5);
    }
    if (_picked != null && revealCorrect && !picked) {
      // 揭示正确答案但不是用户选中的那个：勾个边
      border = Border.all(color: color, width: 1.5);
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _picked == null ? onTap : null,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: border,
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _picked != null && (picked || revealCorrect)
                      ? color
                      : AppTheme.ink)),
        ),
      ),
    );
  }

  Widget _result() {
    final allRight = _correct == _questions.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OrangeMascot(
                size: 120,
                mood: allRight ? MascotMood.celebrate : MascotMood.happy),
            const SizedBox(height: 16),
            Text(allRight ? '全对，厉害！' : '今天完成啦！',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink)),
            const SizedBox(height: 8),
            Text('答对 $_correct / ${_questions.length} 题',
                style: const TextStyle(fontSize: 16, color: AppTheme.ink2)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.warnSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text('连续打卡 $_streak 天 · +$_earned 积分',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '每天早餐时花 3 分钟，慢慢就把观念刻进脑子里了 🍊',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.ink2),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('收下奖励，回去学习'),
            ),
          ],
        ),
      ),
    );
  }
}
