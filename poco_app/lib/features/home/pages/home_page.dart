import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../widgets/greeting_section.dart';
import '../widgets/hero_recipe_card.dart';
import '../widgets/seasonal_scroll.dart';
import '../widgets/quick_scan_grid.dart';
import '../../../core/design_system/widgets/poco_mascot_tip.dart';
import '../../../core/design_system/widgets/poco_fab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar(context)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GreetingSection(),
                        const SizedBox(height: AppSpacing.stackLg),
                        const HeroRecipeCard(),
                        const SizedBox(height: AppSpacing.stackLg),
                        const SeasonalScroll(),
                        const SizedBox(height: AppSpacing.stackLg),
                        const QuickScanGrid(),
                        const SizedBox(height: AppSpacing.stackLg),
                        const PocoMascotTip(
                          tip: "You've used garlic in your last 3 meals. Try swapping it for shallots in your next dish for a more delicate, sweet aroma!",
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const PocoFab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: AppSpacing.stackMd),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.primary.withAlpha(25)),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Text('Poco', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary, fontWeight: FontWeight.bold,
          )),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
