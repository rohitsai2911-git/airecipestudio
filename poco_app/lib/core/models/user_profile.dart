class UserProfile {
  final String id;
  final String userId;
  final String name;
  final bool dietaryPref;
  final bool mealPlanningPref;
  final bool notificationsPref;
  final bool darkMode;
  final int xp;
  final int level;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.dietaryPref,
    required this.mealPlanningPref,
    required this.notificationsPref,
    required this.darkMode,
    required this.xp,
    required this.level,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String? ?? '',
    dietaryPref: json['dietary_pref'] as bool? ?? false,
    mealPlanningPref: json['meal_planning_pref'] as bool? ?? true,
    notificationsPref: json['notifications_pref'] as bool? ?? true,
    darkMode: json['dark_mode'] as bool? ?? false,
    xp: json['xp'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
