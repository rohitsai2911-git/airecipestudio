import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class XpProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final int currentXp;
  final int xpToNextLevel;

  const XpProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    required this.currentXp,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress.clamp(0, 1), strokeWidth: strokeWidth),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$currentXp', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold,
              )),
              Text('/ $xpToNextLevel', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFFE4E2E1);
    canvas.drawCircle(center, radius, paint);

    paint.color = AppColors.primary;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
