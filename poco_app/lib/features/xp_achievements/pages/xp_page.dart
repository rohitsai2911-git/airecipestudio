import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/design_system/widgets/poco_app_bar.dart';
import '../providers/xp_provider.dart';
import '../widgets/progress_ring_svg.dart';
import '../widgets/achievement_bento_grid.dart';
import '../widgets/activity_feed.dart';

class XpPage extends ConsumerWidget {
  const XpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = ref.watch(xpProvider);
    final level = ref.watch(levelProvider);
    final xpToNext = ref.watch(xpToNextLevelProvider);
    final progress = xp / xpToNext;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: PocoAppBar(title: 'XP & Achievements'),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackLg),
                  child: XpProgressRing(
                    progress: progress,
                    size: 140,
                    currentXp: xp,
                    xpToNextLevel: xpToNext,
                    strokeWidth: 12,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'Level $level',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerPadding,
                  AppSpacing.stackLg,
                  AppSpacing.containerPadding,
                  AppSpacing.stackMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Achievements',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
              sliver: SliverToBoxAdapter(
                child: AchievementBentoGrid(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerPadding,
                  AppSpacing.stackLg,
                  AppSpacing.containerPadding,
                  AppSpacing.stackMd,
                ),
                child: Text(
                  'Activity',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
              sliver: SliverToBoxAdapter(
                child: ActivityFeed(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.stackLg),
            ),
          ],
        ),
      ),
    );
  }
}
