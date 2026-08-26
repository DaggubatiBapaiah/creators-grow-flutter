import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/notifiers/onboarding_notifier.dart';

class OnboardingCompleteScreen extends ConsumerWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 88,
                    color: Color(0xFF10B981), // Green
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "You're ready to grow.",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Here is your CreatorsGrow workflow to maximize your social impact:',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Visual workflow loop
                  _buildWorkflowStep(context, '1', 'CONNECT', 'Link your channels securely'),
                  _buildWorkflowArrow(),
                  _buildWorkflowStep(context, '2', 'UNDERSTAND', 'Analyze your target audience'),
                  _buildWorkflowArrow(),
                  _buildWorkflowStep(context, '3', 'CREATE & PUBLISH', 'Generate and schedule content'),
                  _buildWorkflowArrow(),
                  _buildWorkflowStep(context, '4', 'MEASURE & GROW', 'Track engagement and improve metrics'),
                ],
              ),
              FilledButton(
                onPressed: () {
                  ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowStep(BuildContext context, String number, String title, String subtitle) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
          child: Text(
            number,
            style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkflowArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(Icons.arrow_downward_rounded, size: 18, color: Color(0xFF475569)),
        ],
      ),
    );
  }
}
