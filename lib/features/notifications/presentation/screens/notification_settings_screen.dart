import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_preference.dart';
import '../notifiers/notification_notifier.dart';
import '../../../../core/theme/app_theme.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  static const List<Map<String, String>> categoriesList = [
    {
      'id': 'publishing',
      'title': 'Publishing Updates',
      'desc': 'Scheduled posts successfully published or failed alerts'
    },
    {
      'id': 'account_security',
      'title': 'Account Security',
      'desc': 'Social platform tokens expired or security logins'
    },
    {
      'id': 'usage_limits',
      'title': 'Usage Limits',
      'desc': 'Alerts when AI tokens or features quota are near maximum'
    },
    {
      'id': 'growth',
      'title': 'Growth milestones',
      'desc': 'Follower increments and content analytics insights'
    },
    {
      'id': 'crm',
      'title': 'Brand Deals CRM',
      'desc': 'Pitch responses and sponsor follow-up reminders'
    },
    {
      'id': 'mediakit',
      'title': 'Media Kit Views',
      'desc': 'Live notifications when brand representatives check your media kit'
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: state.isLoading && state.preferences.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : RefreshIndicator(
              onRefresh: () => ref.read(notificationNotifierProvider.notifier).loadAll(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      _buildHeaderCard(),
                      const SizedBox(height: 24),

                      // Notification Preferences list
                      const Text(
                        'NOTIFICATION CATEGORIES & CHANNELS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoriesList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final cat = categoriesList[i];
                          final catId = cat['id']!;
                          
                          // Find active pref or default
                          final activePref = state.preferences.firstWhere(
                            (p) => p.category == catId,
                            orElse: () => NotificationPreference(
                              category: catId,
                              emailEnabled: true,
                              pushEnabled: true,
                              inAppEnabled: true,
                            ),
                          );

                          return _CategoryPreferenceCard(
                            title: cat['title']!,
                            description: cat['desc']!,
                            preference: activePref,
                            onChanged: (email, push, inApp) {
                              ref.read(notificationNotifierProvider.notifier).updatePref(
                                    category: catId,
                                    emailEnabled: email,
                                    pushEnabled: push,
                                    inAppEnabled: inApp,
                                  );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // In-app Notifications log history
                      const Text(
                        'RECENT NOTIFICATIONS LOG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (state.notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No recent notification logs found.',
                              style: TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final log = state.notifications[i];
                            return ListTile(
                              tileColor: AppTheme.surfaceColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              leading: CircleAvatar(
                                radius: 15,
                                backgroundColor: log.isRead ? Colors.white10 : AppTheme.primaryColor.withValues(alpha: 0.2),
                                child: Icon(
                                  log.isRead ? Icons.notifications_none : Icons.notifications_active,
                                  color: log.isRead ? Colors.white38 : AppTheme.primaryColor,
                                  size: 16,
                                ),
                              ),
                              title: Text(
                                log.title,
                                style: TextStyle(
                                  color: log.isRead ? Colors.white38 : Colors.white,
                                  fontWeight: log.isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                log.body,
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                              trailing: log.isRead
                                  ? null
                                  : TextButton(
                                      onPressed: () => ref.read(notificationNotifierProvider.notifier).markAsRead(log.id),
                                      child: const Text('Mark Read', style: TextStyle(fontSize: 11, color: AppTheme.primaryColor)),
                                    ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Icon(Icons.spatial_audio_off_outlined, color: AppTheme.primaryColor, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anti-Spam Guarantee',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Customize exactly how you receive updates. Turn off any channel to keep your inbox clean.',
                  style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPreferenceCard extends StatelessWidget {
  final String title;
  final String description;
  final NotificationPreference preference;
  final Function(bool, bool, bool) onChanged;

  const _CategoryPreferenceCard({
    required this.title,
    required this.description,
    required this.preference,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
          const SizedBox(height: 3),
          Text(description, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChannelToggle('In-App', preference.inAppEnabled, (val) {
                onChanged(preference.emailEnabled, preference.pushEnabled, val);
              }),
              _buildChannelToggle('Email', preference.emailEnabled, (val) {
                onChanged(val, preference.pushEnabled, preference.inAppEnabled);
              }),
              _buildChannelToggle('Push', preference.pushEnabled, (val) {
                onChanged(preference.emailEnabled, val, preference.inAppEnabled);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelToggle(String label, bool value, Function(bool) onToggle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(width: 4),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: value,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white12,
            onChanged: onToggle,
          ),
        ),
      ],
    );
  }
}
