import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/models/auth_state.dart';
import '../../../../features/auth/domain/notifiers/auth_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final displayName = authState is Authenticated ? authState.user.displayName : 'Creator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('CreatorsGrow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.dashboard_outlined,
              size: 72,
              color: Color(0xFF6366F1),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, $displayName!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This is the unified dashboard placeholder. Next, we will connect your Meta social accounts.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
