class GlossaryTerm {
  final String term;
  final List<String> aliases;
  final String oneLine;
  final String dailyAnalogy;

  const GlossaryTerm({
    required this.term,
    required this.aliases,
    required this.oneLine,
    required this.dailyAnalogy,
  });

  factory GlossaryTerm.fromJson(Map<String, dynamic> j) => GlossaryTerm(
        term: j['term'] as String,
        aliases: (j['aliases'] as List?)?.cast<String>() ?? const [],
        oneLine: j['one_line'] as String,
        dailyAnalogy: j['daily_analogy'] as String? ?? '',
      );

  /// 匹配词本身或别名（大小写不敏感、包含匹配）
  bool matches(String kw) {
    final k = kw.toLowerCase();
    if (term.toLowerCase().contains(k)) return true;
    return aliases.any((a) => a.toLowerCase().contains(k));
  }
}
