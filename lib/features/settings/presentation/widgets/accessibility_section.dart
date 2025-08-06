import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/settings_provider.dart';

class AccessibilitySection extends ConsumerWidget {
  const AccessibilitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Optimize: Only watch accessibility-specific fields to minimize rebuilds
    final highContrast = ref.watch(settingsNotifierProvider.select((s) => s.highContrast));
    final largeText = ref.watch(settingsNotifierProvider.select((s) => s.largeText));
    final reduceMotion = ref.watch(settingsNotifierProvider.select((s) => s.reduceMotion));
    final hapticFeedback = ref.watch(settingsNotifierProvider.select((s) => s.hapticFeedback));
    final voiceFeedback = ref.watch(settingsNotifierProvider.select((s) => s.voiceFeedback));
    
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
                  Icons.accessibility,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Accessibility',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // High Contrast
            SwitchListTile(
              title: const Text('High contrast mode'),
              subtitle: const Text('Improve visibility with enhanced contrast'),
              value: highContrast,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateHighContrast(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 8),
            
            // Large Text
            SwitchListTile(
              title: const Text('Large text'),
              subtitle: const Text('Increase text size throughout the app'),
              value: largeText,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateLargeText(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 8),
            
            // Reduce Motion
            SwitchListTile(
              title: const Text('Reduce motion'),
              subtitle: const Text('Minimize animations and transitions'),
              value: reduceMotion,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateReduceMotion(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 16),
            
            // Haptic Feedback
            Text(
              'Haptic Feedback',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.vibration, size: 16),
                const SizedBox(width: 8),
                const Text('Off'),
                Expanded(
                  child: Slider(
                    value: hapticFeedback.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: _getHapticLabel(hapticFeedback),
                    onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                        .updateHapticFeedback(value.round()),
                  ),
                ),
                const Text('Strong'),
                const SizedBox(width: 8),
                const Icon(Icons.vibration, size: 20),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Voice Feedback
            SwitchListTile(
              title: const Text('Voice feedback'),
              subtitle: const Text('Spoken announcements for important actions'),
              value: voiceFeedback,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateVoiceFeedback(value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    )
        .animate(delay: 300.ms)
        .slideX(begin: -0.2, end: 0)
        .fadeIn(duration: 400.ms);
  }
  
  String _getHapticLabel(int level) {
    switch (level) {
      case 0:
        return 'Off';
      case 1:
        return 'Light';
      case 2:
        return 'Strong';
      default:
        return 'Light';
    }
  }
}