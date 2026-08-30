import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/notifiers/onboarding_notifier.dart';

class PlatformSelectionScreen extends ConsumerStatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  ConsumerState<PlatformSelectionScreen> createState() => _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends ConsumerState<PlatformSelectionScreen> {
  final List<String> _platforms = [
    'Instagram',
    'Facebook',
    'YouTube',
    'TikTok',
    'LinkedIn',
    'X',
  ];

  final List<String> _selectedPlatforms = [];

  @override
  void initState() {
    super.initState();
    final onboardingState = ref.read(onboardingNotifierProvider);
    _selectedPlatforms.addAll(onboardingState.selectedPlatforms);
  }

  void _togglePlatform(String platform) {
    setState(() {
      if (_selectedPlatforms.contains(platform)) {
        _selectedPlatforms.remove(platform);
      } else {
        _selectedPlatforms.add(platform);
      }
    });
  }

  void _submit() {
    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one platform')),
      );
      return;
    }
    ref.read(onboardingNotifierProvider.notifier).updatePlatforms(_selectedPlatforms);
    context.go('/onboarding/complete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 3 of 4'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/goals'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select your social channels',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Which social media platforms do you use for your creator business?',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _platforms.length,
                  itemBuilder: (context, index) {
                    final platform = _platforms[index];
                    final isSelected = _selectedPlatforms.contains(platform);
                    return InkWell(
                      onTap: () => _togglePlatform(platform),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getPlatformIcon(platform),
                              size: 32,
                              color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              platform,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
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

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'Instagram':
        return Icons.camera_alt_outlined;
      case 'Facebook':
        return Icons.facebook_outlined;
      case 'YouTube':
        return Icons.video_library_outlined;
      case 'TikTok':
        return Icons.music_note_outlined;
      case 'LinkedIn':
        return Icons.business_center_outlined;
      case 'X':
        return Icons.alternate_email_outlined;
      default:
        return Icons.device_hub_outlined;
    }
  }
}
