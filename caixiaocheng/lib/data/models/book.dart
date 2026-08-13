/// 经典书籍推荐：仅存原创的大白话摘要/导读，不复制原书原文。
class BookCoreIdea {
  final String idea;
  final String explain;
  const BookCoreIdea({required this.idea, required this.explain});

  factory BookCoreIdea.fromJson(Map<String, dynamic> j) => BookCoreIdea(
        idea: j['idea'] as String? ?? '',
        explain: j['explain'] as String? ?? '',
      );
}

class Book {
  final String id;
  final String title;
  final String author;
  final int level; // 1 入门 / 2 进阶 / 3 高阶
  final String coverEmoji;
  final List<String> tags;
  final String oneLine;
  final String whyRead;
  final List<BookCoreIdea> coreIdeas;
  final List<String> takeaways;
  final String forWhom;
  final String readPath;
  final List<String> relatedChapters;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.level,
    required this.coverEmoji,
    required this.tags,
    required this.oneLine,
    required this.whyRead,
    required this.coreIdeas,
    required this.takeaways,
    required this.forWhom,
    required this.readPath,
    required this.relatedChapters,
  });

  factory Book.fromJson(Map<String, dynamic> j) => Book(
        id: j['id'] as String,
        title: j['title'] as String,
        author: j['author'] as String? ?? '',
        level: (j['level'] as num?)?.toInt() ?? 1,
        coverEmoji: j['cover_emoji'] as String? ?? '📖',
        tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        oneLine: j['one_line'] as String? ?? '',
        whyRead: j['why_read'] as String? ?? '',
        coreIdeas: ((j['core_ideas'] as List?) ?? const [])
            .map((e) => BookCoreIdea.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        takeaways:
            (j['takeaways'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        forWhom: j['for_whom'] as String? ?? '',
        readPath: j['read_path'] as String? ?? '',
        relatedChapters: (j['related_chapters'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  String get levelLabel => switch (level) {
        1 => '入门',
        2 => '进阶',
        _ => '高阶',
      };
}
