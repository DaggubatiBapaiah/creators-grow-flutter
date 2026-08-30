import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/billing_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _isAnnually = false;

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(billingNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Plans & Subscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: billingState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Plan Header Info
                  if (billingState.status != null) ...[
                    _buildCurrentPlanCard(billingState.status!),
                    const SizedBox(height: 24),
                  ],

                  // Plan Header title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Choose Your Plan',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Supercharge your content workflow and sponsorships',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Billing Cycle Toggle
                  _buildBillingToggle(),
                  const SizedBox(height: 20),

                  // Three Plans
                  _buildPlanCard(
                    title: 'Free',
                    price: '₹0',
                    subtitle: 'For starting creators',
                    isPopular: false,
                    features: [
                      'Up to 2 connected social accounts',
                      '5 scheduled posts per month',
                      '5 AI generations per month',
                      'Basic analytics'
                    ],
                    planCode: 'free',
                    currentPlanCode: billingState.status?.planCode,
                    onUpgrade: null,
                    isUpgrading: billingState.isUpgrading,
                  ),
                  const SizedBox(height: 16),

                  _buildPlanCard(
                    title: 'Creator',
                    price: _isAnnually ? '₹399' : '₹499',
                    subtitle: 'For active individual creators',
                    isPopular: true,
                    features: [
                      'Up to 5 connected social accounts',
                      '50 scheduled posts per month',
                      '100 AI generations per month',
                      'Advanced analytics dashboard',
                      'Growth Intelligence recommendations',
                      'Customizable Media Kit page'
                    ],
                    planCode: 'creator',
                    currentPlanCode: billingState.status?.planCode,
                    onUpgrade: () => _handleUpgrade('creator'),
                    isUpgrading: billingState.isUpgrading,
                  ),
                  const SizedBox(height: 16),

                  _buildPlanCard(
                    title: 'Pro',
                    price: _isAnnually ? '₹1,199' : '₹1,499',
                    subtitle: 'For professional creators & agencies',
                    isPopular: false,
                    features: [
                      'Unlimited social accounts',
                      'Unlimited scheduled posts',
                      'Unlimited AI Copilot generations',
                      'Brand Deal CRM Pipeline',
                      'Growth Intelligence & Advanced Analytics',
                      'Customizable Media Kit + sponsorship outreach',
                      'Priority support'
                    ],
                    planCode: 'pro',
                    currentPlanCode: billingState.status?.planCode,
                    onUpgrade: () => _handleUpgrade('pro'),
                    isUpgrading: billingState.isUpgrading,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Future<void> _handleUpgrade(String planCode) async {
    try {
      await ref.read(billingNotifierProvider.notifier).upgrade(planCode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan updated successfully to ${planCode.toUpperCase()}!'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment simulation failed: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  Widget _buildBillingToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Monthly', style: TextStyle(color: Colors.white70)),
        Switch(
          value: _isAnnually,
          activeColor: AppTheme.primaryColor,
          onChanged: (val) => setState(() => _isAnnually = val),
        ),
        Row(
          children: [
            const Text('Annually', style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Save 20%',
                style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentPlanCard(dynamic status) {
    final expires = DateFormat('dd MMM yyyy').format(status.currentPeriodEnd);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Subscription', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    status.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Active', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white12),
          
          // Limits / Usages Counters
          _buildUsageIndicator('Social Accounts', status.connectedAccounts, status.maxSocialAccounts),
          const SizedBox(height: 12),
          _buildUsageIndicator('Scheduled Posts', status.scheduledPostsUsed, status.maxScheduledPosts),
          const SizedBox(height: 12),
          _buildUsageIndicator('AI Copilot generations', status.aiGenerationsUsed, status.maxAiGenerations),
          
          const SizedBox(height: 16),
          Text(
            'Renews / Expires on: $expires',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageIndicator(String label, int used, int max) {
    final double percent = max > 0 ? (used / max).clamp(0.0, 1.0) : 0.0;
    final maxLabel = max > 1000 ? 'Unlimited' : max.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('$used / $maxLabel', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(percent >= 1.0 ? Colors.redAccent : AppTheme.primaryColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required bool isPopular,
    required List<String> features,
    required String planCode,
    required String? currentPlanCode,
    required VoidCallback? onUpgrade,
    required bool isUpgrading,
  }) {
    final isCurrent = currentPlanCode?.toLowerCase() == planCode.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? AppTheme.surfaceColor : const Color(0xFF1E202B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent 
              ? Colors.greenAccent 
              : isPopular ? AppTheme.primaryColor : Colors.white12,
          width: isCurrent || isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Most Popular',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Current Plan', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Text(
                _isAnnually ? '/year' : '/month',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Action button
          if (isCurrent)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('CURRENT PLAN', style: TextStyle(color: Colors.white38)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUpgrading ? null : onUpgrade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isUpgrading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('UPGRADE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          
          const Divider(height: 32, color: Colors.white12),
          
          // Feature list
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: AppTheme.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
