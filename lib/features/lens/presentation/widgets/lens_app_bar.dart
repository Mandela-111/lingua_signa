import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/lens_state_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/enums/recognition_state.dart';

class LensAppBar extends ConsumerWidget {
  const LensAppBar({
    super.key,
    required this.onBack,
  });
  
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lensState = ref.watch(lensStateNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withAlpha(26),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Back Button
            IconButton(
              onPressed: lensState.isActive ? null : onBack,
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(51),
                foregroundColor: lensState.isActive 
                    ? Colors.white.withAlpha(128)
                    : Colors.white,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Title and Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lens Mode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    settings.selectedLanguage.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ),
            
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(lensState.recognitionState).withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(lensState.recognitionState),
                ),
              ),
              child: Text(
                lensState.recognitionState.message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(RecognitionState state) {
    switch (state) {
      case RecognitionState.idle:
        return Colors.grey;
      case RecognitionState.initializing:
        return Colors.blue;
      case RecognitionState.ready:
        return Colors.orange;
      case RecognitionState.translating:
        return Colors.green;
      case RecognitionState.error:
        return Colors.red;
    }
  }
}