class Chapter {
  final String id;
  final int level;
  final int orderIndex;
  final String title;
  final String subtitle;
  final String description;
  final String coverEmoji;
  final String themeColor;
  final String unlockType;
  final String? unlockRef;
  final double requiredCorrectRate;
  final int requiredQuizCount;
  final int estimatedMinutes;
  final String rankTitle;

  const Chapter({
    required this.id,
    required this.level,
    required this.orderIndex,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coverEmoji,
    required this.themeColor,
    required this.unlockType,
    required this.unlockRef,
    required this.requiredCorrectRate,
    required this.requiredQuizCount,
    required this.estimatedMinutes,
    required this.rankTitle,
  });

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
        id: j['id'] as String,
        level: j['level'] as int,
        orderIndex: j['order_index'] as int,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String? ?? '',
        description: j['description'] as String? ?? '',
        coverEmoji: j['cover_emoji'] as String? ?? '🍊',
        themeColor: j['theme_color'] as String? ?? '#FF8C42',
        unlockType: j['unlock_type'] as String? ?? 'prev_chapter',
        unlockRef: j['unlock_ref'] as String?,
        requiredCorrectRate:
            (j['required_correct_rate'] as num?)?.toDouble() ?? 0.8,
        requiredQuizCount: j['required_quiz_count'] as int? ?? 3,
        estimatedMinutes: j['estimated_minutes'] as int? ?? 10,
        rankTitle: j['rank_title'] as String? ?? '',
      );

  int get colorValue {
    var hex = themeColor.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }
}
