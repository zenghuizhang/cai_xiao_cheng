// 首启引导页：3 页滑动介绍，完成后进主界面。
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      '🍊',
      '你好，我是财小橙',
      '一个把金融名词翻译成大白话的投资启蒙 App。\n不用懂术语，不用有基础，从零开始，慢慢来。',
    ),
    (
      '🗺️',
      '四步学习路径',
      '看懂通胀 → 分清工具 → 掌握定投 → 识破骗局。\n每章 30 张知识卡 + 闯关测验，学完还有果实收获。',
    ),
    (
      '🛡️',
      '三个承诺',
      '不荐股、不承诺收益、纯教学。\n所有收益均为假设示例，不构成投资建议。',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 完成引导：写库后 SplashGate 监听到状态变化自动切到主界面。
  Future<void> _finish() async {
    await context.read<AppState>().finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('跳过',
                    style: TextStyle(color: AppTheme.ink2)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final (emoji, title, desc) = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 88)),
                        const SizedBox(height: 28),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.ink)),
                        const SizedBox(height: 14),
                        Text(
                          desc,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15,
                              height: 1.8,
                              color: AppTheme.ink2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 指示点
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppTheme.primary : AppTheme.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  child: Text(isLast ? '开始学习 🍊' : '下一步'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
