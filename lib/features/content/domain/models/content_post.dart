class ContentPost {
  final String id;
  final String userId;
  final String socialAccountId;
  final String platform;
  final String? caption;
  final List<String> mediaIds;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final String? externalPostId;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentPost({
    required this.id,
    required this.userId,
    required this.socialAccountId,
    required this.platform,
    this.caption,
    this.mediaIds = const [],
    required this.status,
    this.scheduledAt,
    this.publishedAt,
    this.externalPostId,
    this.failureReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentPost.fromJson(Map<String, dynamic> json) {
    return ContentPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      socialAccountId: json['social_account_id'] as String,
      platform: json['platform'] as String,
      caption: json['caption'] as String?,
      mediaIds: (json['media_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      status: json['status'] as String,
      scheduledAt: json['scheduled_at'] != null ? DateTime.parse(json['scheduled_at'] as String) : null,
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at'] as String) : null,
      externalPostId: json['external_post_id'] as String?,
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'social_account_id': socialAccountId,
      'platform': platform,
      'caption': caption,
      'media_ids': mediaIds,
      'status': status,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'external_post_id': externalPostId,
      'failure_reason': failureReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ContentPost copyWith({
    String? id,
    String? userId,
    String? socialAccountId,
    String? platform,
    String? caption,
    List<String>? mediaIds,
    String? status,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    String? externalPostId,
    String? failureReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      socialAccountId: socialAccountId ?? this.socialAccountId,
      platform: platform ?? this.platform,
      caption: caption ?? this.caption,
      mediaIds: mediaIds ?? this.mediaIds,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      publishedAt: publishedAt ?? this.publishedAt,
      externalPostId: externalPostId ?? this.externalPostId,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
