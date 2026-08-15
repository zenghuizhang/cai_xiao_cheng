import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// 小橙人吉祥物：一个圆滚滚的橙子，带不同表情。
class OrangeMascot extends StatelessWidget {
  final double size;
  final MascotMood mood;
  const OrangeMascot({super.key, this.size = 80, this.mood = MascotMood.happy});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(painter: _MascotPainter(mood)),
    );
  }
}

enum MascotMood { happy, celebrate, warn, sad, think }

class _MascotPainter extends CustomPainter {
  final MascotMood mood;
  _MascotPainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final bodyR = w * 0.42;
    final bodyCy = h * 0.55;

    // 叶子
    final leafPaint = Paint()..color = const Color(0xFF6FB47A);
    final stemPaint = Paint()
      ..color = const Color(0xFF5A7D4E)
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(cx, bodyCy - bodyR), Offset(cx, bodyCy - bodyR - h * 0.13), stemPaint);
    final leaf = Path()
      ..moveTo(cx, bodyCy - bodyR - h * 0.13)
      ..quadraticBezierTo(cx + w * 0.16, bodyCy - bodyR - h * 0.18,
          cx + w * 0.12, bodyCy - bodyR - h * 0.06)
      ..quadraticBezierTo(cx + w * 0.04, bodyCy - bodyR - h * 0.05, cx,
          bodyCy - bodyR - h * 0.1)
      ..close();
    canvas.drawPath(leaf, leafPaint);

    // 橙子身体
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 0.9,
        colors: [Color(0xFFFFB37A), AppTheme.primary],
      ).createShader(Rect.fromCircle(center: Offset(cx, bodyCy), radius: bodyR));
    canvas.drawCircle(Offset(cx, bodyCy), bodyR, bodyPaint);

    // 高光
    final hiPaint = Paint()..color = Colors.white.withOpacity(0.35);
    canvas.drawCircle(Offset(cx - bodyR * 0.35, bodyCy - bodyR * 0.4), bodyR * 0.18, hiPaint);

    final eyeDy = bodyCy - bodyR * 0.12;
    final eyeDx = bodyR * 0.32;
    final eyeR = w * 0.035;

    final eyePaint = Paint()..color = const Color(0xFF3D2B1F);
    final mouthPaint = Paint()
      ..color = const Color(0xFF3D2B1F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;

    switch (mood) {
      case MascotMood.celebrate:
        _drawEye(canvas, Offset(cx - eyeDx, eyeDy), eyeR, eyePaint, happy: true);
        _drawEye(canvas, Offset(cx + eyeDx, eyeDy), eyeR, eyePaint, happy: true);
        _drawMouth(canvas, cx, bodyCy + bodyR * 0.22, bodyR * 0.45, mouthPaint, smile: true);
        _drawBlush(canvas, cx, bodyCy, bodyR);
        break;
      case MascotMood.warn:
        canvas.drawCircle(Offset(cx - eyeDx, eyeDy), eyeR, eyePaint);
        canvas.drawCircle(Offset(cx + eyeDx, eyeDy), eyeR, eyePaint);
        _drawMouth(canvas, cx, bodyCy + bodyR * 0.3, bodyR * 0.3, mouthPaint, smile: false);
        final sweatPaint = Paint()..color = const Color(0xFF7FB8E8);
        canvas.drawCircle(Offset(cx + bodyR * 0.75, bodyCy - bodyR * 0.3), w * 0.03, sweatPaint);
        break;
      case MascotMood.sad:
        _drawEye(canvas, Offset(cx - eyeDx, eyeDy), eyeR, eyePaint, happy: true);
        _drawEye(canvas, Offset(cx + eyeDx, eyeDy), eyeR, eyePaint, happy: true);
        // 倒过来的嘴
        final p = Path()
          ..moveTo(cx - bodyR * 0.3, bodyCy + bodyR * 0.3)
          ..quadraticBezierTo(cx, bodyCy + bodyR * 0.1, cx + bodyR * 0.3, bodyCy + bodyR * 0.3);
        canvas.drawPath(p, mouthPaint);
        break;
      case MascotMood.think:
        canvas.drawCircle(Offset(cx - eyeDx, eyeDy), eyeR, eyePaint);
        canvas.drawCircle(Offset(cx + eyeDx, eyeDy), eyeR, eyePaint);
        final p = Path()
          ..moveTo(cx - bodyR * 0.18, bodyCy + bodyR * 0.25)
          ..lineTo(cx + bodyR * 0.18, bodyCy + bodyR * 0.25);
        canvas.drawPath(p, mouthPaint);
        break;
      case MascotMood.happy:
      default:
        canvas.drawCircle(Offset(cx - eyeDx, eyeDy), eyeR, eyePaint);
        canvas.drawCircle(Offset(cx + eyeDx, eyeDy), eyeR, eyePaint);
        _drawMouth(canvas, cx, bodyCy + bodyR * 0.18, bodyR * 0.4, mouthPaint, smile: true);
        _drawBlush(canvas, cx, bodyCy, bodyR);
    }
  }

  void _drawEye(Canvas canvas, Offset c, double r, Paint p, {required bool happy}) {
    if (happy) {
      final eye = Paint()
        ..color = p.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.9
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(c.dx - r, c.dy + r * 0.4)
        ..quadraticBezierTo(c.dx, c.dy - r, c.dx + r, c.dy + r * 0.4);
      canvas.drawPath(path, eye);
    } else {
      canvas.drawCircle(c, r, p);
    }
  }

  void _drawMouth(Canvas canvas, double cx, double cy, double r, Paint p,
      {required bool smile}) {
    final path = Path()
      ..moveTo(cx - r * 0.6, cy)
      ..quadraticBezierTo(cx, cy + (smile ? r * 0.8 : -r * 0.6), cx + r * 0.6, cy);
    canvas.drawPath(path, p);
  }

  void _drawBlush(Canvas canvas, double cx, double cy, double bodyR) {
    final blush = Paint()..color = const Color(0xFFFFB3A1).withOpacity(0.7);
    canvas.drawCircle(Offset(cx - bodyR * 0.62, cy + bodyR * 0.1), bodyR * 0.1, blush);
    canvas.drawCircle(Offset(cx + bodyR * 0.62, cy + bodyR * 0.1), bodyR * 0.1, blush);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.mood != mood;
}
