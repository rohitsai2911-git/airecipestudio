import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

class TactileButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double? width;
  final double? height;

  const TactileButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height ?? 52,
        transform: _isPressed ? Matrix4.translationValues(0, 2, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: [
            if (!_isPressed) AppShadows.vibrantButton,
          ],
          border: Border(
            bottom: BorderSide(
              color: _isPressed ? Colors.transparent : AppColors.vibrantButtonShadow,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.foregroundColor ?? AppColors.onPrimary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(widget.text, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: widget.foregroundColor ?? AppColors.onPrimary,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
