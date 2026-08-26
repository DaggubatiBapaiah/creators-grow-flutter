import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/content_notifier.dart';
import '../../domain/models/content_post.dart';
import 'package:intl/intl.dart';

class ContentListScreen extends ConsumerStatefulWidget {
  const ContentListScreen({super.key});

  @override
  ConsumerState<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends ConsumerState<ContentListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(contentNotifierProvider.notifier).loadPosts());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Pipeline'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/composer'),
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : state.error != null
            ? Center(child: Text(state.error!, style: const TextStyle(color: AppTheme.errorColor)))
            : state.posts.isEmpty
                ? _buildEmptyState()
                : _buildList(state.posts),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: AppTheme.secondaryTextColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No content yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tap New Post to start creating.', style: TextStyle(color: AppTheme.secondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildList(List<ContentPost> posts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: AppTheme.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(post.status),
                    Text(post.platform, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.caption ?? 'No caption',
                  style: const TextStyle(fontSize: 16),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (post.scheduledAt != null)
                  Text(
                    'Scheduled: ${DateFormat.yMd().add_jm().format(post.scheduledAt!)}',
                    style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12),
                  ),
                if (post.publishedAt != null)
                  Text(
                    'Published: ${DateFormat.yMd().add_jm().format(post.publishedAt!)}',
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                  ),
                if (post.status == 'failed' && post.failureReason != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Error: ${post.failureReason}',
                      style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (post.status == 'scheduled')
                      TextButton(
                        onPressed: () => ref.read(contentNotifierProvider.notifier).cancelPost(post.id),
                        child: const Text('Cancel', style: TextStyle(color: AppTheme.errorColor)),
                      ),
                    if (post.status == 'draft' || post.status == 'cancelled')
                      TextButton(
                        onPressed: () => ref.read(contentNotifierProvider.notifier).deletePost(post.id),
                        child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'published': color = Colors.green; break;
      case 'scheduled': color = AppTheme.primaryColor; break;
      case 'failed': color = AppTheme.errorColor; break;
      default: color = AppTheme.secondaryTextColor; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
