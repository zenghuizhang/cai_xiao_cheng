import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/book.dart';
import '../../widgets/glossary_sheet.dart';

/// 书籍详情：核心理念大白话解读 + 金句 + 适合谁 + 阅读路径。
class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 16),
            _section(
              icon: '🤔',
              title: '为什么值得读',
              child: Text(book.whyRead,
                  style: const TextStyle(
                      fontSize: 16, height: 1.8, color: AppTheme.ink)),
            ),
            const SizedBox(height: 14),
            _section(
              icon: '💡',
              title: '核心理念（大白话版）',
              child: Column(
                children: [
                  for (int i = 0; i < book.coreIdeas.length; i++)
                    _ideaItem(i + 1, book.coreIdeas[i]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _section(
              icon: '✨',
              title: '记住这几句',
              bg: AppTheme.greenSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final t in book.takeaways)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🍊 '),
                          Expanded(
                            child: Text(t,
                                style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.7,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E7D4F))),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _section(
              icon: '👥',
              title: '适合谁读',
              child: Text(book.forWhom,
                  style: const TextStyle(
                      fontSize: 15, height: 1.8, color: AppTheme.ink)),
            ),
            const SizedBox(height: 14),
            _section(
              icon: '🗺️',
              title: '怎么读更省力',
              child: Text(book.readPath,
                  style: const TextStyle(
                      fontSize: 15, height: 1.8, color: AppTheme.ink)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warnSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📖 '),
                  Expanded(
                    child: Text(
                      '这里是原创的大白话导读，帮你快速了解一本书的精华。'
                      '如果觉得有启发，建议购买或借阅正版原书细细阅读，支持作者。',
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.7,
                          color: Color(0xFF7A4A1F)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => GlossarySheet.open(context),
              icon: const Icon(Icons.search, color: AppTheme.primary),
              label: const Text('遇到不懂的词？查一下'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 94,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            alignment: Alignment.center,
            child: Text(book.coverEmoji, style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.3)),
                const SizedBox(height: 6),
                Text(book.author,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.5)),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('${book.levelLabel} · ${book.oneLine}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String icon,
    required String title,
    required Widget child,
    Color bg = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bg == Colors.white ? AppTheme.line : bg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _ideaItem(int i, BookCoreIdea idea) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.warnSoft,
              shape: BoxShape.circle,
            ),
            child: Text('$i',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(idea.idea,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                        height: 1.5)),
                const SizedBox(height: 4),
                Text(idea.explain,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: AppTheme.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
