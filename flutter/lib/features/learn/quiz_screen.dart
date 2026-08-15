import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/db/database_helper.dart';
import '../../providers/app_state.dart';
import '../../data/models/chapter.dart';
import '../../data/models/quiz.dart';
import '../../widgets/orange_mascot.dart';

class QuizScreen extends StatefulWidget {
  final Chapter chapter;
  const QuizScreen({super.key, required this.chapter});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _db = DatabaseHelper.instance;
  List<Quiz> _quizzes = [];
  int _i = 0;
  int _correct = 0;
  int? _selected;
  bool _loading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _quizzes = await _db.getQuizzes(widget.chapter.id);
    setState(() => _loading = false);
  }

  void _choose(int idx) {
    if (_selected != null) return;
    setState(() {
      _selected = idx;
      if (idx == _quizzes[_i].answerIndex) _correct++;
    });
  }

  Future<void> _next() async {
    if (_i < _quizzes.length - 1) {
      setState(() {
        _i++;
        _selected = null;
      });
    } else {
      final passed = await context.read<AppState>().recordQuiz(
          widget.chapter.id, _correct, _quizzes.length);
      setState(() => _finished = true);
      if (passed) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('${widget.chapter.title} · 闯关')),
      body: SafeArea(child: _finished ? _result() : _question()),
    );
  }

  Widget _question() {
    final q = _quizzes[_i];
    final letters = ['A', 'B', 'C', 'D'];
    final progress = (_i + (_selected != null ? 1 : 0)) / _quizzes.length;

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
              Text('第 ${_i + 1} / ${_quizzes.length} 题',
                  style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const SizedBox(height: 10),
              Text(q.question,
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.5,
                      color: AppTheme.ink)),
              const SizedBox(height: 24),
              ...List.generate(q.options.length, (oi) {
                final isCorrect = oi == q.answerIndex;
                final isSelected = oi == _selected;
                Color? bg;
                Color border = AppTheme.line;
                Widget? trailing;
                if (_selected != null) {
                  if (isCorrect) {
                    bg = AppTheme.greenSoft;
                    border = AppTheme.success;
                    trailing = const Icon(Icons.check_circle,
                        color: AppTheme.success);
                  } else if (isSelected) {
                    bg = const Color(0xFFFDECEA);
                    border = AppTheme.danger;
                    trailing = const Icon(Icons.cancel,
                        color: AppTheme.danger);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: bg ?? Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _selected == null ? () => _choose(oi) : null,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selected != null && isCorrect
                                    ? AppTheme.success
                                    : (_selected != null && isSelected
                                        ? AppTheme.danger
                                        : AppTheme.cream),
                              ),
                              child: Text(letters[oi],
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _selected != null &&
                                              (isCorrect || isSelected)
                                          ? Colors.white
                                          : AppTheme.ink2)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(q.options[oi],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: AppTheme.ink)),
                            ),
                            if (trailing != null) trailing,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              if (_selected != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _selected == q.answerIndex
                        ? AppTheme.greenSoft
                        : AppTheme.warnSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          OrangeMascot(
                              size: 36,
                              mood: _selected == q.answerIndex
                                  ? MascotMood.celebrate
                                  : MascotMood.warn),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selected == q.answerIndex
                                  ? q.rightReply
                                  : q.wrongReply,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _selected == q.answerIndex
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
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: ElevatedButton(
              onPressed: _next,
              child: Text(_i < _quizzes.length - 1 ? '下一题' : '查看结果'),
            ),
          ),
      ],
    );
  }

  Widget _result() {
    final rate = _correct / _quizzes.length;
    final passed = rate >= widget.chapter.requiredCorrectRate;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OrangeMascot(
                size: 120,
                mood: passed ? MascotMood.celebrate : MascotMood.sad),
            const SizedBox(height: 16),
            Text(passed ? '闯关成功！' : '差一点点！',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink)),
            const SizedBox(height: 8),
            Text('答对 $_correct / ${_quizzes.length} 题',
                style:
                    const TextStyle(fontSize: 16, color: AppTheme.ink2)),
            const SizedBox(height: 10),
            Text(
              passed
                  ? (widget.chapter.id == 'C4'
                      ? '🎉 恭喜你完成全部认知进阶！你已经比90%的人更清醒了。'
                      : '下一章已解锁，小树又结出一个果实 🍊')
                  : '答对 ${(widget.chapter.requiredCorrectRate * 100).round()}% 才能解锁，没关系，看看解析再来一次！',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, height: 1.7, color: AppTheme.ink2),
            ),
            const SizedBox(height: 28),
            if (passed)
              ElevatedButton(
                onPressed: () => Navigator.popUntil(
                    context, (route) => route.isFirst),
                child: const Text('回到首页看小树长大'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _i = 0;
                    _correct = 0;
                    _selected = null;
                    _finished = false;
                  });
                },
                child: const Text('再试一次'),
              ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.popUntil(
                  context, (route) => route.isFirst),
              child: const Text('先回首页'),
            ),
          ],
        ),
      ),
    );
  }
}
