import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/ai_copilot_notifier.dart';
import 'package:creators_grow/core/theme/app_theme.dart';

class AIPromptBottomSheet extends ConsumerStatefulWidget {
  final String platform;
  const AIPromptBottomSheet({Key? key, required this.platform}) : super(key: key);

  @override
  ConsumerState<AIPromptBottomSheet> createState() => _AIPromptBottomSheetState();
}

class _AIPromptBottomSheetState extends ConsumerState<AIPromptBottomSheet> {
  final _promptController = TextEditingController();
  String _selectedTone = 'engaging';

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiCopilotNotifierProvider);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('Spark AI Copilot', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (aiState.variations.isEmpty) ...[
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'What is this post about? (e.g. My morning routine)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTone,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Tone'),
              items: const [
                DropdownMenuItem(value: 'engaging', child: Text('Engaging')),
                DropdownMenuItem(value: 'professional', child: Text('Professional')),
                DropdownMenuItem(value: 'humorous', child: Text('Humorous')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedTone = val);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: aiState.isLoading
                    ? null
                    : () {
                        if (_promptController.text.length > 2) {
                          ref.read(aiCopilotNotifierProvider.notifier).generate(
                                prompt: _promptController.text,
                                platform: widget.platform,
                                tone: _selectedTone,
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: aiState.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Generate Variations'),
              ),
            ),
          ],
          if (aiState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(aiState.error!, style: const TextStyle(color: Colors.red)),
            ),
          if (aiState.variations.isNotEmpty) ...[
            Text('Select a variation:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: aiState.variations.length,
                itemBuilder: (context, index) {
                  final variation = aiState.variations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, variation.fullText);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(variation.hook, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(variation.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: variation.hashtags
                                  .map((h) => Text(h, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)))
                                  .toList(),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(aiCopilotNotifierProvider.notifier).reset();
                  _promptController.clear();
                },
                child: const Text('Start Over'),
              ),
            )
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
