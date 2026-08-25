import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../social_accounts/presentation/notifiers/social_accounts_notifier.dart';
import '../notifiers/content_notifier.dart';
import 'package:go_router/go_router.dart';

class ContentComposerScreen extends ConsumerStatefulWidget {
  const ContentComposerScreen({super.key});

  @override
  ConsumerState<ContentComposerScreen> createState() => _ContentComposerScreenState();
}

class _ContentComposerScreenState extends ConsumerState<ContentComposerScreen> {
  final _captionController = TextEditingController();
  String? _selectedAccountId;
  DateTime? _scheduledAt;

  @override
  Widget build(BuildContext context) {
    final accountsState = ref.watch(socialAccountsNotifierProvider);
    final connectedAccounts = accountsState.accounts.where((a) => a.status == 'connected').toList();
    final contentState = ref.watch(contentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedAccountId,
              decoration: InputDecoration(
                labelText: 'Select Social Account',
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: connectedAccounts.map((account) {
                return DropdownMenuItem(
                  value: account.id,
                  child: Text('${account.platform} - ${account.username}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedAccountId = val),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _captionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'What do you want to share?',
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.primaryColor),
                    SizedBox(height: 8),
                    Text('Add Media (Image/Video)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (contentState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  contentState.error!,
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _submit('draft'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SAVE DRAFT'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                       final date = await showDatePicker(
                         context: context,
                         initialDate: DateTime.now().add(const Duration(days: 1)),
                         firstDate: DateTime.now(),
                         lastDate: DateTime.now().add(const Duration(days: 365)),
                       );
                       if (date != null && context.mounted) {
                         final time = await showTimePicker(
                           context: context,
                           initialTime: TimeOfDay.now(),
                         );
                         if (time != null) {
                           setState(() {
                             _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                           });
                           _submit('scheduled');
                         }
                       }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SCHEDULE'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _submit('published'), // mapped to Publish Now
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('PUBLISH NOW'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String status) async {
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }
    final accountsState = ref.read(socialAccountsNotifierProvider);
    final account = accountsState.accounts.firstWhere((a) => a.id == _selectedAccountId);

    try {
      await ref.read(contentNotifierProvider.notifier).createPost(
        socialAccountId: _selectedAccountId!,
        platform: account.platform,
        caption: _captionController.text,
        status: status,
        scheduledAt: _scheduledAt,
      );
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      // Error handled in state
    }
  }
}
