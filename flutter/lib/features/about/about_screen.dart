import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 关于与免责声明。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于与免责声明')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text('🍊', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text('财小橙',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ink)),
            ),
            const Center(
              child: Text('给零基础小白的投资认知启蒙 · v1.0.0',
                  style: TextStyle(color: AppTheme.ink2, fontSize: 13)),
            ),
            const SizedBox(height: 24),
            _section('这是什么 App', [
              '财小橙是一个【纯教学、纯本地】的投资认知启蒙应用。',
              '它不连接服务器，不收集你的任何信息，也不提供任何真实交易、开户或实时行情。',
              '我们只想帮你在 7 天里，用大白话搞懂：钱为什么会贬值、常见理财工具怎么回事、定投是什么、以及怎么躲开骗局。',
            ]),
            _section('重要免责声明', [
              '1. 本 App 内所有数字（收益率、通胀率、模拟涨跌等）均为【假设性教学示例】，不是预测，更不是承诺。',
              '2. 定投计算器使用固定年化的理想公式，真实市场有涨有跌，结果仅供理解原理。',
              '3. 本 App 不构成任何投资建议、招揽或邀约。任何投资决策请基于你自己的判断，并咨询持牌专业人士。',
              '4. 投资有风险，入市需谨慎；永远只用 3–5 年用不到的闲钱投资。',
            ], danger: true),
            _section('隐私说明', [
              'App 不申请联网权限，不读取通讯录、位置等敏感信息。',
              '你的学习进度、积分、打卡记录只保存在本机的 SQLite 数据库里，卸载 App 即会清除。',
            ]),
            _section('内容怎么更新', [
              '所有课程、题目、模拟场景都打包在 assets/data/knowledge_base.json 中。',
              '更新内容只需替换该 JSON（同时递增 content_version 以触发重新灌库），再重新打包即可，无需改动代码。',
            ]),
            const SizedBox(height: 24),
            const Center(
              child: Text('慢慢来，比较快 🍊',
                  style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<String> bullets, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: danger ? AppTheme.danger : AppTheme.ink)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: danger ? const Color(0xFFFDECEA) : AppTheme.warnSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final b in bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(b,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: danger
                                ? const Color(0xFFB4452F)
                                : const Color(0xFF7A4A1F))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
