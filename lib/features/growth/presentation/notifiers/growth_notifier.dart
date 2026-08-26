import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:creators_grow/features/growth/data/repositories/growth_repository.dart';
import 'package:creators_grow/features/growth/domain/models/growth_models.dart';

class GrowthState {
  final GrowthScore? score;
  final List<BestTimeScore>? bestTimes;
  final ContentAnalysis? contentAnalysis;
  final List<GrowthRecommendation>? recommendations;
  final bool isLoading;
  final String? error;

  GrowthState({
    this.score,
    this.bestTimes,
    this.contentAnalysis,
    this.recommendations,
    this.isLoading = false,
    this.error,
  });

  GrowthState copyWith({
    GrowthScore? score,
    List<BestTimeScore>? bestTimes,
    ContentAnalysis? contentAnalysis,
    List<GrowthRecommendation>? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return GrowthState(
      score: score ?? this.score,
      bestTimes: bestTimes ?? this.bestTimes,
      contentAnalysis: contentAnalysis ?? this.contentAnalysis,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GrowthNotifier extends StateNotifier<GrowthState> {
  final GrowthRepository _repository;

  GrowthNotifier(this._repository) : super(GrowthState()) {
    refreshGrowthData();
  }

  Future<void> refreshGrowthData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final futures = await Future.wait([
        _repository.getGrowthScore(),
        _repository.getBestTimes(),
        _repository.getContentAnalysis(),
        _repository.getRecommendations(),
      ]);

      state = state.copyWith(
        score: futures[0] as GrowthScore,
        bestTimes: futures[1] as List<BestTimeScore>,
        contentAnalysis: futures[2] as ContentAnalysis,
        recommendations: futures[3] as List<GrowthRecommendation>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final growthNotifierProvider =
    StateNotifierProvider<GrowthNotifier, GrowthState>((ref) {
  return GrowthNotifier(ref.watch(growthRepositoryProvider));
});
