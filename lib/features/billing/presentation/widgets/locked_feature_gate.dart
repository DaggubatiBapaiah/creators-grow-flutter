import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/billing_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../screens/pricing_screen.dart';

class LockedFeatureGate extends ConsumerWidget {
  final Widget child;
  final bool Function(BillingState) checkAccess;
  final String featureName;

  const LockedFeatureGate({
    super.key,
    required this.child,
    required this.checkAccess,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingState = ref.watch(billingNotifierProvider);
    
    // Fallback while loading
    if (billingState.status == null) {
      if (billingState.isLoading) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
      }
      return child; // Allow bypass if server state is unavailable
    }

    final hasAccess = checkAccess(billingState);
    if (hasAccess) return child;

    return Stack(
      children: [
        // Blur / Lock the content child
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AbsorbPointer(child: child),
        ),
        
        // Lock Overlay
        Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, color: AppTheme.primaryColor, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock $featureName',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upgrade your plan to access premium analytics, Growth Intelligence, custom Media Kits, CRM pipeline, and advanced scheduling.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PricingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Premium Plans'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
