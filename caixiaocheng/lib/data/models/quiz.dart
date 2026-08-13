class Quiz {
  final String id;
  final String chapterId;
  final int orderIndex;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final String rightReply;
  final String wrongReply;
  final int points;

  const Quiz({
    required this.id,
    required this.chapterId,
    required this.orderIndex,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    required this.rightReply,
    required this.wrongReply,
    required this.points,
  });

  factory Quiz.fromJson(Map<String, dynamic> j) => Quiz(
        id: j['id'] as String,
        chapterId: j['chapter_id'] as String,
        orderIndex: j['order_index'] as int,
        question: j['question'] as String,
        options: (j['options'] as List).cast<String>(),
        answerIndex: j['answer_index'] as int,
        explanation: j['explanation'] as String? ?? '',
        rightReply: j['right_reply'] as String? ?? '答对啦！',
        wrongReply:
            j['wrong_reply'] as String? ?? '哎呀，这是90%新手都会踩的坑哦，记住啦！',
        points: j['points'] as int? ?? 20,
      );
}
