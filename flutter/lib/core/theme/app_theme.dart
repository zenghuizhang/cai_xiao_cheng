import 'package:flutter/material.dart';

/// 视觉规范：暖橙 #FF8C42 + 奶白 #FFF8F0，营造温暖、安全、放松的阅读氛围。
/// 正文 18px、行高 1.8（要求项），全 App 禁用股票软件的大红大绿作为主基调。
class AppTheme {
  static const Color primary = Color(0xFFFF8C42); // 暖橙主色
  static const Color primaryDark = Color(0xFFE5732A);
  static const Color cream = Color(0xFFFFF8F0); // 奶白背景
  static const Color card = Colors.white;
  static const Color ink = Color(0xFF3D2B1F); // 暖棕黑，比纯黑柔和
  static const Color ink2 = Color(0xFF8A7A6D);
  static const Color line = Color(0xFFF0E6D8);
  static const Color success = Color(0xFF6FB47A); // 柔绿，答对用
  static const Color danger = Color(0xFFE86A5C); // 暴跌红，克制使用
  static const Color warnSoft = Color(0xFFFFEBDC);
  static const Color greenSoft = Color(0xFFE6F4E9);

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: cream,
      ),
      scaffoldBackgroundColor: cream,
      fontFamily: null,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: line, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: line, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        // 正文统一偏大 16-18px，行高 1.8（阅读友好）
        bodyLarge: const TextStyle(
          fontSize: 18,
          height: 1.8,
          color: ink,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          height: 1.8,
          color: ink,
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: ink,
          height: 1.3,
        ),
        titleMedium: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      dividerColor: line,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: ink2,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
    );
  }

  /// 段位配色
  static const Map<int, Color> levelColor = {
    1: Color(0xFFCD7F32), // 青铜
    2: Color(0xFF9AA7B0), // 白银
    3: Color(0xFFE5A83B), // 黄金
    4: Color(0xFF7B6BD6), // 铂金
  };
  static const Map<int, String> levelTitle = {
    1: "青铜小白",
    2: "白银学徒",
    3: "黄金规划师",
    4: "铂金守心人",
  };
}
