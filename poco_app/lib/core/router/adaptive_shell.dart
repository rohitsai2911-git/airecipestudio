import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../design_system/widgets/poco_bottom_nav.dart';

class AdaptiveShell extends StatelessWidget {
  final Widget child;
  const AdaptiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 1024) {
          return _DesktopSidebar(child: child);
        } else if (width >= 768) {
          return _TabletNavRail(child: child);
        }
        return _MobileBottomNav(child: child);
      },
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final Widget child;
  const _MobileBottomNav({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final routes = PocoBottomNav.tabs.routes;
    for (int i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: PocoBottomNav(
        currentIndex: _currentIndex(context),
        onTap: (i) => context.go(PocoBottomNav.tabs.routes[i]),
      ),
    );
  }
}

class _TabletNavRail extends StatelessWidget {
  final Widget child;
  const _TabletNavRail({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final routes = PocoBottomNav.tabs.routes;
    for (int i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex(context),
          onDestinationSelected: (i) => context.go(PocoBottomNav.tabs.routes[i]),
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppColors.surface,
          selectedIconTheme: const IconThemeData(color: AppColors.primary),
          unselectedIconTheme: const IconThemeData(color: AppColors.onSurfaceVariant),
          selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          unselectedLabelTextStyle: const TextStyle(color: AppColors.onSurfaceVariant),
          destinations: List.generate(
            PocoBottomNav.tabs.labels.length,
            (i) => NavigationRailDestination(
              icon: Icon(PocoBottomNav.tabs.icons[i]),
              selectedIcon: Icon(PocoBottomNav.tabs.icons[i], fill: 1),
              label: Text(PocoBottomNav.tabs.labels[i]),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: child),
      ],
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  final Widget child;
  const _DesktopSidebar({required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final routes = PocoBottomNav.tabs.routes;
    for (int i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(right: BorderSide(color: AppColors.outlineVariant.withAlpha(51))),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.primary.withAlpha(25)),
                        ),
                        child: const Icon(Icons.pets, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.stackMd),
                      Text('Poco', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.bold,
                      )),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackMd),
                    itemCount: PocoBottomNav.tabs.labels.length,
                    itemBuilder: (context, i) {
                      final isActive = _currentIndex(context) == i;
                      return ListTile(
                        leading: Icon(
                          PocoBottomNav.tabs.icons[i],
                          fill: isActive ? 1 : 0,
                          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                        title: Text(
                          PocoBottomNav.tabs.labels[i],
                          style: TextStyle(
                            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        selected: isActive,
                        selectedTileColor: AppColors.primaryFixed.withAlpha(51),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        onTap: () => context.go(PocoBottomNav.tabs.routes[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
