import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/design_system/widgets/activity_item.dart';

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ActivityItem(
          icon: Icons.check_circle,
          title: 'Completed Pasta Carbonara',
          xpAmount: '50',
          timestamp: '2h ago',
          iconColor: AppColors.primary,
        ),
        ActivityItem(
          icon: Icons.emoji_events,
          title: "Earned 'First Recipe' badge",
          xpAmount: '25',
          timestamp: '1d ago',
        ),
        ActivityItem(
          icon: Icons.explore,
          title: 'Tried new cuisine',
          xpAmount: '10',
          timestamp: '2d ago',
        ),
        ActivityItem(
          icon: Icons.local_fire_department,
          title: 'Maintained streak',
          xpAmount: '100',
          timestamp: '3d ago',
          iconColor: AppColors.secondary,
        ),
      ],
    );
  }
}
