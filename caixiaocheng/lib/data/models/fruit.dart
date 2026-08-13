class Fruit {
  final String id;
  final String chapterId;
  final String skillLabel;
  final String emoji;

  const Fruit({
    required this.id,
    required this.chapterId,
    required this.skillLabel,
    required this.emoji,
  });

  factory Fruit.fromJson(Map<String, dynamic> j) => Fruit(
        id: j['id'] as String,
        chapterId: j['chapter_id'] as String,
        skillLabel: j['skill_label'] as String,
        emoji: j['emoji'] as String? ?? '🍊',
      );
}
