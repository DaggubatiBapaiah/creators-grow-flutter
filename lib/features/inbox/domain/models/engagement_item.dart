class EngagementItem {
  final String id;
  final String userId;
  final String socialAccountId;
  final String platform;
  final String itemType; // 'comment' | 'reply' | 'mention'
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final String externalId;
  final String? parentExternalId;
  final String? postExternalId;
  final bool isRead;
  final bool isReplied;
  final int likeCount;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EngagementItem({
    required this.id,
    required this.userId,
    required this.socialAccountId,
    required this.platform,
    required this.itemType,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.externalId,
    this.parentExternalId,
    this.postExternalId,
    required this.isRead,
    required this.isReplied,
    required this.likeCount,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EngagementItem.fromJson(Map<String, dynamic> json) {
    return EngagementItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      socialAccountId: json['social_account_id'] as String,
      platform: json['platform'] as String,
      itemType: json['item_type'] as String,
      authorName: json['author_name'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      content: json['content'] as String,
      externalId: json['external_id'] as String,
      parentExternalId: json['parent_external_id'] as String?,
      postExternalId: json['post_external_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      isReplied: json['is_replied'] as bool? ?? false,
      likeCount: json['like_count'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  bool get isLiked => metadata?['isLiked'] == true;
  bool get isHidden => metadata?['isHidden'] == true;

  EngagementItem copyWith({
    String? id,
    String? userId,
    String? socialAccountId,
    String? platform,
    String? itemType,
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    String? externalId,
    String? parentExternalId,
    String? postExternalId,
    bool? isRead,
    bool? isReplied,
    int? likeCount,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EngagementItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      socialAccountId: socialAccountId ?? this.socialAccountId,
      platform: platform ?? this.platform,
      itemType: itemType ?? this.itemType,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      externalId: externalId ?? this.externalId,
      parentExternalId: parentExternalId ?? this.parentExternalId,
      postExternalId: postExternalId ?? this.postExternalId,
      isRead: isRead ?? this.isRead,
      isReplied: isReplied ?? this.isReplied,
      likeCount: likeCount ?? this.likeCount,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
