import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:creators_grow/features/growth/presentation/notifiers/growth_notifier.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(growthNotifierProvider);

    if (state.isLoading && state.score == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              TextButton(
                onPressed: () => ref.read(growthNotifierProvider.notifier).refreshGrowthData(),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    final hasInsufficientData = state.score?.score == null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Creator Intelligence', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => ref.read(growthNotifierProvider.notifier).refreshGrowthData(),
          ),
        ],
      ),
      body: hasInsufficientData
          ? _buildInsufficientDataState(context)
          : RefreshIndicator(
              onRefresh: () => ref.read(growthNotifierProvider.notifier).refreshGrowthData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreCard(context, state),
                    const SizedBox(height: 24),
                    _buildRecommendationsList(context, state),
                    const SizedBox(height: 24),
                    _buildBestTimesSection(context, state),
                    const SizedBox(height: 24),
                    _buildContentAnalysisSection(context, state),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInsufficientDataState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.show_chart, size: 48, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 24),
            Text(
              'Not enough data yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'We need a bit more historical data to generate reliable insights. Keep publishing and check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF94A3B8), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, GrowthState state) {
    final score = state.score!;
    final trendColor = score.trend == 'up'
        ? Colors.greenAccent
        : (score.trend == 'down' ? Colors.redAccent : Colors.grey);
    final trendIcon = score.trend == 'up'
        ? Icons.trending_up
        : (score.trend == 'down' ? Icons.trending_down : Icons.remove);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Growth Score',
                style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(trendIcon, size: 14, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      '${score.change > 0 ? '+' : ''}${score.change}',
                      style: TextStyle(color: trendColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${score.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '/ 100',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Top Factors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...score.factors.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(f.name, style: const TextStyle(color: Color(0xFF94A3B8))),
                    Text('${f.score}/100', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(BuildContext context, GrowthState state) {
    if (state.recommendations == null || state.recommendations!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Actions',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...state.recommendations!.map((rec) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF818CF8), size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.recommendation,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rec.reason,
                          style: const TextStyle(color: Color(0xFF94A3B8), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildBestTimesSection(BuildContext context, GrowthState state) {
    if (state.bestTimes == null || state.bestTimes!.isEmpty) {
      return const SizedBox.shrink();
    }

    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best Times to Post',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            children: state.bestTimes!.take(3).map((time) {
              final isTop = state.bestTimes!.indexOf(time) == 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: isTop ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          '${days[time.dayOfWeek]}, ${time.hour}:00',
                          style: TextStyle(
                            color: isTop ? Colors.white : const Color(0xFF94A3B8),
                            fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 14, color: Colors.orangeAccent),
                        const SizedBox(width: 4),
                        Text(
                          '${time.score.toStringAsFixed(1)} score',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentAnalysisSection(BuildContext context, GrowthState state) {
    if (state.contentAnalysis == null || state.contentAnalysis!.formats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format Performance',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            children: state.contentAnalysis!.formats.map((f) {
              final isAboveAvg = f.averageEngagementRate > state.contentAnalysis!.overallAverageEngagement;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      f.format.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Text(
                          '${(f.averageEngagementRate * 100).toStringAsFixed(2)}% ER',
                          style: TextStyle(
                            color: isAboveAvg ? Colors.greenAccent : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isAboveAvg) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.trending_up, size: 14, color: Colors.greenAccent),
                        ]
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
