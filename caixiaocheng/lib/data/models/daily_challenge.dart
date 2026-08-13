class DailyChallenge {
  final String id;
  final String question;
  final bool answer;
  final String explanation;

  const DailyChallenge({
    required this.id,
    required this.question,
    required this.answer,
    required this.explanation,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> j) => DailyChallenge(
        id: j['id'] as String,
        question: j['question'] as String,
        answer: j['answer'] as bool,
        explanation: j['explanation'] as String? ?? '',
      );
}
