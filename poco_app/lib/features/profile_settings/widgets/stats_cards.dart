import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

class StatsCards extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsCards({
    super.key,
    required this.stats,
  });

  static const List<_StatConfig> _configs = [
    _StatConfig(icon: Icons.menu_book, key: 'recipes', label: 'Recipes'),
    _StatConfig(icon: Icons.access_time, key: 'time', label: 'Total time'),
    _StatConfig(icon: Icons.military_tech, key: 'xp', label: 'XP'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
      child: Row(
        children: _configs.map((cfg) {
          final value = stats[cfg.key];
          final displayValue = value is int ? _formatNumber(value) : value.toString();

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [AppShadows.card],
              ),
              child: Column(
                children: [
                  Icon(cfg.icon, color: AppColors.primary, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    displayValue,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cfg.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return n.toString();
  }
}

class _StatConfig {
  final IconData icon;
  final String key;
  final String label;

  const _StatConfig({
    required this.icon,
    required this.key,
    required this.label,
  });
}
