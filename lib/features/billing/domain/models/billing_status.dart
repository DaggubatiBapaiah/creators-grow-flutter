class BillingStatus {
  final String planCode;
  final String status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final int connectedAccounts;
  final int maxSocialAccounts;
  final int scheduledPostsUsed;
  final int maxScheduledPosts;
  final int aiGenerationsUsed;
  final int maxAiGenerations;
  final bool hasCrmAccess;
  final bool hasGrowthIntelligence;
  final bool hasMediaKitCustomization;

  const BillingStatus({
    required this.planCode,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.connectedAccounts,
    required this.maxSocialAccounts,
    required this.scheduledPostsUsed,
    required this.maxScheduledPosts,
    required this.aiGenerationsUsed,
    required this.maxAiGenerations,
    required this.hasCrmAccess,
    required this.hasGrowthIntelligence,
    required this.hasMediaKitCustomization,
  });

  factory BillingStatus.fromJson(Map<String, dynamic> json) {
    final statusMap = json['status'] as Map<String, dynamic>;
    final usage = statusMap['usage'] as Map<String, dynamic>;
    final limits = statusMap['limits'] as Map<String, dynamic>;

    return BillingStatus(
      planCode: statusMap['planCode'] as String,
      status: statusMap['status'] as String,
      currentPeriodStart: DateTime.parse(statusMap['currentPeriodStart'] as String),
      currentPeriodEnd: DateTime.parse(statusMap['currentPeriodEnd'] as String),
      cancelAtPeriodEnd: statusMap['cancelAtPeriodEnd'] as bool? ?? false,
      connectedAccounts: usage['connectedAccounts'] as int,
      maxSocialAccounts: limits['maxSocialAccounts'] as int,
      scheduledPostsUsed: usage['scheduledPostsUsed'] as int,
      maxScheduledPosts: limits['maxScheduledPosts'] as int,
      aiGenerationsUsed: usage['aiGenerationsUsed'] as int,
      maxAiGenerations: limits['maxAiGenerations'] as int,
      hasCrmAccess: limits['hasCrmAccess'] as bool? ?? false,
      hasGrowthIntelligence: limits['hasGrowthIntelligence'] as bool? ?? false,
      hasMediaKitCustomization: limits['hasMediaKitCustomization'] as bool? ?? false,
    );
  }

  String get displayName {
    switch (planCode.toLowerCase()) {
      case 'creator':
        return 'Creator';
      case 'pro':
        return 'Pro';
      default:
        return 'Free';
    }
  }

  bool get isPaid => planCode.toLowerCase() != 'free';
}
