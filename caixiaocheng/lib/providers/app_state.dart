import 'package:flutter/foundation.dart';
import '../core/db/database_helper.dart';
import '../data/models/chapter.dart';

/// 全局应用状态：章节解锁、积分、段位、成长树、连击等。
class AppState extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<Chapter> _chapters = [];
  List<Chapter> get chapters => _chapters;

  int totalPoints = 0;
  int currentLevel = 1;
  String rankTitle = '青铜小白';
  int cardsRead = 0;
  int totalCards = 0;
  int chaptersPassed = 0;
  int streak = 0;
  bool crashUsed = false;
  bool onboardingDone = false;
  String? riskProfile;
  int reviewCount = 0;
  Set<String> unlockedFruits = {};
  Set<String> passedChapters = {};
  bool loaded = false;

  Future<void> init() async {
    _chapters = await _db.getChapters();
    totalCards = await _db.countCards();
    await refresh();
    loaded = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    final u = await _db.getUserStatus();
    totalPoints = u['total_points'] as int? ?? 0;
    currentLevel = u['current_level'] as int? ?? 1;
    rankTitle = (u['rank_title'] as String?) ?? '青铜小白';
    cardsRead = u['cards_read_count'] as int? ?? 0;
    chaptersPassed = u['quizzes_passed_count'] as int? ?? 0;
    streak = u['daily_streak'] as int? ?? 0;
    crashUsed = (u['crash_sim_used'] as int? ?? 0) == 1;
    onboardingDone = (u['onboarding_done'] as int? ?? 0) == 1;
    riskProfile = u['risk_profile'] as String?;
    reviewCount = await _db.getReviewCount();

    passedChapters.clear();
    for (final c in _chapters) {
      if (await _db.isChapterPassed(c.id)) passedChapters.add(c.id);
    }
    final fruits = await _db.getFruits();
    unlockedFruits = fruits
        .where((f) => (f['unlocked'] as int? ?? 0) == 1)
        .map((f) => f['chapter_id'] as String)
        .toSet();
    notifyListeners();
  }

  /// 章节是否解锁：C1 始终解锁；其余需要上一章通关。
  bool isChapterUnlocked(Chapter c) {
    if (c.unlockType == 'none' || c.orderIndex == 1) return true;
    if (c.unlockRef == null) return true;
    return passedChapters.contains(c.unlockRef);
  }

  /// 当前推荐进入的章节（第一个未通关的）
  Chapter? get currentChapter {
    for (final c in _chapters) {
      if (!passedChapters.contains(c.id)) return c;
    }
    return _chapters.isNotEmpty ? _chapters.last : null;
  }

  /// 虚拟资产：积分按 1 积分 = 10 元「认知本金」展示（纯虚拟，非真实货币）
  int get virtualAssets => 10000 + totalPoints * 10;

  Future<int> recordCard(String cardId, String status, int points) async {
    final e = await _db.recordCardRead(cardId, status, points);
    await refresh();
    return e;
  }

  Future<bool> recordQuiz(String chapterId, int correct, int total) async {
    final passed = await _db.recordQuizAttempt(chapterId, correct, total);
    await refresh();
    return passed;
  }

  Future<int> recordSim(String simId, String key, double pnl) async {
    final e = await _db.recordSimAttempt(simId, key, pnl);
    await refresh();
    return e;
  }

  Future<(int, int)> recordDaily(int correct, int total) async {
    final r = await _db.recordDaily(correct, total);
    await refresh();
    return r;
  }

  Future<bool> markCrash() async {
    final first = await _db.markCrashUsed();
    await refresh();
    return first;
  }

  Future<void> finishOnboarding() async {
    await _db.saveUserStatus({'onboarding_done': 1});
    onboardingDone = true;
    notifyListeners();
  }

  Future<void> saveRiskProfile(String type) async {
    await _db.saveRiskProfile(type);
    riskProfile = type;
    notifyListeners();
  }

  /// 复习反馈：mastered=true 移出队列（+5 积分）；false 留队。
  Future<void> recordReview(String cardId, {required bool mastered}) async {
    await _db.recordReview(cardId, mastered: mastered);
    await refresh();
  }

  /// 风险画像展示映射（UI 复用）。
  static (String, String, String) riskProfileMeta(String type) {
    switch (type) {
      case 'conservative':
        return ('🛡️', '保守型', '保本优先，波动要小');
      case 'aggressive':
        return ('🚀', '进取型', '追求高收益，扛得住大波动');
      default:
        return ('⚖️', '稳健型', '平衡增长，跑赢通胀');
    }
  }

  /// 风险画像对应的建议股债配置（教学参考，呼应 100-年龄法则）。
  static String riskAllocation(String type) {
    switch (type) {
      case 'conservative':
        return '股 20% / 债 80%';
      case 'aggressive':
        return '股 60% / 债 40%';
      default:
        return '股 40% / 债 60%';
    }
  }

  Future<void> reset() async {
    await _db.resetAll();
    await refresh();
  }
}
