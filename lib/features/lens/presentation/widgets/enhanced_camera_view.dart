import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/providers/camera_provider.dart';
import '../../../../core/domain/enums/app_language.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/domain/models/app_settings.dart';
import '../providers/lens_state_provider.dart';
import '../../domain/enums/recognition_state.dart';
import '../../domain/models/lens_state.dart';
import '../../domain/models/translation_result.dart';

/// Enhanced Camera View for Live ASL/GSL Translation Demo
/// Features beautiful animations, real-time overlays, and professional UI
class EnhancedCameraView extends ConsumerWidget {
  const EnhancedCameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cameraState = ref.watch(cameraNotifierProvider);
    final lensState = ref.watch(lensStateNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.9),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Camera Preview Area
          Positioned.fill(
            child: _buildCameraPreview(context, cameraState, lensState),
          ),

          // Recognition Status Overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: _buildStatusOverlay(context, lensState, settings, ref),
          ),

          // Translation Result Overlay
          if (lensState.currentTranslation != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildTranslationOverlay(
                context,
                lensState.currentTranslation!,
                settings.selectedLanguage,
              ),
            ),

          // Camera Controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildCameraControls(context, ref, cameraState, lensState),
          ),

          // Debug Info (for demo purposes)
          if (settings.showDebugInfo)
            Positioned(
              top: 100,
              right: 20,
              child: _buildDebugInfo(context, cameraState, lensState),
            ),
        ],
      ),
    );
  }

  /// Build camera preview with beautiful placeholder
  Widget _buildCameraPreview(
    BuildContext context,
    CameraState cameraState,
    LensState lensState,
  ) {
    final theme = Theme.of(context);

    if (cameraState.isInitialized && cameraState.isCapturing) {
      // Real camera preview (when camera package is available)
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(theme, lensState.recognitionState),
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            children: [
              // Mock camera preview for now
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                            Icons.videocam,
                            size: 80,
                            color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 2000.ms,
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                      const SizedBox(height: 20),
                      Text(
                        'Live Camera Feed',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Frame: ${cameraState.frameCount}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scanning animation overlay
              if (lensState.recognitionState == RecognitionState.translating)
                _buildScanningOverlay(theme),
            ],
          ),
        ),
      );
    }

    // Camera not ready - show beautiful placeholder
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                  Icons.camera_alt_outlined,
                  size: 100,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(delay: 400.ms, duration: 600.ms),
            const SizedBox(height: 24),
            Text(
              'Camera Initializing...',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
            const SizedBox(height: 8),
            Text(
              'Tap "Start Translation" to begin',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }

  /// Build status overlay with beautiful animations
  Widget _buildStatusOverlay(
    BuildContext context,
    LensState lensState,
    AppSettings settings,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(theme, lensState.recognitionState);
    final statusMessage = _getStatusMessage(lensState.recognitionState);

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Status indicator
              Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 1500.ms,
                    color: statusColor.withValues(alpha: 0.5),
                  ),

              const SizedBox(width: 12),

              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusMessage,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Language: ${settings.selectedLanguage == AppLanguage.asl ? 'ASL' : 'GSL'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Language toggle button
              IconButton(
                onPressed: () {
                  ref.read(lensStateNotifierProvider.notifier).switchLanguage();
                },
                icon: const Icon(Icons.translate),
                tooltip: 'Switch Language',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, duration: 600.ms);
  }

  /// Build translation result overlay with stunning animations
  Widget _buildTranslationOverlay(
    BuildContext context,
    TranslationResult translation,
    AppLanguage language,
  ) {
    final theme = Theme.of(context);
    final confidenceColor = _getConfidenceColor(theme, translation.confidence);

    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.95),
                theme.colorScheme.secondaryContainer.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: confidenceColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: confidenceColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Translation header
              Row(
                children: [
                  Icon(Icons.sign_language, color: confidenceColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '${language == AppLanguage.asl ? 'ASL' : 'GSL'} Translation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: confidenceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Confidence indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(translation.confidence * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: confidenceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Translation text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  translation.text,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 600.ms)
        .slideY(begin: 0.3, end: 0, duration: 600.ms);
  }

  /// Build camera controls for demo
  Widget _buildCameraControls(
    BuildContext context,
    WidgetRef ref,
    CameraState cameraState,
    LensState lensState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Start/Stop Translation
        _buildControlButton(
          context: context,
          icon: lensState.isActive ? Icons.stop : Icons.play_arrow,
          label: lensState.isActive ? 'Stop' : 'Start',
          onPressed: () async {
            final notifier = ref.read(lensStateNotifierProvider.notifier);
            if (lensState.isActive) {
              notifier.stopTranslation();
            } else {
              await notifier.startTranslation();
            }
          },
          isPrimary: true,
        ),

        // Camera switch (when available)
        _buildControlButton(
          context: context,
          icon: Icons.flip_camera_ios,
          label: 'Flip',
          onPressed: cameraState.isInitialized
              ? () => ref.read(cameraNotifierProvider.notifier).switchCamera()
              : null,
        ),

        // Settings
        _buildControlButton(
          context: context,
          icon: Icons.settings,
          label: 'Settings',
          onPressed: () {
            // Navigate to settings or show settings modal
          },
        ),
      ],
    );
  }

  /// Build individual control button
  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: isPrimary
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              foregroundColor: isPrimary
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              child: Icon(icon, size: 28),
            )
            .animate()
            .scale(delay: (isPrimary ? 0 : 200).ms, duration: 600.ms)
            .fadeIn(delay: (isPrimary ? 100 : 300).ms, duration: 400.ms),

        const SizedBox(height: 8),

        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: (isPrimary ? 200 : 400).ms, duration: 400.ms),
      ],
    );
  }

  /// Build debug info panel
  Widget _buildDebugInfo(
    BuildContext context,
    CameraState cameraState,
    LensState lensState,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Info',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Camera: ${cameraState.isInitialized ? 'Ready' : 'Not Ready'}'),
          Text('Capturing: ${cameraState.isCapturing}'),
          Text('Frames: ${cameraState.frameCount}'),
          Text('Recognition: ${lensState.recognitionState.name}'),
          Text('Active: ${lensState.isActive}'),
        ],
      ),
    );
  }

  /// Build scanning animation overlay
  Widget _buildScanningOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Scanning line animation
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child:
                  Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              theme.colorScheme.primary,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .slideY(begin: 0, end: 1, duration: 2000.ms),
            ),
          ],
        ),
      ),
    );
  }

  /// Get status color based on recognition state
  Color _getStatusColor(ThemeData theme, RecognitionState state) {
    switch (state) {
      case RecognitionState.idle:
        return theme.colorScheme.onSurface.withValues(alpha: 0.5);
      case RecognitionState.initializing:
        return theme.colorScheme.primary;
      case RecognitionState.ready:
        return Colors.green;
      case RecognitionState.translating:
        return theme.colorScheme.secondary;
      case RecognitionState.error:
        return Colors.red;
    }
  }

  /// Get status message
  String _getStatusMessage(RecognitionState state) {
    switch (state) {
      case RecognitionState.idle:
        return 'Tap camera to translate';
      case RecognitionState.initializing:
        return 'Initializing...';
      case RecognitionState.ready:
        return 'Ready to translate';
      case RecognitionState.translating:
        return 'Scanning for signs...';
      case RecognitionState.error:
        return 'Translation error';
    }
  }

  /// Get confidence color
  Color _getConfidenceColor(ThemeData theme, double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}

/// Extension to add debug info setting to AppSettings
extension AppSettingsDebug on AppSettings {
  bool get showDebugInfo => true; // Enable for demo purposes
}
