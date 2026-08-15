import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CaiXiaoChengApp());
}

class CaiXiaoChengApp extends StatelessWidget {
  const CaiXiaoChengApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: '财小橙 · 投资启蒙',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const SplashGate(),
      ),
    );
  }
}

/// 首启加载：读 JSON 灌库 + 等待 Provider 初始化
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.loaded) {
          return Scaffold(
            backgroundColor: AppTheme.cream,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🍊', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  const Text('财小橙',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark)),
                  const SizedBox(height: 8),
                  const Text('从零开始，慢慢变富',
                      style: TextStyle(color: AppTheme.ink2)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: AppTheme.line,
                      valueColor: const AlwaysStoppedAnimation(
                          AppTheme.primary),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // 首启引导
        if (!state.onboardingDone) {
          return const OnboardingScreen();
        }
        return const MainShell();
      },
    );
  }
}
