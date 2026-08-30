class NotificationItem {
  final String id;
  final String userId;
  final String category;
  final String title;
  final String body;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    required this.body,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
