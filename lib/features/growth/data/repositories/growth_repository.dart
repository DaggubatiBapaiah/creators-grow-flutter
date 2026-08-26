import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/core/network/api_client.dart';
import 'package:creators_grow/features/growth/domain/models/growth_models.dart';

final growthRepositoryProvider = Provider<GrowthRepository>((ref) {
  return GrowthRepository(ref.watch(dioProvider));
});

class GrowthRepository {
  final Dio _dio;

  GrowthRepository(this._dio);

  Future<GrowthScore> getGrowthScore() async {
    final response = await _dio.get('/api/v1/growth/score');
    return GrowthScore.fromJson(response.data);
  }

  Future<List<BestTimeScore>> getBestTimes() async {
    final response = await _dio.get('/api/v1/growth/best-times');
    final List<dynamic> data = response.data['bestTimes'] ?? [];
    return data.map((e) => BestTimeScore.fromJson(e)).toList();
  }

  Future<ContentAnalysis> getContentAnalysis() async {
    final response = await _dio.get('/api/v1/growth/content-analysis');
    // If unavailable (no formats), we can still map it, it just returns empty arrays
    if (response.data['analysis'] != null) {
      return ContentAnalysis.fromJson(response.data['analysis']);
    }
    return ContentAnalysis(formats: [], overallAverageEngagement: 0, overallAverageReach: 0);
  }

  Future<List<GrowthRecommendation>> getRecommendations() async {
    final response = await _dio.get('/api/v1/growth/recommendations');
    final List<dynamic> data = response.data['recommendations'] ?? [];
    return data.map((e) => GrowthRecommendation.fromJson(e)).toList();
  }
}
