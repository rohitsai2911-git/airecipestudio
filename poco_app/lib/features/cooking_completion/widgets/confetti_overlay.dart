import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ConfettiOverlay extends StatelessWidget {
  const ConfettiOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ConfettiDot(delay: 0, color: AppColors.primaryContainer),
          _ConfettiDot(delay: 200, color: Color(0xFFAB3500)),
          _ConfettiDot(delay: 400, color: Color(0xFFFFDBD0)),
          _ConfettiDot(delay: 600, color: AppColors.secondary),
          _ConfettiDot(delay: 800, color: Color(0xFF78DC77)),
        ],
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  final int delay;
  final Color color;

  const _ConfettiDot({
    required this.delay,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2000),
      curve: Interval(delay / 2000.0, 1.0, curve: Curves.easeOut),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
