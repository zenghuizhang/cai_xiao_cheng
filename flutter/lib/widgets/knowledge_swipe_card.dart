// 知识卡卡片视图 + 滑动背景：学习页与复习页共用。
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/models/knowledge_card.dart';
import 'glossary_sheet.dart';

/// 知识卡主体（难度徽章 + 标题 + 大白话类比 + 核心知识 + 配图建议 + 术语 chips）。
class KnowledgeCardView extends StatelessWidget {
  final KnowledgeCard card;
  const KnowledgeCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 难度徽章
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warnSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '难度${'★' * card.difficulty}${'☆' * (3 - card.difficulty)}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 14),
            Text(card.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                    height: 1.35)),
            const SizedBox(height: 18),
            // 生活类比（重点卡片）
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.warnSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🥬', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 6),
                      Text('大白话类比',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(card.dailyAnalogy,
                      style: const TextStyle(
                          fontSize: 16,
                          height: 1.8,
                          color: Color(0xFF7A4A1F))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('核心知识',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink2)),
            const SizedBox(height: 6),
            Text(card.coreKnowledge,
                style:
                    const TextStyle(fontSize: 17, height: 1.8, color: AppTheme.ink)),
            if (card.illustrationNote.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('🎨 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text('配图建议：${card.illustrationNote}',
                          style: const TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AppTheme.ink2)),
                    ),
                  ],
                ),
              ),
            ],
            if (card.glossaryTerms.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('文中术语（点一下看解释）',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.ink2,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: card.glossaryTerms
                    .map((t) => ActionChip(
                          label: Text(t),
                          onPressed: () =>
                              GlossarySheet.open(context, initial: t),
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: AppTheme.primary, width: 1),
                          labelStyle: const TextStyle(
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// 滑卡背景：右滑（懂了/绿）或左滑（再看看/橙）。
class SwipeBackground extends StatelessWidget {
  final bool right;
  const SwipeBackground({super.key, required this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(right ? -0.9 : 0.9, 0),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: right ? AppTheme.greenSoft : AppTheme.warnSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(right ? Icons.thumb_up : Icons.refresh,
              size: 48,
              color: right ? AppTheme.success : AppTheme.primary),
          const SizedBox(height: 8),
          Text(right ? '懂了！' : '再看看',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: right ? AppTheme.success : AppTheme.primary)),
        ],
      ),
    );
  }
}
