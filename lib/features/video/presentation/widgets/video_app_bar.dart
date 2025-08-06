import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/call_state.dart';
import '../providers/video_conference_provider.dart';

class VideoAppBar extends ConsumerWidget {
  const VideoAppBar({
    super.key,
    required this.onBack,
    required this.callState,
  });
  
  final VoidCallback onBack;
  final CallState callState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final videoState = ref.watch(videoConferenceNotifierProvider);
    
    return Container(
      color: callState == CallState.connected 
          ? Colors.black.withAlpha(128)
          : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Back Button
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: callState == CallState.connected 
                    ? Colors.white.withAlpha(51)
                    : theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                foregroundColor: callState == CallState.connected 
                    ? Colors.white 
                    : theme.colorScheme.onSurface,
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
                    'Video Bridge',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: callState == CallState.connected 
                          ? Colors.white 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (callState == CallState.connected && videoState.roomId.isNotEmpty)
                    Text(
                      'Room: ${videoState.roomId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: callState == CallState.connected 
                            ? Colors.white.withAlpha(179)
                            : theme.colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                ],
              ),
            ),
            
            // Call Duration
            if (callState == CallState.connected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDuration(videoState.callDuration),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            
            // Status Indicator
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(callState),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  
  Color _getStatusColor(CallState callState) {
    switch (callState) {
      case CallState.idle:
        return Colors.grey;
      case CallState.connecting:
        return Colors.orange;
      case CallState.connected:
        return Colors.green;
      case CallState.error:
        return Colors.red;
    }
  }
}