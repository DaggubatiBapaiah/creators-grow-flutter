import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/models/social_platform.dart';
import '../../domain/models/social_account.dart';
import '../notifiers/social_accounts_notifier.dart';

class ConnectedAccountsScreen extends ConsumerStatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  ConsumerState<ConnectedAccountsScreen> createState() => _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends ConsumerState<ConnectedAccountsScreen> with RouteAware, WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(socialAccountsNotifierProvider.notifier).fetchAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialAccountsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(socialAccountsNotifierProvider.notifier).fetchAccounts();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link Social Channels',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect your social platforms to understand your audience and grow faster.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          error.toString(),
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            ref.read(socialAccountsNotifierProvider.notifier).fetchAccounts();
                          },
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (accounts) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: SocialPlatform.values.map((platform) {
                        final connectedAcc = accounts.firstWhere(
                          (acc) => acc.platform == platform,
                          orElse: () => SocialAccount(
                            id: '',
                            platform: platform,
                            accountName: '',
                            platformAccountId: '',
                            status: 'disconnected',
                          ),
                        );

                        final isConnected = connectedAcc.id.isNotEmpty;

                        return _PlatformConnectionCard(
                          platform: platform,
                          isConnected: isConnected,
                          accountName: connectedAcc.accountName,
                          status: connectedAcc.status,
                          onConnect: () => _handleConnect(platform),
                          onDisconnect: () => _handleDisconnect(connectedAcc),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConnect(SocialPlatform platform) async {
    if (!platform.isSupported) return;
    
    try {
      await ref.read(socialAccountsNotifierProvider.notifier).connectPlatform(platform);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Browser opened. Complete authorization and tap Refresh.'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AppError ? e.message : 'Could not open authorization in browser.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleDisconnect(SocialAccount account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text('Disconnect ${account.platform.displayName}?'),
          content: const Text(
            'Your account connection and future data syncing will stop.',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(socialAccountsNotifierProvider.notifier).disconnectAccount(account.id);
              },
              child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}

class _PlatformConnectionCard extends StatelessWidget {
  final SocialPlatform platform;
  final bool isConnected;
  final String accountName;
  final String status;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _PlatformConnectionCard({
    required this.platform,
    required this.isConnected,
    required this.accountName,
    required this.status,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComingSoon = !platform.isSupported;
    final bool isReconnectRequired = status == 'reconnect_required';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected 
              ? (isReconnectRequired ? Colors.orangeAccent : const Color(0xFF10B981))
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF0F172A),
            child: Icon(
              _getPlatformIcon(platform),
              color: isComingSoon ? const Color(0xFF64748B) : const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 2),
                if (isComingSoon)
                  const Text(
                    'Coming soon',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  )
                else if (isConnected)
                  Row(
                    children: [
                      Text(
                        '@$accountName',
                        style: TextStyle(
                          color: isReconnectRequired ? Colors.orangeAccent : const Color(0xFF10B981),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isReconnectRequired) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 14),
                      ]
                    ],
                  )
                else
                  const Text(
                    'Not connected',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
              ],
            ),
          ),
          if (!isComingSoon)
            isConnected
                ? (isReconnectRequired
                    ? FilledButton(
                        onPressed: onConnect,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reconnect', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      )
                    : OutlinedButton(
                        onPressed: onDisconnect,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent)),
                      ))
                : FilledButton(
                    onPressed: onConnect,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Connect', style: TextStyle(color: Colors.white)),
                  ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return Icons.camera_alt_outlined;
      case SocialPlatform.facebook:
        return Icons.facebook_outlined;
      case SocialPlatform.youtube:
        return Icons.video_library_outlined;
      case SocialPlatform.tiktok:
        return Icons.music_note_outlined;
      case SocialPlatform.linkedin:
        return Icons.business_center_outlined;
      case SocialPlatform.x:
        return Icons.alternate_email_outlined;
    }
  }
}