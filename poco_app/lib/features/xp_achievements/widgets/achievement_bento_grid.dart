import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/achievement_card.dart';

class AchievementBentoGrid extends StatelessWidget {
  const AchievementBentoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AchievementCard(
            title: 'First Recipe',
            description: 'Complete your first recipe',
            icon: Icons.restaurant,
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Row(
          children: [
            Expanded(
              child: AchievementCard(
                title: '5 Day Streak',
                description: 'Cook 5 days in a row',
                icon: Icons.local_fire_department,
                iconColor: const Color(0xFFAB3500),
              ),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: AchievementCard(
                title: 'Master Chef',
                description: 'Complete 25 recipes',
                icon: Icons.emoji_events,
                iconColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackMd),
        SizedBox(
          width: double.infinity,
          child: AchievementCard(
            title: 'Spice Explorer',
            description: 'Try 10 different cuisines',
            icon: Icons.explore,
            iconColor: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Row(
          children: [
            Expanded(
              child: AchievementCard(
                title: 'Quick Cook',
                description: 'Finish a meal in 15 min',
                icon: Icons.timer,
                iconColor: const Color(0xFF78DC77),
              ),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: AchievementCard(
                title: 'Meal Planner',
                description: 'Plan 7 days of meals',
                icon: Icons.calendar_today,
                iconColor: const Color(0xFFFFDBD0),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
