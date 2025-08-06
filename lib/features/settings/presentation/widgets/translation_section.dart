import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/settings_provider.dart';

class TranslationSection extends ConsumerWidget {
  const TranslationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Optimize: Only watch translation-specific fields to minimize rebuilds
    final isAutoTranslate = ref.watch(settingsNotifierProvider.select((s) => s.isAutoTranslate));
    final showConfidence = ref.watch(settingsNotifierProvider.select((s) => s.showConfidence));
    final translationTextSize = ref.watch(settingsNotifierProvider.select((s) => s.translationTextSize));
    final saveHistory = ref.watch(settingsNotifierProvider.select((s) => s.saveHistory));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.translate,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Translation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Auto-translate
            SwitchListTile(
              title: const Text('Auto-translate'),
              subtitle: const Text('Automatically start translation when signs are detected'),
              value: isAutoTranslate,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateAutoTranslate(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 8),
            
            // Show Confidence
            SwitchListTile(
              title: const Text('Show confidence level'),
              subtitle: const Text('Display accuracy percentage for translations'),
              value: showConfidence,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateShowConfidence(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 16),
            
            // Text Size Slider
            Text(
              'Translation Text Size',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.text_decrease, size: 16),
                Expanded(
                  child: Slider(
                    value: translationTextSize.toDouble(),
                    min: 12,
                    max: 28,
                    divisions: 8,
                    label: '${translationTextSize}px',
                    onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                        .updateTranslationTextSize(value.round()),
                  ),
                ),
                const Icon(Icons.text_increase, size: 16),
              ],
            ),
            
            // Preview Text
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Hello, this is a sample translation text.',
                style: TextStyle(
                  fontSize: translationTextSize.toDouble(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Translation History
            SwitchListTile(
              title: const Text('Save translation history'),
              subtitle: const Text('Keep a record of recent translations'),
              value: saveHistory,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateSaveHistory(value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    )
        .animate(delay: 100.ms)
        .slideX(begin: -0.2, end: 0)
        .fadeIn(duration: 400.ms);
  }
}