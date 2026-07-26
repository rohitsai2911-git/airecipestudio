import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class PocoAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool useGlass;

  const PocoAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.useGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.stackMd,
      ),
      decoration: useGlass
          ? BoxDecoration(
              color: AppColors.surface.withAlpha(204),
            )
          : const BoxDecoration(color: AppColors.surface),
      child: Row(
        children: [
          leading ?? Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.primary.withAlpha(25)),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary, fontWeight: FontWeight.bold,
          )),
          const Spacer(),
          ...?actions,
          if (actions == null)
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

class PocoGlassAppBar extends PocoAppBar {
  const PocoGlassAppBar({
    super.key,
    required super.title,
    super.leading,
    super.actions,
  }) : super(useGlass: true);
}
