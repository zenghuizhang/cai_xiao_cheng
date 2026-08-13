// 风险测评：5 题画像问卷（题库在 knowledge_base.json 的 risk_quiz 段）。
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class RiskQuizScreen extends StatefulWidget {
  const RiskQuizScreen({super.key});

  @override
  State<RiskQuizScreen> createState() => _RiskQuizScreenState();
}

enum _Phase { loading, quiz, result }

class _RiskQuizScreenState extends State<RiskQuizScreen> {
  _Phase _phase = _Phase.loading;
  List<Map<String, dynamic>> _questions = [];
  int _index = 0;
  int _score = 0;
  int? _selected;
  String _type = 'moderate';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/knowledge_base.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    setState(() {
      _questions = (data['risk_quiz'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
      _phase = _Phase.quiz;
    });
  }

  void _next() {
    setState(() {
      _score +=
          ((_questions[_index]['options'] as List)[_selected!] as Map)[
              'score'] as int;
      _index++;
      _selected = null;
      if (_index >= _questions.length) {
        _type = _score <= 6
            ? 'conservative'
            : (_score >= 14 ? 'aggressive' : 'moderate');
        _phase = _Phase.result;
      }
    });
  }

  Future<void> _retake() async {
    setState(() {
      _index = 0;
      _score = 0;
      _selected = null;
      _phase = _Phase.quiz;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Text(_phase == _Phase.result ? '我的风险画像' : '风险测评'),
      ),
      body: switch (_phase) {
        _Phase.loading =>
          const Center(child: CircularProgressIndicator()),
        _Phase.quiz => _quizBody(context),
        _Phase.result => _resultBody(context),
      },
    );
  }

  Widget _quizBody(BuildContext context) {
    final q = _questions[_index];
    final options = q['options'] as List;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('第 ${_index + 1} / ${_questions.length} 题',
                style: const TextStyle(
                    color: AppTheme.ink2,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.line),
              ),
              child: Text(q['question'] as String,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      height: 1.5)),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final o = options[i] as Map<String, dynamic>;
                  final sel = _selected == i;
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selected = i),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: sel ? AppTheme.primary : AppTheme.line,
                            width: sel ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              sel
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: sel
                                  ? AppTheme.primary
                                  : AppTheme.ink2,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(o['text'] as String,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: AppTheme.ink)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : (_index == _questions.length - 1 ? _finish : _next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                child: Text(_index == _questions.length - 1
                    ? '查看结果'
                    : '下一题'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    _next();
    await context.read<AppState>().saveRiskProfile(_type);
  }

  Widget _resultBody(BuildContext context) {
    final (emoji, name, desc) = AppState.riskProfileMeta(_type);
    final alloc = AppState.riskAllocation(_type);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 12),
            Text('你是「$name」',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink)),
            const SizedBox(height: 8),
            Text(desc,
                style: const TextStyle(fontSize: 14, color: AppTheme.ink2)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📋 建议配置（教学参考）',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark)),
                  const SizedBox(height: 8),
                  Text('股债配置：$alloc',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink)),
                  const SizedBox(height: 8),
                  const Text(
                      '这是基于你答题倾向给出的学习参考，呼应「100-年龄法则」。\n真实配置请结合收入、年龄与家庭情况，本结果不构成投资建议。',
                      style:
                          TextStyle(fontSize: 12, height: 1.7, color: AppTheme.ink2)),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _retake,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('再测一次',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                child: const Text('完成'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
