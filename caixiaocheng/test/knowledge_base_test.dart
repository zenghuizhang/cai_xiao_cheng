// 校验 assets 中的课程 JSON 结构，确保首启灌库不会出问题。
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> data;

  setUpAll(() {
    final f = File('assets/data/knowledge_base.json');
    data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  });

  test('顶层包含全部 8 个数据段', () {
    for (final k in [
      'meta',
      'chapters',
      'cards',
      'quizzes',
      'simulations',
      'glossary',
      'daily_challenges',
      'fruits',
      'books',
    ]) {
      expect(data.containsKey(k), true, reason: '缺少 $k');
    }
  });

  test('4 个章节，解锁链 C1→C2→C3→C4', () {
    final chapters = data['chapters'] as List;
    expect(chapters.length, 4);
    expect(chapters[0]['id'], 'C1');
    expect(chapters[0]['unlock_type'], 'none');
    for (int i = 1; i < 4; i++) {
      expect(chapters[i]['unlock_type'], 'prev_chapter');
      expect(chapters[i]['unlock_ref'], chapters[i - 1]['id']);
    }
  });

  test('卡片规模达标、分布合理、每张带生活类比', () {
    final cards = data['cards'] as List;
    expect(cards.length, greaterThanOrEqualTo(80));
    final counts = {1: 0, 2: 0, 3: 0, 4: 0};
    final ids = <String>{};
    for (final c in cards) {
      counts[c['chapter'] as int] = counts[c['chapter']]! + 1;
      ids.add(c['id'] as String);
      expect((c['daily_analogy'] as String).isNotEmpty, true,
          reason: '${c['id']} 缺 daily_analogy');
      expect((c['core_knowledge'] as String).isNotEmpty, true);
      expect(c['glossary_terms'], isA<List>());
      expect(c['points'], greaterThan(0));
    }
    for (final n in counts.values) {
      expect(n, greaterThanOrEqualTo(15), reason: '每章至少 15 张卡');
    }
    expect(ids.length, cards.length, reason: '卡片 id 不能重复');
  });

  test('题目数量达标、答案索引合法、对错文案存在', () {
    final quizzes = data['quizzes'] as List;
    final byChapter = <String, int>{};
    for (final q in quizzes) {
      byChapter[q['chapter_id'] as String] =
          (byChapter[q['chapter_id']] ?? 0) + 1;
      final opts = q['options'] as List;
      expect(opts.length >= 2, true);
      final ai = q['answer_index'] as int;
      expect(ai >= 0 && ai < opts.length, true,
          reason: '${q['id']} answer_index 越界');
      expect((q['right_reply'] as String?)?.isNotEmpty ?? false, true);
      expect((q['wrong_reply'] as String?)?.isNotEmpty ?? false, true);
    }
    for (final n in byChapter.values) {
      expect(n, greaterThanOrEqualTo(5), reason: '每章至少 5 道题');
    }
  });

  test('模拟场景 ≥6 个，每个 3 个选项且字段齐全', () {
    final sims = data['simulations'] as List;
    expect(sims.length, greaterThanOrEqualTo(6));
    for (final s in sims) {
      final opts = s['options'] as List;
      expect(opts.length, 3);
      for (final o in opts) {
        expect(o.containsKey('key'), true);
        expect(o.containsKey('outcome'), true);
        expect(o.containsKey('pnl_pct'), true);
        expect(o.containsKey('emoji'), true);
        expect(o.containsKey('takeaway'), true);
      }
    }
  });

  test('词条 ≥20，one_line 均不超过 20 个字符', () {
    final g = data['glossary'] as List;
    expect(g.length, greaterThanOrEqualTo(20));
    for (final t in g) {
      final one = t['one_line'] as String;
      expect(one.isNotEmpty, true);
      expect(one.length <= 20, true,
          reason: '${t['term']} 的 one_line 超 20 字: $one');
    }
  });

  test('每日判断题 ≥7 道且 answer 是布尔', () {
    final d = data['daily_challenges'] as List;
    expect(d.length, greaterThanOrEqualTo(7));
    for (final q in d) {
      expect(q['answer'], isA<bool>());
    }
  });

  test('4 个果实对应 4 章', () {
    final f = data['fruits'] as List;
    expect(f.length, 4);
    final chapters = (data['chapters'] as List).map((c) => c['id']).toSet();
    for (final fruit in f) {
      expect(chapters.contains(fruit['chapter_id']), true);
    }
  });

  test('【交叉引用】卡片术语 100% 可查（复刻 UI matches 逻辑）', () {
    final cards = data['cards'] as List;
    final gloss = data['glossary'] as List;
    final unreachable = <String>[];
    for (final c in cards) {
      for (final t in (c['glossary_terms'] as List)) {
        final kw = (t as String).toLowerCase();
        final hit = gloss.any((g) {
          if (kw.contains((g['term'] as String).toLowerCase())) return true;
          return (g['aliases'] as List? ?? const [])
              .any((a) => kw.contains((a as String).toLowerCase()));
        });
        if (!hit) unreachable.add('${c['id']} → $t');
      }
    }
    expect(unreachable, isEmpty,
        reason: '以下术语在词条库查不到（会触发「没找到」空态）: $unreachable');
  });

  test('【交叉引用】卡片→题目引用全部有效，无孤儿题目', () {
    final cards = data['cards'] as List;
    final quizzes = data['quizzes'] as List;
    final quizIds = quizzes.map((q) => q['id'] as String).toSet();
    final cardQuizRefs = cards
        .map((c) => c['related_quiz_id'] as String?)
        .whereType<String>()
        .toSet();
    for (final ref in cardQuizRefs) {
      expect(quizIds.contains(ref), true, reason: '卡片引用了不存在的题目 $ref');
    }
    for (final q in quizzes) {
      expect(cardQuizRefs.contains(q['id'] as String), true,
          reason: '题目 ${q['id']} 没有被任何卡片引用（孤儿题）');
    }
  });

  test('【交叉引用】模拟/果实/书籍引用的章节均合法', () {
    final chapters = (data['chapters'] as List).map((c) => c['id']).toSet();
    for (final s in (data['simulations'] as List)) {
      expect(chapters.contains(s['chapter_id']), true);
    }
    for (final b in (data['books'] as List)) {
      for (final ref in (b['related_chapters'] as List? ?? const [])) {
        expect(chapters.contains(ref), true,
            reason: '${b['id']} 引用了不存在的章节 $ref');
      }
    }
  });

  test('【内容质量】词条无重复、类比非空、无占位符', () {
    final gloss = data['glossary'] as List;
    final terms = gloss.map((g) => g['term'] as String).toList();
    expect(terms.toSet().length, terms.length, reason: '词条 term 重复');
    for (final g in gloss) {
      expect((g['daily_analogy'] as String? ?? '').isNotEmpty, true,
          reason: '${g['term']} 缺 daily_analogy');
      final combined =
          '${g['one_line']} ${g['daily_analogy']}'.toLowerCase();
      for (final ph in ['todo', '待补充', 'placeholder', 'xxx']) {
        expect(combined.contains(ph), false,
            reason: '${g['term']} 含占位符 $ph');
      }
    }
  });

  test('风险测评题库：5 题、每题 3 选项、score 合法、无占位符', () {
    final rq = data['risk_quiz'] as List;
    expect(rq.length, 5);
    for (final q in rq) {
      final opts = q['options'] as List;
      expect(opts.length, 3, reason: '${q['id']} 应为 3 选项');
      for (final o in opts) {
        expect(o['score'], isA<int>(), reason: '${q['id']} 选项缺 score');
        expect(o['score'] >= 0 && o['score'] <= 4, true);
        final text = o['text'] as String;
        expect(text.isNotEmpty, true);
        expect(text.toLowerCase().contains('todo'), false);
      }
      expect((q['question'] as String).isNotEmpty, true);
    }
  });

  test('经典书架：≥10 本，字段齐全，含作者与正版提示', () {
    final books = data['books'] as List;
    expect(books.length, greaterThanOrEqualTo(10));
    final ids = <String>{};
    for (final b in books) {
      ids.add(b['id'] as String);
      for (final k in [
        'title',
        'author',
        'level',
        'one_line',
        'why_read',
        'for_whom',
        'read_path'
      ]) {
        expect((b[k]?.toString() ?? '').isNotEmpty, true,
            reason: '${b['id']} 缺 $k');
      }
      final ideas = b['core_ideas'] as List;
      expect(ideas.length, greaterThanOrEqualTo(3));
      for (final idea in ideas) {
        expect((idea['idea'] as String).isNotEmpty, true);
        expect((idea['explain'] as String).isNotEmpty, true);
      }
      expect((b['takeaways'] as List).length, greaterThanOrEqualTo(3));
      expect(b['level'], inInclusiveRange(1, 3));
      expect((b['one_line'] as String).length <= 20, true);
    }
    expect(ids.length, books.length, reason: '书籍 id 不能重复');
    expect((data['books_note'] as String?)?.isNotEmpty, true);
  });
}
