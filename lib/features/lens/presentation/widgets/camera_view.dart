import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/lens_state_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/enums/recognition_state.dart';
import 'translation_overlay.dart';

class CameraView extends ConsumerWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lensState = ref.watch(lensStateNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    
    return Stack(
      children: [
        // Camera Preview Background
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a1a1a),
                Color(0xFF000000),
              ],
            ),
          ),
          child: const _MockCameraPreview(),
        ),
        
        // Recognition State Overlay
        if (lensState.recognitionState != RecognitionState.idle)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _RecognitionStateIndicator(
              state: lensState.recognitionState,
              selectedLanguage: settings.selectedLanguage,
            ),
          ),
        
        // Translation Overlay
        if (lensState.currentTranslation != null)
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: TranslationOverlay(
              translation: lensState.currentTranslation!,
              textSize: settings.translationTextSize.toDouble(),
            ),
          ),
        
        // Corner Guides
        if (lensState.isActive) ...[
          const Positioned(
            top: 40,
            left: 40,
            child: _CornerGuide(alignment: Alignment.topLeft),
          ),
          const Positioned(
            top: 40,
            right: 40,
            child: _CornerGuide(alignment: Alignment.topRight),
          ),
          const Positioned(
            bottom: 160,
            left: 40,
            child: _CornerGuide(alignment: Alignment.bottomLeft),
          ),
          const Positioned(
            bottom: 160,
            right: 40,
            child: _CornerGuide(alignment: Alignment.bottomRight),
          ),
        ],
      ],
    );
  }
}

class _MockCameraPreview extends StatelessWidget {
  const _MockCameraPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(25),
              Colors.black.withAlpha(76),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecognitionStateIndicator extends StatelessWidget {
  const _RecognitionStateIndicator({
    required this.state,
    required this.selectedLanguage,
  });
  
  final RecognitionState state;
  final dynamic selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(178),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: state.indicatorColor.withAlpha(128),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: state.indicatorColor,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 500.ms)
              .then()
              .fadeOut(duration: 500.ms),
          
          const SizedBox(width: 8),
          
          // Status Text
          Text(
            state.message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Language Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(76),
              ),
            ),
            child: Text(
              selectedLanguage.code,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -1.0, end: 0)
        .fadeIn(duration: 300.ms);
  }
}

class _CornerGuide extends StatelessWidget {
  const _CornerGuide({required this.alignment});
  
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: alignment.y < 0 ? BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ) : BorderSide.none,
          bottom: alignment.y > 0 ? BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ) : BorderSide.none,
          left: alignment.x < 0 ? BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ) : BorderSide.none,
          right: alignment.x > 0 ? BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ) : BorderSide.none,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 1000.ms)
        .then()
        .fadeOut(duration: 1000.ms);
  }
}