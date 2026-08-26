class GrowthFactor {
  final String name;
  final num score;
  final num weight;

  GrowthFactor({
    required this.name,
    required this.score,
    required this.weight,
  });

  factory GrowthFactor.fromJson(Map<String, dynamic> json) {
    return GrowthFactor(
      name: json['name'] as String,
      score: json['score'] as num,
      weight: json['weight'] as num,
    );
  }
}

class GrowthScore {
  final num? score;
  final String trend;
  final num change;
  final List<GrowthFactor> factors;

  GrowthScore({
    required this.score,
    required this.trend,
    required this.change,
    required this.factors,
  });

  factory GrowthScore.fromJson(Map<String, dynamic> json) {
    return GrowthScore(
      score: json['score'] as num?,
      trend: json['trend'] as String? ?? 'none',
      change: json['change'] as num? ?? 0,
      factors: (json['factors'] as List<dynamic>?)
              ?.map((e) => GrowthFactor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BestTimeScore {
  final String platform;
  final int dayOfWeek;
  final int hour;
  final num score;
  final int sampleSize;

  BestTimeScore({
    required this.platform,
    required this.dayOfWeek,
    required this.hour,
    required this.score,
    required this.sampleSize,
  });

  factory BestTimeScore.fromJson(Map<String, dynamic> json) {
    return BestTimeScore(
      platform: json['platform'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      hour: json['hour'] as int,
      score: json['score'] as num,
      sampleSize: json['sampleSize'] as int,
    );
  }
}

class ContentFormatPerformance {
  final String format;
  final num averageEngagementRate;
  final num averageReach;
  final num averageSaves;
  final int sampleSize;

  ContentFormatPerformance({
    required this.format,
    required this.averageEngagementRate,
    required this.averageReach,
    required this.averageSaves,
    required this.sampleSize,
  });

  factory ContentFormatPerformance.fromJson(Map<String, dynamic> json) {
    return ContentFormatPerformance(
      format: json['format'] as String,
      averageEngagementRate: json['averageEngagementRate'] as num,
      averageReach: json['averageReach'] as num,
      averageSaves: json['averageSaves'] as num,
      sampleSize: json['sampleSize'] as int,
    );
  }
}

class ContentAnalysis {
  final List<ContentFormatPerformance> formats;
  final num overallAverageEngagement;
  final num overallAverageReach;

  ContentAnalysis({
    required this.formats,
    required this.overallAverageEngagement,
    required this.overallAverageReach,
  });

  factory ContentAnalysis.fromJson(Map<String, dynamic> json) {
    return ContentAnalysis(
      formats: (json['formats'] as List<dynamic>?)
              ?.map((e) => ContentFormatPerformance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      overallAverageEngagement: json['overallAverageEngagement'] as num? ?? 0,
      overallAverageReach: json['overallAverageReach'] as num? ?? 0,
    );
  }
}

class GrowthRecommendationMetric {
  final String name;
  final num value;
  final num baseline;

  GrowthRecommendationMetric({
    required this.name,
    required this.value,
    required this.baseline,
  });

  factory GrowthRecommendationMetric.fromJson(Map<String, dynamic> json) {
    return GrowthRecommendationMetric(
      name: json['name'] as String,
      value: json['value'] as num,
      baseline: json['baseline'] as num,
    );
  }
}

class GrowthRecommendation {
  final String category;
  final String recommendation;
  final String reason;
  final GrowthRecommendationMetric metric;
  final num confidence;

  GrowthRecommendation({
    required this.category,
    required this.recommendation,
    required this.reason,
    required this.metric,
    required this.confidence,
  });

  factory GrowthRecommendation.fromJson(Map<String, dynamic> json) {
    return GrowthRecommendation(
      category: json['category'] as String,
      recommendation: json['recommendation'] as String,
      reason: json['reason'] as String,
      metric: GrowthRecommendationMetric.fromJson(json['metric'] as Map<String, dynamic>),
      confidence: json['confidence'] as num,
    );
  }
}
