import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ServingsSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const ServingsSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$value', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.primary, fontWeight: FontWeight.bold,
        )),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              thumbShape: _CustomThumbShape(),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.outlineVariant,
              overlayColor: AppColors.primary.withAlpha(25),
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: value.toString(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(28, 28);

  @override
  void paint(PaintingContext context, Offset center, {required Animation<double> activationAnimation, required Animation<double> enableAnimation, required bool isDiscrete, required TextPainter labelPainter, required RenderBox parentBox, required SliderThemeData sliderTheme, required TextDirection textDirection, required double value, required double textScaleFactor, required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    final paint = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, 14, paint);
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, 14, borderPaint);
  }
}
