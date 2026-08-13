import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/db/database_helper.dart';
import '../../data/models/book.dart';
import 'book_detail_screen.dart';

/// 经典书架：投资经典的大白话导读，按难度分组。
class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  final _db = DatabaseHelper.instance;
  List<Book> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _books = await _db.getBooks();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('经典书架')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 40)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('站在巨人的肩膀上',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text('${_books.length} 本投资经典，我们用大白话帮你嚼碎了。想深入，再去读原书。',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.6)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final level in [1, 2, 3]) ...[
                    _levelHeader(level),
                    const SizedBox(height: 10),
                    ..._books.where((b) => b.level == level).map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BookCard(
                                book: b,
                                onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              BookDetailScreen(book: b)),
                                    )),
                          ),
                        ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.warnSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '🥬 书架内容是我们原创的大白话导读，帮你判断「这本书值不值得读、讲了什么」，'
                      '不复制原书原文。想深入学习，请购买或借阅正版图书。',
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.7,
                          color: Color(0xFF7A4A1F)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _levelHeader(int level) {
    final (emoji, label, desc) = switch (level) {
      1 => ('🌱', '入门 · 先读这些', '完全零基础也能轻松读'),
      2 => ('🌿', '进阶 · 建立体系', '懂基础后，构建投资框架'),
      _ => ('🌳', '高阶 · 修炼心态', '理解风险、周期与人性'),
    };
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink)),
        const SizedBox(width: 8),
        Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.9),
                      AppTheme.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(book.coverEmoji,
                    style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(book.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warnSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(book.levelLabel,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryDark)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(book.author,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.ink2)),
                    const SizedBox(height: 6),
                    Text(book.oneLine,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: book.tags
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.cream,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('#$t',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.ink2)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.ink2),
            ],
          ),
        ),
      ),
    );
  }
}
