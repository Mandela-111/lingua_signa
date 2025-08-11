import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/video_conference_provider.dart';
import '../../domain/enums/call_state.dart';

import '../../domain/models/video_conference_state.dart';
import '../../../lens/domain/models/translation_result.dart';
import '../../../lens/domain/enums/recognition_state.dart';
import '../../../../core/domain/enums/app_language.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Enhanced Video Conference View with Real-Time Translation
class EnhancedVideoConferenceView extends ConsumerWidget {
  const EnhancedVideoConferenceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoConferenceNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.black54, Colors.black87],
        ),
      ),
      child: Stack(
        children: [
          // Main video content
          Positioned.fill(child: _buildVideoContent(context, videoState, ref)),

          // Translation overlay
          if (videoState.callState == CallState.connected)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: _buildTranslationOverlay(
                context,
                ref,
                settings.selectedLanguage,
              ),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context, videoState, ref),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(context, videoState, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent(
    BuildContext context,
    VideoConferenceState videoState,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);

    switch (videoState.callState) {
      case CallState.idle:
        return _buildWelcomeScreen(context, theme, ref);
      case CallState.connecting:
        return _buildConnectingScreen(context, theme);
      case CallState.connected:
        return _buildActiveCallScreen(context, theme, videoState);
      case CallState.error:
        return _buildErrorScreen(
          context,
          theme,
          videoState.error ?? 'Unknown error',
        );
    }
  }

  Widget _buildWelcomeScreen(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
  ) {
    final roomController = TextEditingController();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.video_call,
              size: 80,
              color: theme.colorScheme.primary,
            ).animate().scale(duration: 1000.ms).fadeIn(duration: 800.ms),
            const SizedBox(height: 24),
            Text(
                  'LinguaSigna Video Call',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Join a room with real-time ASL/GSL translation',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
            const SizedBox(height: 32),
            TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    labelText: 'Room ID',
                    hintText: 'Enter room code (e.g., DEMO2025)',
                    prefixIcon: const Icon(Icons.meeting_room),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0, duration: 600.ms),
            const SizedBox(height: 24),
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final roomId = roomController.text.trim();
                      if (roomId.isNotEmpty) {
                        ref
                            .read(videoConferenceNotifierProvider.notifier)
                            .joinRoom(roomId);
                      }
                    },
                    icon: const Icon(Icons.video_call, size: 24),
                    label: Text(
                      'Join Video Call',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), duration: 600.ms),
            const SizedBox(height: 16),
            Text(
              'Try: DEMO2025, ASL-ROOM, or GSL-MEET',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectingScreen(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child:
                Icon(
                      Icons.video_call,
                      size: 80,
                      color: theme.colorScheme.primary,
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 2000.ms,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
          ).animate().scale(duration: 1000.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 32),
          Text(
            'Connecting to Room...',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
          const SizedBox(height: 16),
          Text(
            'Setting up translation services',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildActiveCallScreen(
    BuildContext context,
    ThemeData theme,
    VideoConferenceState videoState,
  ) {
    return Center(
      child:
          Container(
                width: double.infinity,
                height: 300,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.4,
                              ),
                              theme.colorScheme.secondaryContainer.withValues(
                                alpha: 0.6,
                              ),
                              theme.colorScheme.tertiaryContainer.withValues(
                                alpha: 0.4,
                              ),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                    Icons.videocam,
                                    size: 60,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  )
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  )
                                  .shimmer(
                                    duration: 2000.ms,
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.3),
                                  ),
                              const SizedBox(height: 16),
                              Text(
                                'Live Video Feed',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Room: ${videoState.roomId}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .scale(begin: const Offset(0.9, 0.9), duration: 600.ms),
    );
  }

  Widget _buildErrorScreen(
    BuildContext context,
    ThemeData theme,
    String error,
  ) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ).animate().scale(duration: 600.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationOverlay(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) {
    final videoNotifier = ref.read(videoConferenceNotifierProvider.notifier);
    final translationState = videoNotifier.translationState;
    final currentTranslation = videoNotifier.currentTranslation;

    if (translationState == RecognitionState.idle ||
        currentTranslation == null) {
      return _buildTranslationStatus(context, translationState, language);
    }

    return _buildTranslationResult(context, currentTranslation, language);
  }

  Widget _buildTranslationStatus(
    BuildContext context,
    RecognitionState state,
    AppLanguage language,
  ) {
    final theme = Theme.of(context);
    final statusColor = _getTranslationStatusColor(theme, state);
    final statusMessage = _getTranslationStatusMessage(state);

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor, width: 2),
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Text(
                  '$statusMessage (${language == AppLanguage.asl ? 'ASL' : 'GSL'})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, duration: 500.ms);
  }

  Widget _buildTranslationResult(
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
              Row(
                children: [
                  Icon(
                    Icons.record_voice_over,
                    color: confidenceColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${language == AppLanguage.asl ? 'ASL' : 'GSL'} Translation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  translation.text,
                  style: theme.textTheme.headlineSmall?.copyWith(
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

  Widget _buildTopBar(
    BuildContext context,
    VideoConferenceState videoState,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              ref.read(videoConferenceNotifierProvider.notifier).leaveCall();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: videoState.callState == CallState.connected
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room: ${videoState.roomId}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDuration(videoState.callDuration),
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  )
                : Text(
                    'LinguaSigna Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    VideoConferenceState videoState,
    WidgetRef ref,
  ) {
    if (videoState.callState != CallState.connected) {
      return const SizedBox.shrink();
    }

    final videoNotifier = ref.read(videoConferenceNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: videoState.isLocalAudioEnabled ? Icons.mic : Icons.mic_off,
            label: 'Audio',
            onPressed: () => ref
                .read(videoConferenceNotifierProvider.notifier)
                .toggleLocalAudio(),
            isActive: videoState.isLocalAudioEnabled,
          ),
          _buildControlButton(
            icon: videoState.isLocalVideoEnabled
                ? Icons.videocam
                : Icons.videocam_off,
            label: 'Video',
            onPressed: () => ref
                .read(videoConferenceNotifierProvider.notifier)
                .toggleLocalVideo(),
            isActive: videoState.isLocalVideoEnabled,
          ),
          _buildControlButton(
            icon: videoNotifier.translationState != RecognitionState.idle
                ? Icons.closed_caption
                : Icons.closed_caption_off,
            label: 'Translation',
            onPressed: () => videoNotifier.toggleTranslation(),
            isActive: videoNotifier.translationState != RecognitionState.idle,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            onPressed: () {
              ref.read(videoConferenceNotifierProvider.notifier).leaveCall();
              Navigator.of(context).pop();
            },
            isActive: false,
            isEndCall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
    bool isEndCall = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isEndCall
                ? Colors.red.withValues(alpha: 0.8)
                : (isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.5)),
            shape: BoxShape.circle,
            border: Border.all(
              color: isEndCall
                  ? Colors.red
                  : (isActive ? Colors.white : Colors.grey),
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: isEndCall
                  ? Colors.white
                  : (isActive ? Colors.white : Colors.grey),
            ),
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Helper methods
  Color _getTranslationStatusColor(ThemeData theme, RecognitionState state) {
    switch (state) {
      case RecognitionState.idle:
        return Colors.grey;
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

  String _getTranslationStatusMessage(RecognitionState state) {
    switch (state) {
      case RecognitionState.idle:
        return 'Translation Off';
      case RecognitionState.initializing:
        return 'Initializing...';
      case RecognitionState.ready:
        return 'Ready to Translate';
      case RecognitionState.translating:
        return 'Translating...';
      case RecognitionState.error:
        return 'Translation Error';
    }
  }

  Color _getConfidenceColor(ThemeData theme, double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

}
