import 'package:flutter/material.dart';
import '../core/db/database_helper.dart';
import '../core/theme/app_theme.dart';
import '../data/models/glossary_term.dart';

/// 「一句话读懂」悬浮词典：底部常驻搜索入口。
class GlossarySheet {
  static Future<void> open(BuildContext context, {String? initial}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GlossaryPanel(initial: initial),
    );
  }
}

class _GlossaryPanel extends StatefulWidget {
  final String? initial;
  const _GlossaryPanel({this.initial});

  @override
  State<_GlossaryPanel> createState() => _GlossaryPanelState();
}

class _GlossaryPanelState extends State<_GlossaryPanel> {
  final _ctrl = TextEditingController();
  List<GlossaryTerm> _all = [];
  List<GlossaryTerm> _shown = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _all = await DatabaseHelper.instance.getGlossary();
    if (widget.initial != null && widget.initial!.isNotEmpty) {
      _ctrl.text = widget.initial!;
    }
    _filter();
    setState(() => _loading = false);
  }

  void _filter() {
    final kw = _ctrl.text.trim();
    setState(() {
      if (kw.isEmpty) {
        _shown = _all;
      } else {
        _shown = _all.where((g) => g.matches(kw)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      height: mq.size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              children: [
                const Text('🔍 一句话读懂',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _ctrl,
              onChanged: (_) => _filter(),
              decoration: InputDecoration(
                hintText: '搜词，比如「复利」「ROE」「定投」',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide:
                      const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _shown.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🤔',
                                style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text('没找到「${_ctrl.text}」',
                                style: const TextStyle(color: AppTheme.ink2)),
                            const SizedBox(height: 4),
                            const Text('换个词试试，或翻到「我的」看全部词条',
                                style: TextStyle(
                                    color: AppTheme.ink2, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _shown.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final g = _shown[i];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warnSoft,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        g.term,
                                        style: const TextStyle(
                                          color: AppTheme.primaryDark,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (g.aliases.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8),
                                        child: Text(
                                          g.aliases.join('、'),
                                          style: const TextStyle(
                                              color: AppTheme.ink2,
                                              fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('💡 ',
                                        style: TextStyle(fontSize: 16)),
                                    Expanded(
                                      child: Text(
                                        g.oneLine,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          height: 1.6,
                                          color: AppTheme.ink,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (g.dailyAnalogy.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cream,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('🥬 '),
                                        Expanded(
                                          child: Text(
                                            g.dailyAnalogy,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.6,
                                                color: AppTheme.ink2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// 可点的术语文本：点一下弹出一句话解释。
class TermText extends StatelessWidget {
  final String term;
  final TextStyle? style;
  const TermText(this.term, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GlossarySheet.open(context, initial: term),
      child: Text(
        term,
        style: (style ?? const TextStyle()).copyWith(
          color: AppTheme.primaryDark,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dashed,
          decorationColor: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
