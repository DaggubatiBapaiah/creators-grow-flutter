import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/notifiers/onboarding_notifier.dart';

class CreatorGoalScreen extends ConsumerStatefulWidget {
  const CreatorGoalScreen({super.key});

  @override
  ConsumerState<CreatorGoalScreen> createState() => _CreatorGoalScreenState();
}

class _CreatorGoalScreenState extends ConsumerState<CreatorGoalScreen> {
  final List<String> _availableGoals = [
    'Grow followers',
    'Increase engagement',
    'Get brand deals',
    'Generate leads',
    'Sell products',
    'Build personal brand',
  ];

  final List<String> _selectedGoals = [];

  @override
  void initState() {
    super.initState();
    final onboardingState = ref.read(onboardingNotifierProvider);
    _selectedGoals.addAll(onboardingState.goals);
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _submit() {
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one goal')),
      );
      return;
    }
    ref.read(onboardingNotifierProvider.notifier).updateGoals(_selectedGoals);
    context.go('/onboarding/platforms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2 of 4'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/profile'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What are your primary goals?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select all goals that apply to your creative business.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableGoals.length,
                  itemBuilder: (context, index) {
                    final goal = _availableGoals[index];
                    final isSelected = _selectedGoals.contains(goal);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => _toggleGoal(goal),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                                : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_outlined,
                                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF475569),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
