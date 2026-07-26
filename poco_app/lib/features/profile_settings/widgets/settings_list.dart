import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsList extends StatelessWidget {
  final bool dietaryPref;
  final bool mealPlanningPref;
  final bool notificationsPref;
  final bool isDarkMode;
  final ValueChanged<bool> onDietaryChanged;
  final ValueChanged<bool> onMealPlanningChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onLogout;

  const SettingsList({
    super.key,
    required this.dietaryPref,
    required this.mealPlanningPref,
    required this.notificationsPref,
    required this.isDarkMode,
    required this.onDietaryChanged,
    required this.onMealPlanningChanged,
    required this.onNotificationsChanged,
    required this.onDarkModeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Dietary Preferences'),
          subtitle: const Text('Manage allergies & restrictions'),
          value: dietaryPref,
          onChanged: onDietaryChanged,
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Meal Planning'),
          subtitle: const Text('Weekly meal plan reminders'),
          value: mealPlanningPref,
          onChanged: onMealPlanningChanged,
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Notifications'),
          subtitle: const Text('Push alerts & suggestions'),
          value: notificationsPref,
          onChanged: onNotificationsChanged,
          activeColor: AppColors.primary,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.dark_mode, color: AppColors.onSurfaceVariant),
          title: const Text('Dark Mode'),
          trailing: Switch(
            value: isDarkMode,
            onChanged: onDarkModeChanged,
            activeColor: AppColors.primary,
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text(
            'Log out',
            style: TextStyle(color: AppColors.error),
          ),
          onTap: onLogout,
        ),
      ],
    );
  }
}
