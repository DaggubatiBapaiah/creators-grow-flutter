import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/engagement_item.dart';
import '../notifiers/inbox_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../social_accounts/domain/models/social_platform.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _searchController = TextEditingController();
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inboxNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Unified Engagement Inbox'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Platform Tabs row
          _buildPlatformTabs(state),

          // Sub-filters (Unread, Replied) + Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search author or content...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (val) {
                      ref.read(inboxNotifierProvider.notifier).setSearchKeyword(val);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                _buildStatusDropdown(state),
              ],
            ),
          ),

          // Error Alerts banner
          if (state.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade800),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Comment Thread Items List
          Expanded(
            child: state.isLoading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                : state.items.isEmpty
                    ? const Center(
                        child: Text('No messages or comments found.', style: TextStyle(color: Colors.white38)),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(inboxNotifierProvider.notifier).loadItems(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          itemCount: state.items.length,
                          itemBuilder: (context, i) {
                            final item = state.items[i];
                            return _InboxItemTile(
                              item: item,
                              onReply: (text) => ref.read(inboxNotifierProvider.notifier).replyToComment(item.id, text),
                              onLike: () => ref.read(inboxNotifierProvider.notifier).toggleLike(item.id, !item.isLiked),
                              onHide: () => ref.read(inboxNotifierProvider.notifier).toggleHide(item.id, !item.isHidden),
                              onDelete: () => ref.read(inboxNotifierProvider.notifier).deleteComment(item.id),
                              onRead: () => ref.read(inboxNotifierProvider.notifier).markItemAsRead(item.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformTabs(InboxState state) {
    final platforms = ['all', 'instagram', 'facebook', 'youtube', 'x'];
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: platforms.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = platforms[i];
          final isSel = state.activePlatform == p;
          
          Color brandColor = AppTheme.primaryColor;
          if (p == 'instagram') brandColor = const Color(0xFFE1306C);
          if (p == 'facebook') brandColor = const Color(0xFF1877F2);
          if (p == 'youtube') brandColor = const Color(0xFFFF0000);
          if (p == 'x') brandColor = Colors.white;

          return ChoiceChip(
            label: Text(
              p.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? Colors.black : Colors.white60,
              ),
            ),
            selected: isSel,
            selectedColor: brandColor,
            backgroundColor: AppTheme.surfaceColor,
            onSelected: (val) {
              if (val) {
                ref.read(inboxNotifierProvider.notifier).setPlatformFilter(p);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(InboxState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: state.activeStatus,
          dropdownColor: AppTheme.surfaceColor,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          hint: const Text('All Status', style: TextStyle(color: Colors.white60)),
          items: const [
            DropdownMenuItem(value: null, child: Text('All Status')),
            DropdownMenuItem(value: 'unread', child: Text('Unread')),
            DropdownMenuItem(value: 'replied', child: Text('Replied')),
          ],
          onChanged: (val) {
            ref.read(inboxNotifierProvider.notifier).setStatusFilter(val);
          },
        ),
      ),
    );
  }
}

class _InboxItemTile extends StatefulWidget {
  final EngagementItem item;
  final Function(String) onReply;
  final VoidCallback onLike;
  final VoidCallback onHide;
  final VoidCallback onDelete;
  final VoidCallback onRead;

  const _InboxItemTile({
    required this.item,
    required this.onReply,
    required this.onLike,
    required this.onHide,
    required this.onDelete,
    required this.onRead,
  });

  @override
  State<_InboxItemTile> createState() => _InboxItemTileState();
}

class _InboxItemTileState extends State<_InboxItemTile> {
  bool _isReplying = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    
    Color brandColor = Colors.white24;
    if (item.platform == 'instagram') brandColor = const Color(0xFFE1306C);
    if (item.platform == 'facebook') brandColor = const Color(0xFF1877F2);
    if (item.platform == 'youtube') brandColor = const Color(0xFFFF0000);
    if (item.platform == 'x') brandColor = Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.item.isRead ? Colors.transparent : brandColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header info
          GestureDetector(
            onTap: widget.onRead,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: item.authorAvatarUrl != null ? NetworkImage(item.authorAvatarUrl!) : null,
                  backgroundColor: AppTheme.primaryColor,
                  child: item.authorAvatarUrl == null 
                      ? Text(item.authorName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  '@${item.authorName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: brandColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.platform.toUpperCase(),
                    style: TextStyle(color: brandColor, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                if (!item.isRead)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Message/comment body
          Text(
            item.content,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 12),

          // Action Toolbar (Like, Reply, Hide, Delete depending on permissions)
          Row(
            children: [
              // Like comment (disable for YouTube)
              if (item.platform != 'youtube') ...[
                IconButton(
                  icon: Icon(item.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: item.isLiked ? Colors.redAccent : Colors.white38, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onLike,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.likeCount}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(width: 20),
              ],

              // Reply action
              TextButton.icon(
                onPressed: () => setState(() => _isReplying = !_isReplying),
                icon: Icon(item.isReplied ? Icons.check_circle : Icons.reply_outlined,
                    color: item.isReplied ? Colors.greenAccent : AppTheme.primaryColor, size: 16),
                label: Text(
                  item.isReplied ? 'Replied' : 'Reply',
                  style: TextStyle(color: item.isReplied ? Colors.greenAccent : AppTheme.primaryColor, fontSize: 11),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),

              // Hide comment
              IconButton(
                icon: Icon(item.isHidden ? Icons.visibility_off : Icons.visibility,
                    color: item.isHidden ? Colors.orangeAccent : Colors.white38, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: widget.onHide,
              ),
              const SizedBox(width: 14),

              // Delete action
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  _showDeleteConfirm(context);
                },
              ),
            ],
          ),

          // Sub-reply form
          if (_isReplying) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Write a public reply...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.black26,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      widget.onReply(text);
                      _controller.clear();
                      setState(() => _isReplying = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Send', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Comment?'),
        content: const Text('This will permanently delete this comment from the social media platform. Action is irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
