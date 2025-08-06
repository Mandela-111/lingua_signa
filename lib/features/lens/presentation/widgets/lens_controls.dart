import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/lens_state_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/enums/recognition_state.dart';

class LensControls extends ConsumerWidget {
  const LensControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lensState = ref.watch(lensStateNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    
    return Container(
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Message
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lensState.recognitionState.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms),
              
              const SizedBox(height: 24),
              
              // Main Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Language Switch
                  _ControlButton(
                    icon: Icons.language,
                    label: settings.selectedLanguage.code,
                    isEnabled: !lensState.isActive,
                    onTap: lensState.isActive 
                        ? null 
                        : () => ref.read(lensStateNotifierProvider.notifier).switchLanguage(),
                  ),
                  
                  // Main Action Button
                  _MainActionButton(
                    isActive: lensState.isActive,
                    recognitionState: lensState.recognitionState,
                    onTap: () => _handleMainAction(ref, lensState),
                  ),
                  
                  // Settings Button
                  _ControlButton(
                    icon: Icons.tune,
                    label: 'Settings',
                    isEnabled: !lensState.isActive,
                    onTap: lensState.isActive 
                        ? null 
                        : () => _showQuickSettings(context, ref),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Additional Controls
              if (lensState.isActive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => ref.read(lensStateNotifierProvider.notifier).stopTranslation(),
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text('Stop Translation'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .slideY(begin: 0.5, end: 0)
                    .fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleMainAction(WidgetRef ref, dynamic lensState) async {
    final lensNotifier = ref.read(lensStateNotifierProvider.notifier);
    
    if (lensState.isActive) {
      lensNotifier.stopTranslation();
    } else {
      // Haptic feedback
      await HapticFeedback.mediumImpact();
      await lensNotifier.startTranslation();
    }
  }
  
  void _showQuickSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _QuickSettingsSheet(),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    required this.onTap,
  });
  
  final IconData icon;
  final String label;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled 
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled 
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isEnabled 
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton({
    required this.isActive,
    required this.recognitionState,
    required this.onTap,
  });
  
  final bool isActive;
  final RecognitionState recognitionState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.error : theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? theme.colorScheme.error : theme.colorScheme.primary)
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isActive ? Icons.stop : Icons.camera_alt,
          color: isActive 
              ? theme.colorScheme.onError 
              : theme.colorScheme.onPrimary,
          size: 32,
        ),
      ),
    )
        .animate(target: isActive ? 1 : 0)
        .scaleXY(end: 1.1)
        .then()
        .scaleXY(end: 1.0);
  }
}

class _QuickSettingsSheet extends ConsumerWidget {
  const _QuickSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Quick Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Auto-translate toggle
          SwitchListTile(
            title: const Text('Auto-translate'),
            subtitle: const Text('Automatically start translation when signs are detected'),
            value: settings.isAutoTranslate,
            onChanged: (value) => ref.read(settingsNotifierProvider.notifier).updateAutoTranslate(value),
          ),
          
          const SizedBox(height: 16),
          
          // Text size slider
          Text(
            'Translation Text Size',
            style: theme.textTheme.titleMedium,
          ),
          Slider(
            value: settings.translationTextSize.toDouble(),
            min: 14,
            max: 24,
            divisions: 5,
            label: '${settings.translationTextSize}px',
            onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                .updateTranslationTextSize(value.round()),
          ),
          
          const SizedBox(height: 24),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}