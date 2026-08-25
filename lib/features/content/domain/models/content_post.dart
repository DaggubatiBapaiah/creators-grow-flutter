import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_post.freezed.dart';
part 'content_post.g.dart';

@freezed
class ContentPost with _$ContentPost {
  const factory ContentPost({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'social_account_id') required String socialAccountId,
    required String platform,
    String? caption,
    @JsonKey(name: 'media_ids') @Default([]) List<String> mediaIds,
    required String status,
    @JsonKey(name: 'scheduled_at') DateTime? scheduledAt,
    @JsonKey(name: 'published_at') DateTime? publishedAt,
    @JsonKey(name: 'external_post_id') String? externalPostId,
    @JsonKey(name: 'failure_reason') String? failureReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ContentPost;

  factory ContentPost.fromJson(Map<String, dynamic> json) => _$ContentPostFromJson(json);
}
