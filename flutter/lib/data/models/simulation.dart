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

class Simulation {
  final String id;
  final String? chapterId;
  final int orderIndex;
  final String title;
  final String background;
  final int eraYear;
  final double initialAmount;
  final List<SimOption> options;

  const Simulation({
    required this.id,
    required this.chapterId,
    required this.orderIndex,
    required this.title,
    required this.background,
    required this.eraYear,
    required this.initialAmount,
    required this.options,
  });

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
      );
}
