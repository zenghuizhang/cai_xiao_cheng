import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// 圆形进度条，用于学习页顶部显示本章完成度。
class CircleProgress extends StatelessWidget {
  final double progress; // 0~1
  final double size;
  final String? label;
  const CircleProgress({
    super.key,
    required this.progress,
    this.size = 64,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(p),
          ),
          Text(
            label ?? '${(p * 100).round()}%',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double p;
  _RingPainter(this.p);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final bg = Paint()
      ..color = AppTheme.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..shader = const SweepGradient(
        startAngle: 0,
        endAngle: 6.283,
        colors: [AppTheme.primary, Color(0xFFFFB347)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.283 * p,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.p != p;
}
