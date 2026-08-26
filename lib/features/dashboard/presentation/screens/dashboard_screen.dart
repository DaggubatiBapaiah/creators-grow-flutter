import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../features/auth/domain/models/auth_state.dart';
import '../../../../features/auth/domain/notifiers/auth_notifier.dart';
import '../../../../features/onboarding/domain/notifiers/onboarding_notifier.dart';
import '../../../../features/social_accounts/presentation/notifiers/social_accounts_notifier.dart';
import '../../../../features/social_accounts/domain/models/social_platform.dart';
import '../../../../features/social_accounts/domain/models/social_account.dart';
import '../../../../features/content/presentation/screens/content_list_screen.dart';
import 'package:creators_grow/features/growth/presentation/screens/growth_screen.dart';
import '../../../../features/analytics/presentation/notifiers/analytics_notifier.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const _HomeTab(),
      const ContentListScreen(),
      const _PlaceholderTab(title: 'Advanced Analytics', icon: Icons.analytics_outlined),
      const GrowthScreen(),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: const Color(0xFF64748B),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library_rounded),
            label: 'Content',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  String _selectedTimeFilter = '7D';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final socialAccountsState = ref.watch(socialAccountsNotifierProvider);
    final analyticsState = ref.watch(dashboardStatsProvider);

    final displayName = authState is Authenticated
        ? authState.user.displayName
        : (onboardingState.displayName.isNotEmpty ? onboardingState.displayName : 'Creator');

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good morning, $displayName',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Here's what's happening with your content.",
                                style: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Notifications coming soon!')),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: const Color(0xFF6366F1),
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // RESPONSIVE LAYOUT
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildMainDashboardList(analyticsState),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildSideDashboardList(socialAccountsState),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._buildMainDashboardList(analyticsState),
                          const SizedBox(height: 24),
                          ..._buildSideDashboardList(socialAccountsState),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMainDashboardList(AsyncValue<DashboardStats> analyticsState) {
    return analyticsState.when(
      loading: () => [
        const Padding(
          padding: EdgeInsets.all(48.0),
          child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        )
      ],
      error: (err, stack) => [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Error loading stats: $err', style: const TextStyle(color: Colors.redAccent)),
        )
      ],
      data: (stats) {
        return [
          // SECTION 1 - GROWTH OVERVIEW
          const Text(
            'Growth Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 500 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _OverviewCard(title: 'Followers', value: '${stats.followersCount}', change: 'Total', isPositive: null),
                  _OverviewCard(title: 'Reach (24h)', value: '${stats.reach24h}', change: 'vs prior 24h', isPositive: null),
                  _OverviewCard(title: 'Posts Published', value: '${stats.publishedPosts}', change: 'All time', isPositive: null),
                  _OverviewCard(title: 'Posts Scheduled', value: '${stats.scheduledPosts}', change: 'Upcoming', isPositive: null),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // SECTION 3 - CONTENT PERFORMANCE CHART
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Performance',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Aggregated reach',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    // TIME SELECTOR
                    Row(
                      children: ['7D', '30D', '90D'].map((filter) {
                        final isSelected = _selectedTimeFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: const Color(0xFF6366F1),
                            backgroundColor: const Color(0xFF0F172A),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTimeFilter = filter;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (stats.history.isEmpty)
                  const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('No analytics data yet', style: TextStyle(color: Color(0xFF64748B))),
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      _getChartData(stats),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // SECTION 4 - CONTENT PIPELINE
          const Text(
            'Content Pipeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PipelineCard(
                  title: 'Drafts',
                  count: '${stats.draftPosts}',
                  icon: Icons.edit_note_rounded,
                  color: Colors.amber[600]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PipelineCard(
                  title: 'Scheduled',
                  count: '${stats.scheduledPosts}',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PipelineCard(
                  title: 'Published',
                  count: '${stats.publishedPosts}',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ];
      },
    );
  }

  List<Widget> _buildSideDashboardList(AsyncValue<List<SocialAccount>> socialAccountsState) {
    return [
      // SECTION 2 - QUICK ACTIONS
      const Text(
        'Quick Actions',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 12),
      ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _QuickActionTile(
            title: 'Create Post',
            icon: Icons.add_circle_outline_rounded,
            onTap: () => _navigateToPlaceholder(context, 'Create Post'),
          ),
          const SizedBox(height: 8),
          _QuickActionTile(
            title: 'Schedule Content',
            icon: Icons.schedule_rounded,
            onTap: () => context.push('/calendar'),
          ),
          const SizedBox(height: 8),
          _QuickActionTile(
            title: 'Connect Account',
            icon: Icons.add_link_rounded,
            onTap: () => context.push('/social-accounts'),
          ),
          const SizedBox(height: 8),
          _QuickActionTile(
            title: 'View Analytics',
            icon: Icons.bar_chart_rounded,
            onTap: () => _navigateToPlaceholder(context, 'View Analytics'),
          ),
        ],
      ),
      const SizedBox(height: 32),

      // NEW SECTION - SOCIAL ACCOUNTS STATUS
      const Text(
        'Social Accounts',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155), width: 0.5),
        ),
        child: Column(
          children: socialAccountsState.when(
            loading: () => [
              const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
            ],
            error: (err, _) => [
              const Text('Failed to load accounts.', style: TextStyle(color: Colors.redAccent))
            ],
            data: (accounts) {
              return SocialPlatform.values.map((platform) {
                final match = accounts.firstWhere(
                  (acc) => acc.platform == platform,
                  orElse: () => const SocialAccount(
                    id: '',
                    platform: SocialPlatform.instagram,
                    accountName: '',
                    platformAccountId: '',
                    status: 'disconnected',
                  ),
                );

                final String status = platform.isSupported
                    ? (match.id.isNotEmpty ? 'connected' : 'disconnected')
                    : 'coming_soon';

                return _SocialAccountStatusRow(
                  platform: platform.displayName,
                  status: status,
                  accountName: match.id.isNotEmpty ? match.accountName : null,
                );
              }).toList();
            },
          ),
        ),
      ),
      const SizedBox(height: 32),

      // SECTION 5 - CREATOR INSIGHT
      const Text(
        'Creator Insight',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155), width: 1),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Daily Strategy (Demo)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Your audience is responding strongly to educational content.',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Try publishing 2 more educational posts this week.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),

      // SECTION 6 - GROWTH LOOP
      const Text(
        'CreatorsGrow Loop',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          children: [
            _buildLoopItem('CONNECT', 'Link accounts & import records'),
            _buildLoopArrow(),
            _buildLoopItem('UNDERSTAND', 'Review key creator insights'),
            _buildLoopArrow(),
            _buildLoopItem('CREATE & PUBLISH', 'Build and distribute content'),
            _buildLoopArrow(),
            _buildLoopItem('MEASURE & GROW', 'Track visual performance loops'),
          ],
        ),
      ),
    ];
  }

  Widget _buildLoopItem(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoopArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Icon(Icons.arrow_downward, size: 14, color: Color(0xFF334155)),
    );
  }

  void _navigateToPlaceholder(BuildContext context, String actionName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(actionName)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.build_outlined, size: 72, color: Color(0xFF6366F1)),
                const SizedBox(height: 24),
                Text(
                  '$actionName dashboard is coming next.',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We are currently integrating backend data links.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LineChartData _getChartData(DashboardStats stats) {
    List<FlSpot> spots = [];
    int daysLimit = 7;
    if (_selectedTimeFilter == '30D') daysLimit = 30;
    if (_selectedTimeFilter == '90D') daysLimit = 90;

    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: daysLimit));

    // Filter historical data
    final filteredHistory = stats.history.where((p) {
      final pDate = DateTime.tryParse(p.date) ?? now;
      return pDate.isAfter(cutoff) || pDate.isAtSameMomentAs(cutoff);
    }).toList();

    // Map to spots (X: days ago from now, Y: reach)
    for (final point in filteredHistory) {
      final pDate = DateTime.tryParse(point.date) ?? now;
      final daysDiff = now.difference(pDate).inDays.toDouble();
      
      // We want X to be chronological, so 0 is oldest, or just map sequentially if sorted.
      // Assuming stats.history is sorted oldest to newest, we can just use index for X, or standard days.
      spots.add(FlSpot(daysLimit - daysDiff, point.reach.toDouble()));
    }

    if (spots.isEmpty) {
      // Just one empty spot if nothing
      spots.add(const FlSpot(0, 0));
    } else if (spots.length == 1) {
      // Add a 0 point so it draws a line
      spots.insert(0, FlSpot(spots[0].x - 1, 0));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Color(0xFF334155),
          strokeWidth: 0.5,
        ),
      ),
      titlesData: const FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: const Color(0xFF6366F1),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}

class _SocialAccountStatusRow extends StatelessWidget {
  final String platform;
  final String status;
  final String? accountName;

  const _SocialAccountStatusRow({
    required this.platform,
    required this.status,
    this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == 'connected';
    final isComingSoon = status == 'coming_soon';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            platform,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
          ),
          Text(
            isComingSoon
                ? 'Coming soon'
                : (isConnected ? 'Connected (@$accountName)' : 'Not connected'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isComingSoon
                  ? const Color(0xFF64748B)
                  : (isConnected ? const Color(0xFF10B981) : Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool? isPositive;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Row(
            children: [
              if (isPositive != null)
                Icon(
                  isPositive! ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 12,
                  color: isPositive! ? const Color(0xFF10B981) : Colors.red,
                ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 10,
                  color: isPositive == null
                      ? const Color(0xFF64748B)
                      : (isPositive! ? const Color(0xFF10B981) : Colors.red),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _PipelineCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              Text(
                count,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: const Color(0xFF6366F1)),
              const SizedBox(height: 24),
              const Text(
                'This feature is coming next.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'We are building core social API connections.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final onboardingState = ref.watch(onboardingNotifierProvider);

    final displayName = authState is Authenticated
        ? authState.user.displayName
        : (onboardingState.displayName.isNotEmpty ? onboardingState.displayName : 'Creator');

    final email = authState is Authenticated ? authState.user.email : '';
    final category = onboardingState.creatorCategory.isNotEmpty ? onboardingState.creatorCategory : 'Not Set';
    final goals = onboardingState.goals.isNotEmpty ? onboardingState.goals.join(', ') : 'Not Set';
    final platforms = onboardingState.selectedPlatforms.isNotEmpty ? onboardingState.selectedPlatforms.join(', ') : 'Not Set';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF6366F1),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                      style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Onboarding Setup Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildProfileDetailRow('Category', category),
            _buildProfileDetailRow('Goals', goals),
            _buildProfileDetailRow('Platforms', platforms),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
