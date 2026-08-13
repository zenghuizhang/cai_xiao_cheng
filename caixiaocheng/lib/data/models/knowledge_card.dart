class KnowledgeCard {
  final String id;
  final int chapter;
  final int orderIndex;
  final String title;
  final String dailyAnalogy;
  final String coreKnowledge;
  final String illustrationNote;
  final List<String> glossaryTerms;
  final int points;
  final int difficulty;
  final String relatedQuizId;

  const KnowledgeCard({
    required this.id,
    required this.chapter,
    required this.orderIndex,
    required this.title,
    required this.dailyAnalogy,
    required this.coreKnowledge,
    required this.illustrationNote,
    required this.glossaryTerms,
    required this.points,
    required this.difficulty,
    required this.relatedQuizId,
  });

  factory KnowledgeCard.fromJson(Map<String, dynamic> j) => KnowledgeCard(
        id: j['id'] as String,
        chapter: j['chapter'] as int,
        orderIndex: j['order_index'] as int,
        title: j['title'] as String,
        dailyAnalogy: j['daily_analogy'] as String,
        coreKnowledge: j['core_knowledge'] as String,
        illustrationNote: j['illustration_note'] as String? ?? '',
        glossaryTerms:
            (j['glossary_terms'] as List?)?.cast<String>() ?? const [],
        points: j['points'] as int? ?? 10,
        difficulty: j['difficulty'] as int? ?? 1,
        relatedQuizId: j['related_quiz_id'] as String? ?? '',
      );
}
