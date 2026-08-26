import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/analytics_repository.dart';

class HistoryPoint {
  final String date;
  final int reach;
  
  HistoryPoint({required this.date, required this.reach});
  
  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    return HistoryPoint(
      date: json['date'] as String,
      reach: (json['reach'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardStats {
  final int connectedAccounts;
  final int scheduledPosts;
  final int publishedPosts;
  final int draftPosts;
  final int failedPosts;
  final int followersCount;
  final int reach24h;
  final int impressions24h;
  final List<HistoryPoint> history;

  DashboardStats({
    required this.connectedAccounts,
    required this.scheduledPosts,
    required this.publishedPosts,
    required this.draftPosts,
    required this.failedPosts,
    required this.followersCount,
    required this.reach24h,
    required this.impressions24h,
    required this.history,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final historyList = (json['history'] as List<dynamic>?) ?? [];
    return DashboardStats(
      connectedAccounts: json['connectedAccounts'] ?? 0,
      scheduledPosts: json['scheduledPosts'] ?? 0,
      publishedPosts: json['publishedPosts'] ?? 0,
      draftPosts: json['draftPosts'] ?? 0,
      failedPosts: json['failedPosts'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      reach24h: json['reach24h'] ?? 0,
      impressions24h: json['impressions24h'] ?? 0,
      history: historyList.map((e) => HistoryPoint.fromJson(e)).toList(),
    );
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnalyticsRepository(dio);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final data = await repo.getDashboardStats();
  return DashboardStats.fromJson(data);
});

final topPostsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final data = await repo.getTopPosts();
  return data['topPosts'] as List<dynamic>;
});
