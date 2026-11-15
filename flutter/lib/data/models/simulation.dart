class SimOption {
  final String key;
  final String text;
  final String outcome;
  final double pnlPct;
  final String emoji;
  final String takeaway;

  const SimOption({
    required this.key,
    required this.text,
    required this.outcome,
    required this.pnlPct,
    required this.emoji,
    required this.takeaway,
  });

  factory SimOption.fromJson(Map<String, dynamic> j) => SimOption(
        key: j['key'] as String,
        text: j['text'] as String,
        outcome: j['outcome'] as String,
        pnlPct: (j['pnl_pct'] as num?)?.toDouble() ?? 0,
        emoji: j['emoji'] as String? ?? '🍊',
        takeaway: j['takeaway'] as String? ?? '',
      );
}

class StoryOption {
  final String key;
  final String text;
  final String feedback;
  final int scoreDelta;
  final String emoji;

  const StoryOption({
    required this.key,
    required this.text,
    required this.feedback,
    required this.scoreDelta,
    required this.emoji,
  });

  factory StoryOption.fromJson(Map<String, dynamic> j) => StoryOption(
        key: j['key'] as String,
        text: j['text'] as String,
        feedback: j['feedback'] as String? ?? '',
        scoreDelta: j['score_delta'] as int? ?? 0,
        emoji: j['emoji'] as String? ?? '🍊',
      );
}

class StoryRound {
  final String id;
  final String title;
  final String background;
  final List<StoryOption> options;

  const StoryRound({
    required this.id,
    required this.title,
    required this.background,
    required this.options,
  });

  factory StoryRound.fromJson(Map<String, dynamic> j) => StoryRound(
        id: j['id'] as String,
        title: j['title'] as String,
        background: j['background'] as String,
        options: (j['options'] as List? ?? const [])
            .map((e) => StoryOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class StoryEnding {
  final String id;
  final int minScore;
  final int maxScore;
  final String title;
  final String outcome;
  final double pnlPct;
  final String emoji;
  final String takeaway;

  const StoryEnding({
    required this.id,
    required this.minScore,
    required this.maxScore,
    required this.title,
    required this.outcome,
    required this.pnlPct,
    required this.emoji,
    required this.takeaway,
  });

  factory StoryEnding.fromJson(Map<String, dynamic> j) => StoryEnding(
        id: j['id'] as String,
        minScore: j['min_score'] as int? ?? 0,
        maxScore: j['max_score'] as int? ?? 0,
        title: j['title'] as String,
        outcome: j['outcome'] as String,
        pnlPct: (j['pnl_pct'] as num?)?.toDouble() ?? 0,
        emoji: j['emoji'] as String? ?? '🍊',
        takeaway: j['takeaway'] as String? ?? '',
      );
}

class Simulation {
  final String id;
  final String? chapterId;
  final int orderIndex;
  final String title;
  final String background;
  final int eraYear;
  final double initialAmount;
  final List<SimOption> options;
  final List<StoryRound> storyRounds;
  final List<StoryEnding> storyEndings;

  const Simulation({
    required this.id,
    required this.chapterId,
    required this.orderIndex,
    required this.title,
    required this.background,
    required this.eraYear,
    required this.initialAmount,
    required this.options,
    this.storyRounds = const [],
    this.storyEndings = const [],
  });

  bool get isStoryMode => storyRounds.isNotEmpty && storyEndings.isNotEmpty;

  factory Simulation.fromJson(Map<String, dynamic> j) => Simulation(
        id: j['id'] as String,
        chapterId: j['chapter_id'] as String?,
        orderIndex: j['order_index'] as int,
        title: j['title'] as String,
        background: j['background'] as String,
        eraYear: j['era_year'] as int? ?? 0,
        initialAmount: (j['initial_amount'] as num?)?.toDouble() ?? 100000,
        options: (j['options'] as List)
            .map((e) => SimOption.fromJson(e as Map<String, dynamic>))
            .toList(),
        storyRounds: (j['story_rounds'] as List? ?? const [])
            .map((e) => StoryRound.fromJson(e as Map<String, dynamic>))
            .toList(),
        storyEndings: (j['story_endings'] as List? ?? const [])
            .map((e) => StoryEnding.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
