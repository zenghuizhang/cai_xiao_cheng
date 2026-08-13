import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/simulation/simulation_screen.dart';
import 'features/assets/assets_screen.dart';
import 'widgets/glossary_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    LearnScreen(),
    SimulationScreen(),
    AssetsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '首页'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style),
              label: '学习'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.casino_outlined),
              activeIcon: Icon(Icons.casino),
              label: '模拟'),
          BottomNavigationBarItem(
            icon: _buildPointsIcon(state.totalPoints, false),
            activeIcon: _buildPointsIcon(state.totalPoints, true),
            label: '我的',
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () => GlossarySheet.open(context),
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryDark,
              elevation: 4,
              icon: const Icon(Icons.search, color: AppTheme.primary),
              label: const Text('查词',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPointsIcon(int points, bool active) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.person : Icons.person_outline),
        Positioned(
          right: -8,
          top: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: const BoxConstraints(minWidth: 16),
            child: Text(
              '$points',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
