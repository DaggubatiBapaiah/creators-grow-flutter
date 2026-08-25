import 'social_platform.dart';

class SocialAccount {
  final String id;
  final SocialPlatform platform;
  final String accountName;
  final String platformAccountId;
  final String? profileImageUrl;
  final String status;

  const SocialAccount({
    required this.id,
    required this.platform,
    required this.accountName,
    required this.platformAccountId,
    this.profileImageUrl,
    required this.status,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    final platformStr = json['platform'] as String;
    final platform = SocialPlatform.values.firstWhere(
      (e) => e.name.toLowerCase() == platformStr.toLowerCase(),
      orElse: () => SocialPlatform.instagram,
    );

    return SocialAccount(
      id: json['id'] as String,
      platform: platform,
      accountName: json['accountName'] as String,
      platformAccountId: json['platformAccountId'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform.name,
      'accountName': accountName,
      'platformAccountId': platformAccountId,
      'profileImageUrl': profileImageUrl,
      'status': status,
    };
  }
}