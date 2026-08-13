import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../data/models/chapter.dart';
import '../../data/models/knowledge_card.dart';
import '../../data/models/quiz.dart';
import '../../data/models/simulation.dart';
import '../../data/models/glossary_term.dart';
import '../../data/models/daily_challenge.dart';
import '../../data/models/fruit.dart';
import '../../data/models/book.dart';

/// 本地 SQLite 封装。
/// - 内容表（chapters/cards/quizzes/simulations/glossary/...）在首启时由 assets JSON 灌入；
/// - 状态表（user_status/card_reads/...）记录用户学习进度；
/// - 通过 app_meta.content_version 判断是否需要重新灌库（换 JSON 即可更新内容）。
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'caixiaocheng.db';
  static const _dbVersion = 5;
  static const _contentVersion = '4';

  Database? _db;
  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, v) async {
        await _createSchema(db);
        await _seedFromAssets(db);
      },
      onUpgrade: (db, oldV, newV) async {
        // v1 -> v2：新增经典书架 books 表并灌入内容
        if (oldV < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS books (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              author TEXT,
              level INTEGER DEFAULT 1,
              cover_emoji TEXT,
              tags TEXT,
              one_line TEXT,
              why_read TEXT,
              core_ideas TEXT,
              takeaways TEXT,
              for_whom TEXT,
              read_path TEXT,
              related_chapters TEXT,
              sort_order INTEGER DEFAULT 0
            );
          ''');
        }
        // v2 -> v3：书架新增《持续买入》等书目，重新灌库即可
        // v3 -> v4：书架新增《滚雪球》，重新灌库即可
        if (oldV < 4) {
          final raw =
              await rootBundle.loadString('assets/data/knowledge_base.json');
          final data = jsonDecode(raw) as Map<String, dynamic>;
          await _seedBooks(db, data);
        }
        // v4 -> v5：user_status 新增引导完成/风险画像三列（老用户迁移）
        if (oldV < 5) {
          await db.execute(
              'ALTER TABLE user_status ADD COLUMN onboarding_done INTEGER DEFAULT 0');
          await db.execute(
              'ALTER TABLE user_status ADD COLUMN risk_profile TEXT');
          await db.execute(
              'ALTER TABLE user_status ADD COLUMN risk_taken_at TEXT');
        }
      },
    );
  }

  /// 灌入/更新经典书架内容（books 为只读内容表，用 replace 覆盖）。
  Future<void> _seedBooks(Database db, Map<String, dynamic> data) async {
    for (final j in (data['books'] as List? ?? const [])) {
      final b = Book.fromJson(j as Map<String, dynamic>);
      await db.insert('books', _bookRow(b, b.id),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    if (data['books_note'] != null) {
      await db.insert(
          'app_meta', {'key': 'books_note', 'value': data['books_note']},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Map<String, dynamic> _bookRow(Book b, String orderId) => {
        'id': b.id,
        'title': b.title,
        'author': b.author,
        'level': b.level,
        'cover_emoji': b.coverEmoji,
        'tags': jsonEncode(b.tags),
        'one_line': b.oneLine,
        'why_read': b.whyRead,
        'core_ideas': jsonEncode(b.coreIdeas
            .map((e) => {'idea': e.idea, 'explain': e.explain})
            .toList()),
        'takeaways': jsonEncode(b.takeaways),
        'for_whom': b.forWhom,
        'read_path': b.readPath,
        'related_chapters': jsonEncode(b.relatedChapters),
        'sort_order': int.tryParse(orderId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      };

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE chapters (
        id TEXT PRIMARY KEY,
        level INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT,
        description TEXT,
        cover_emoji TEXT,
        theme_color TEXT,
        unlock_type TEXT NOT NULL,
        unlock_ref TEXT,
        required_correct_rate REAL DEFAULT 0.8,
        required_quiz_count INTEGER DEFAULT 3,
        estimated_minutes INTEGER DEFAULT 10,
        rank_title TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        title TEXT NOT NULL,
        daily_analogy TEXT NOT NULL,
        core_knowledge TEXT NOT NULL,
        illustration_note TEXT,
        glossary_terms TEXT,
        points INTEGER DEFAULT 10,
        difficulty INTEGER DEFAULT 1,
        related_quiz_id TEXT
      );
    ''');
    await db.execute(
        'CREATE INDEX idx_cards_chapter ON cards(chapter_id, order_index);');

    await db.execute('''
      CREATE TABLE quizzes (
        id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        question TEXT NOT NULL,
        options TEXT NOT NULL,
        answer_index INTEGER NOT NULL,
        explanation TEXT,
        right_reply TEXT,
        wrong_reply TEXT,
        points INTEGER DEFAULT 20
      );
    ''');
    await db.execute(
        'CREATE INDEX idx_quizzes_chapter ON quizzes(chapter_id, order_index);');

    await db.execute('''
      CREATE TABLE simulations (
        id TEXT PRIMARY KEY,
        chapter_id TEXT,
        order_index INTEGER NOT NULL,
        title TEXT NOT NULL,
        background TEXT NOT NULL,
        era_year INTEGER,
        initial_amount REAL DEFAULT 100000,
        options TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE glossary (
        term TEXT PRIMARY KEY,
        aliases TEXT,
        one_line TEXT NOT NULL,
        daily_analogy TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE daily_challenges (
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        answer INTEGER NOT NULL,
        explanation TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE fruits (
        id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL UNIQUE,
        skill_label TEXT NOT NULL,
        emoji TEXT
      );
    ''');

    // 经典书架（内容表，由 JSON 灌入）
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        level INTEGER DEFAULT 1,
        cover_emoji TEXT,
        tags TEXT,
        one_line TEXT,
        why_read TEXT,
        core_ideas TEXT,
        takeaways TEXT,
        for_whom TEXT,
        read_path TEXT,
        related_chapters TEXT,
        sort_order INTEGER DEFAULT 0
      );
    ''');

    // ---------------- 状态表 ----------------
    await db.execute('''
      CREATE TABLE user_status (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        nickname TEXT DEFAULT '小白',
        current_level INTEGER DEFAULT 1,
        rank_title TEXT DEFAULT '青铜小白',
        total_points INTEGER DEFAULT 0,
        current_chapter_id TEXT DEFAULT 'C1',
        cards_read_count INTEGER DEFAULT 0,
        quizzes_passed_count INTEGER DEFAULT 0,
        daily_streak INTEGER DEFAULT 0,
        last_daily_date TEXT,
        crash_sim_used INTEGER DEFAULT 0,
        onboarding_done INTEGER DEFAULT 0,
        risk_profile TEXT,
        risk_taken_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE card_reads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id TEXT NOT NULL,
        swipe_status TEXT NOT NULL,
        earned_points INTEGER DEFAULT 0,
        read_at TEXT NOT NULL
      );
    ''');
    await db.execute(
        'CREATE INDEX idx_card_reads_card ON card_reads(card_id);');

    await db.execute('''
      CREATE TABLE review_queue (
        card_id TEXT PRIMARY KEY,
        added_at TEXT NOT NULL,
        review_count INTEGER DEFAULT 0,
        mastered INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE quiz_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_id TEXT NOT NULL,
        correct_count INTEGER NOT NULL,
        total_count INTEGER NOT NULL,
        correct_rate REAL NOT NULL,
        passed INTEGER NOT NULL,
        points_earned INTEGER DEFAULT 0,
        attempted_at TEXT NOT NULL
      );
    ''');

    await db.execute(
        'CREATE INDEX idx_quiz_att_chapter ON quiz_attempts(chapter_id);');

    await db.execute('''
      CREATE TABLE sim_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sim_id TEXT NOT NULL,
        chosen_key TEXT NOT NULL,
        pnl_pct REAL,
        points_earned INTEGER DEFAULT 0,
        attempted_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE growth_fruits (
        id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL UNIQUE,
        skill_label TEXT NOT NULL,
        emoji TEXT,
        unlocked INTEGER DEFAULT 0,
        unlocked_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE daily_records (
        date TEXT PRIMARY KEY,
        correct_count INTEGER DEFAULT 0,
        total_count INTEGER DEFAULT 3,
        points_earned INTEGER DEFAULT 0,
        finished INTEGER DEFAULT 0
      );
    ''');
  }

  Future<void> _seedFromAssets(Database db) async {
    final raw =
        await rootBundle.loadString('assets/data/knowledge_base.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;

    // chapters
    for (final j in (data['chapters'] as List)) {
      final c = Chapter.fromJson(j as Map<String, dynamic>);
      await db.insert('chapters', {
        'id': c.id,
        'level': c.level,
        'order_index': c.orderIndex,
        'title': c.title,
        'subtitle': c.subtitle,
        'description': c.description,
        'cover_emoji': c.coverEmoji,
        'theme_color': c.themeColor,
        'unlock_type': c.unlockType,
        'unlock_ref': c.unlockRef,
        'required_correct_rate': c.requiredCorrectRate,
        'required_quiz_count': c.requiredQuizCount,
        'estimated_minutes': c.estimatedMinutes,
        'rank_title': c.rankTitle,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // cards
    for (final j in (data['cards'] as List)) {
      final c = KnowledgeCard.fromJson(j as Map<String, dynamic>);
      await db.insert('cards', {
        'id': c.id,
        'chapter_id': 'C${c.chapter}',
        'order_index': c.orderIndex,
        'title': c.title,
        'daily_analogy': c.dailyAnalogy,
        'core_knowledge': c.coreKnowledge,
        'illustration_note': c.illustrationNote,
        'glossary_terms': jsonEncode(c.glossaryTerms),
        'points': c.points,
        'difficulty': c.difficulty,
        'related_quiz_id': c.relatedQuizId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // quizzes
    for (final j in (data['quizzes'] as List)) {
      final q = Quiz.fromJson(j as Map<String, dynamic>);
      await db.insert('quizzes', {
        'id': q.id,
        'chapter_id': q.chapterId,
        'order_index': q.orderIndex,
        'question': q.question,
        'options': jsonEncode(q.options),
        'answer_index': q.answerIndex,
        'explanation': q.explanation,
        'right_reply': q.rightReply,
        'wrong_reply': q.wrongReply,
        'points': q.points,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // simulations
    for (final j in (data['simulations'] as List)) {
      final s = Simulation.fromJson(j as Map<String, dynamic>);
      await db.insert('simulations', {
        'id': s.id,
        'chapter_id': s.chapterId,
        'order_index': s.orderIndex,
        'title': s.title,
        'background': s.background,
        'era_year': s.eraYear,
        'initial_amount': s.initialAmount,
        'options': jsonEncode(s.options
            .map((o) => {
                  'key': o.key,
                  'text': o.text,
                  'outcome': o.outcome,
                  'pnl_pct': o.pnlPct,
                  'emoji': o.emoji,
                  'takeaway': o.takeaway,
                })
            .toList()),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // glossary
    for (final j in (data['glossary'] as List)) {
      final g = GlossaryTerm.fromJson(j as Map<String, dynamic>);
      await db.insert('glossary', {
        'term': g.term,
        'aliases': jsonEncode(g.aliases),
        'one_line': g.oneLine,
        'daily_analogy': g.dailyAnalogy,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // daily challenges
    for (final j in (data['daily_challenges'] as List)) {
      final d = DailyChallenge.fromJson(j as Map<String, dynamic>);
      await db.insert('daily_challenges', {
        'id': d.id,
        'question': d.question,
        'answer': d.answer ? 1 : 0,
        'explanation': d.explanation,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // fruits + growth_fruits (same seed)
    for (final j in (data['fruits'] as List)) {
      final f = Fruit.fromJson(j as Map<String, dynamic>);
      await db.insert('fruits', {
        'id': f.id,
        'chapter_id': f.chapterId,
        'skill_label': f.skillLabel,
        'emoji': f.emoji,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await db.insert('growth_fruits', {
        'id': f.id,
        'chapter_id': f.chapterId,
        'skill_label': f.skillLabel,
        'emoji': f.emoji,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // 经典书架
    await _seedBooks(db, data);

    // 初始用户状态
    final now = DateTime.now().toIso8601String();
    await db.insert('user_status', {
      'id': 1,
      'nickname': '小白',
      'current_level': 1,
      'rank_title': '青铜小白',
      'total_points': 0,
      'current_chapter_id': 'C1',
      'cards_read_count': 0,
      'quizzes_passed_count': 0,
      'daily_streak': 0,
      'last_daily_date': null,
      'crash_sim_used': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('app_meta',
        {'key': 'content_version', 'value': _contentVersion});
    await db.insert(
        'app_meta', {'key': 'first_launch_at', 'value': now});
  }

  // ---------------- 查询 ----------------
  Future<List<Chapter>> getChapters() async {
    final db = await database;
    final rows = await db.query('chapters', orderBy: 'order_index');
    return rows.map(Chapter.fromJson).toList();
  }

  /// 知识卡总数（首页进度条分母）。
  Future<int> countCards() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM cards')) ??
        0;
  }

  Future<List<KnowledgeCard>> getCards(String chapterId) async {
    final db = await database;
    final rows = await db.query('cards',
        where: 'chapter_id = ?',
        whereArgs: [chapterId],
        orderBy: 'order_index');
    return rows.map(_cardFromRow).toList();
  }

  KnowledgeCard _cardFromRow(Map<String, dynamic> r) {
    return KnowledgeCard(
      id: r['id'] as String,
      chapter: int.parse((r['chapter_id'] as String).substring(1)),
      orderIndex: r['order_index'] as int,
      title: r['title'] as String,
      dailyAnalogy: r['daily_analogy'] as String,
      coreKnowledge: r['core_knowledge'] as String,
      illustrationNote: (r['illustration_note'] as String?) ?? '',
      glossaryTerms:
          (jsonDecode(r['glossary_terms'] as String? ?? '[]') as List)
              .cast<String>(),
      points: r['points'] as int,
      difficulty: r['difficulty'] as int,
      relatedQuizId: (r['related_quiz_id'] as String?) ?? '',
    );
  }

  Future<List<Quiz>> getQuizzes(String chapterId) async {
    final db = await database;
    final rows = await db.query('quizzes',
        where: 'chapter_id = ?',
        whereArgs: [chapterId],
        orderBy: 'order_index');
    return rows.map((r) {
      return Quiz(
        id: r['id'] as String,
        chapterId: r['chapter_id'] as String,
        orderIndex: r['order_index'] as int,
        question: r['question'] as String,
        options: (jsonDecode(r['options'] as String) as List).cast<String>(),
        answerIndex: r['answer_index'] as int,
        explanation: (r['explanation'] as String?) ?? '',
        rightReply: (r['right_reply'] as String?) ?? '答对啦！',
        wrongReply: (r['wrong_reply'] as String?) ??
            '哎呀，这是90%新手都会踩的坑哦，记住啦！',
        points: r['points'] as int,
      );
    }).toList();
  }

  Future<List<Simulation>> getSimulations() async {
    final db = await database;
    final rows = await db.query('simulations', orderBy: 'order_index');
    return rows.map((r) {
      final opts = (jsonDecode(r['options'] as String) as List)
          .map((e) => SimOption.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Simulation(
        id: r['id'] as String,
        chapterId: r['chapter_id'] as String?,
        orderIndex: r['order_index'] as int,
        title: r['title'] as String,
        background: r['background'] as String,
        eraYear: (r['era_year'] as int?) ?? 0,
        initialAmount: (r['initial_amount'] as num?)?.toDouble() ?? 100000,
        options: opts,
      );
    }).toList();
  }

  Future<List<GlossaryTerm>> getGlossary() async {
    final db = await database;
    final rows = await db.query('glossary', orderBy: 'term');
    return rows.map((r) {
      return GlossaryTerm(
        term: r['term'] as String,
        aliases: (jsonDecode(r['aliases'] as String? ?? '[]') as List)
            .cast<String>(),
        oneLine: r['one_line'] as String,
        dailyAnalogy: (r['daily_analogy'] as String?) ?? '',
      );
    }).toList();
  }

  Future<List<DailyChallenge>> getDailyChallenges() async {
    final db = await database;
    final rows = await db.query('daily_challenges');
    return rows
        .map((r) => DailyChallenge(
              id: r['id'] as String,
              question: r['question'] as String,
              answer: (r['answer'] as int) == 1,
              explanation: (r['explanation'] as String?) ?? '',
            ))
        .toList();
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final rows = await db.query('books', orderBy: 'sort_order, id');
    return rows.map((r) {
      final ideas = (jsonDecode(r['core_ideas'] as String? ?? '[]') as List)
          .map((e) =>
              BookCoreIdea.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Book(
        id: r['id'] as String,
        title: r['title'] as String,
        author: (r['author'] as String?) ?? '',
        level: (r['level'] as int?) ?? 1,
        coverEmoji: (r['cover_emoji'] as String?) ?? '📖',
        tags: (jsonDecode(r['tags'] as String? ?? '[]') as List).cast<String>(),
        oneLine: (r['one_line'] as String?) ?? '',
        whyRead: (r['why_read'] as String?) ?? '',
        coreIdeas: ideas,
        takeaways:
            (jsonDecode(r['takeaways'] as String? ?? '[]') as List).cast<String>(),
        forWhom: (r['for_whom'] as String?) ?? '',
        readPath: (r['read_path'] as String?) ?? '',
        relatedChapters: (jsonDecode(r['related_chapters'] as String? ?? '[]')
                as List)
            .cast<String>(),
      );
    }).toList();
  }

  // ---------------- 状态读写 ----------------
  Future<Map<String, dynamic>> getUserStatus() async {
    final db = await database;
    final rows = await db.query('user_status', where: 'id = 1');
    return rows.first;
  }

  Future<void> saveUserStatus(Map<String, dynamic> patch) async {
    final db = await database;
    patch['updated_at'] = DateTime.now().toIso8601String();
    await db.update('user_status', patch, where: 'id = 1');
  }

  /// 记录一次卡片滑动。返回本次新获得的积分（已读过的卡不再加分）。
  Future<int> recordCardRead(
      String cardId, String swipeStatus, int points) async {
    final db = await database;
    final existing = await db.query('card_reads',
        where: 'card_id = ? AND swipe_status = ?',
        whereArgs: [cardId, 'got']);
    if (swipeStatus == 'got' && existing.isNotEmpty) return 0;

    final now = DateTime.now().toIso8601String();
    int earned = 0;
    if (swipeStatus == 'got') {
      earned = points;
      await db.insert('card_reads', {
        'card_id': cardId,
        'swipe_status': swipeStatus,
        'earned_points': earned,
        'read_at': now,
      });
      // 进入复习队列的「没懂」
    } else {
      await db.insert('card_reads', {
        'card_id': cardId,
        'swipe_status': swipeStatus,
        'earned_points': 0,
        'read_at': now,
      });
      await db.insert('review_queue', {
        'card_id': cardId,
        'added_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      // 已掌握的卡片被再次标记「没懂」：重置回待复习状态
      await db.update('review_queue', {'mastered': 0},
          where: 'card_id = ? AND mastered = 1', whereArgs: [cardId]);
    }

    // 已读卡片数（distinct）
    final cnt = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(DISTINCT card_id) FROM card_reads WHERE swipe_status = ?',
        ['got']));
    final total = await totalPoints();
    await saveUserStatus({
      'cards_read_count': cnt ?? 0,
      'total_points': total,
    });
    return earned;
  }

  /// 该卡是否已「懂了」
  Future<bool> isCardRead(String cardId) async {
    final db = await database;
    final rows = await db.query('card_reads',
        where: 'card_id = ? AND swipe_status = ?',
        whereArgs: [cardId, 'got'],
        limit: 1);
    return rows.isNotEmpty;
  }

  Future<List<int>> readCardStats(String chapterId) async {
    final db = await database;
    final all = await db.rawQuery(
        'SELECT id FROM cards WHERE chapter_id = ?', [chapterId]);
    var read = 0;
    for (final r in all) {
      final exist = await db.query('card_reads',
          where: 'card_id = ? AND swipe_status = ?',
          whereArgs: [r['id'], 'got'],
          limit: 1);
      if (exist.isNotEmpty) read++;
    }
    return [read, all.length];
  }

  /// 记录一次测验，返回是否达到通过线（≥80%）。
  Future<bool> recordQuizAttempt(
      String chapterId, int correct, int total) async {
    final db = await database;
    final rate = total == 0 ? 0.0 : correct / total;
    final passed = rate >= 0.8;
    final quizRows = await getQuizzes(chapterId);
    int earned = 0;
    if (passed) {
      // 只在首次通过该章时加分，避免反复刷分
      final before = await db.query('quiz_attempts',
          where: 'chapter_id = ? AND passed = 1',
          whereArgs: [chapterId],
          limit: 1);
      if (before.isEmpty) {
        earned = quizRows.fold<int>(0, (a, q) => a + q.points);
      }
    }
    final now = DateTime.now().toIso8601String();
    await db.insert('quiz_attempts', {
      'chapter_id': chapterId,
      'correct_count': correct,
      'total_count': total,
      'correct_rate': rate,
      'passed': passed ? 1 : 0,
      'points_earned': earned,
      'attempted_at': now,
    });

    final passCnt = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(DISTINCT chapter_id) FROM quiz_attempts WHERE passed = 1'));
    final totalPts = await totalPoints();
    await saveUserStatus({
      'quizzes_passed_count': passCnt ?? 0,
      'total_points': totalPts,
    });

    if (passed) await unlockFruit(chapterId);
    return passed;
  }

  Future<bool> isChapterPassed(String chapterId) async {
    final db = await database;
    final rows = await db.query('quiz_attempts',
        where: 'chapter_id = ? AND passed = 1',
        whereArgs: [chapterId],
        limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> unlockFruit(String chapterId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
        'growth_fruits', {'unlocked': 1, 'unlocked_at': now},
        where: 'chapter_id = ? AND unlocked = 0', whereArgs: [chapterId]);
    // 通过章节即解锁下一章，并更新段位（等级=已通关章数+1，封顶4）
    final order = int.parse(chapterId.substring(1));
    final newLevel = (order + 1).clamp(1, 4);
    final titles = {1: '青铜小白', 2: '白银学徒', 3: '黄金规划师', 4: '铂金守心人'};
    await saveUserStatus({
      'current_level': newLevel,
      'rank_title': titles[newLevel],
    });
  }

  Future<List<Map<String, dynamic>>> getFruits() async {
    final db = await database;
    return db.query('growth_fruits', orderBy: 'chapter_id');
  }

  Future<int> recordSimAttempt(
      String simId, String chosenKey, double pnlPct) async {
    final db = await database;
    // 每个模拟首次作答加 15 分
    final before = await db.query('sim_attempts',
        where: 'sim_id = ?', whereArgs: [simId], limit: 1);
    final earned = before.isEmpty ? 15 : 0;
    await db.insert('sim_attempts', {
      'sim_id': simId,
      'chosen_key': chosenKey,
      'pnl_pct': pnlPct,
      'points_earned': earned,
      'attempted_at': DateTime.now().toIso8601String(),
    });
    await saveUserStatus({'total_points': await totalPoints()});
    return earned;
  }

  Future<bool> markCrashUsed() async {
    final db = await database;
    final row = (await db.query('user_status', where: 'id = 1')).first;
    final already = (row['crash_sim_used'] as int) == 1;
    await saveUserStatus({'crash_sim_used': 1});
    return !already; // 是否首次
  }

  Future<int> totalPoints() async {
    final db = await database;
    final v1 = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COALESCE(SUM(earned_points),0) FROM card_reads')) ??
        0;
    final v2 = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COALESCE(SUM(points_earned),0) FROM quiz_attempts')) ??
        0;
    final v3 = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COALESCE(SUM(points_earned),0) FROM sim_attempts')) ??
        0;
    final v4 = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COALESCE(SUM(points_earned),0) FROM daily_records')) ??
        0;
    return v1 + v2 + v3 + v4;
  }

  /// 每日早餐挑战：返回今天是否已完成。
  Future<bool> isDailyDoneToday() async {
    final db = await database;
    final today = _ymd(DateTime.now());
    final rows = await db.query('daily_records',
        where: 'date = ? AND finished = 1', whereArgs: [today], limit: 1);
    return rows.isNotEmpty;
  }

  /// 记录每日挑战结果，更新连击。返回（新得积分, 当前连击）。
  Future<(int, int)> recordDaily(int correct, int total) async {
    final db = await database;
    final today = _ymd(DateTime.now());
    final earned = correct * 10 + (correct == total ? 20 : 0);
    await db.insert('daily_records', {
      'date': today,
      'correct_count': correct,
      'total_count': total,
      'points_earned': earned,
      'finished': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // 连击计算：以 user_status.last_daily_date 为锚点，
    // 昨天打过卡则 +1，今天重复打不重复计，否则重置为 1。
    final now = DateTime.now();
    final yest = _ymd(now.subtract(const Duration(days: 1)));

    final u = await getUserStatus();
    final last = u['last_daily_date'] as String?;
    int streak = (u['daily_streak'] as int? ?? 0);
    if (last == yest) {
      streak += 1;
    } else if (last == today) {
      // 今日已算过
    } else {
      streak = 1;
    }
    await saveUserStatus({
      'last_daily_date': today,
      'daily_streak': streak,
      'total_points': await totalPoints(),
    });
    return (earned, streak);
  }

  Future<int> getStreak() async {
    final u = await getUserStatus();
    return u['daily_streak'] as int? ?? 0;
  }

  Future<int> getReviewCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM review_queue WHERE mastered = 0')) ??
        0;
  }

  /// 待复习卡片（按入队先后），返回卡片数据。
  Future<List<KnowledgeCard>> getReviewCards() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT c.* FROM review_queue q JOIN cards c ON c.id = q.card_id
      WHERE q.mastered = 0 ORDER BY q.added_at
    ''');
    return rows.map(_cardFromRow).toList();
  }

  /// 复习反馈：mastered=true 移出队列（+5 复习奖励积分）；false 留在队列。
  Future<void> recordReview(String cardId, {required bool mastered}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate(
        'UPDATE review_queue SET mastered = ?, review_count = review_count + 1 '
        'WHERE card_id = ?',
        [mastered ? 1 : 0, cardId]);
    if (mastered) {
      await db.insert('card_reads', {
        'card_id': cardId,
        'swipe_status': 'review_got',
        'earned_points': 5,
        'read_at': now,
      });
    }
    await saveUserStatus({'total_points': await totalPoints()});
  }

  /// 保存风险测评画像（重测覆盖）。
  Future<void> saveRiskProfile(String type) async {
    await saveUserStatus({
      'risk_profile': type,
      'risk_taken_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> resetAll() async {
    final db = await database;
    for (final t in [
      'card_reads',
      'review_queue',
      'quiz_attempts',
      'sim_attempts',
      'daily_records',
    ]) {
      await db.delete(t);
    }
    await db.update('growth_fruits', {'unlocked': 0, 'unlocked_at': null});
    final now = DateTime.now().toIso8601String();
    await db.update('user_status', {
      'nickname': '小白',
      'current_level': 1,
      'rank_title': '青铜小白',
      'total_points': 0,
      'current_chapter_id': 'C1',
      'cards_read_count': 0,
      'quizzes_passed_count': 0,
      'daily_streak': 0,
      'last_daily_date': null,
      'crash_sim_used': 0,
      'updated_at': now,
    });
  }

  String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
