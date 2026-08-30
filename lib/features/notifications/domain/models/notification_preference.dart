class NotificationPreference {
  final String category;
  final bool emailEnabled;
  final bool pushEnabled;
  final bool inAppEnabled;

  const NotificationPreference({
    required this.category,
    required this.emailEnabled,
    required this.pushEnabled,
    required this.inAppEnabled,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      category: json['category'] as String,
      emailEnabled: json['email_enabled'] as bool? ?? true,
      pushEnabled: json['push_enabled'] as bool? ?? true,
      inAppEnabled: json['in_app_enabled'] as bool? ?? true,
    );
  }

  NotificationPreference copyWith({
    String? category,
    bool? emailEnabled,
    bool? pushEnabled,
    bool? inAppEnabled,
  }) {
    return NotificationPreference(
      category: category ?? this.category,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
    );
  }
}
