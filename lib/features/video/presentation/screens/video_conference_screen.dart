import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../navigation/presentation/navigation_service.dart';
import '../widgets/video_app_bar.dart';
import '../widgets/room_join_view.dart';
import '../widgets/call_view.dart';
import '../providers/video_conference_provider.dart';
import '../../domain/enums/call_state.dart';
import '../../domain/models/video_conference_state.dart';

class VideoConferenceScreen extends ConsumerWidget {
  const VideoConferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.watch(navigationServiceProvider);
    final videoState = ref.watch(videoConferenceNotifierProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // Handle back button - leave call if active
        if (videoState.callState == CallState.connected ||
            videoState.callState == CallState.connecting) {
          await ref.read(videoConferenceNotifierProvider.notifier).leaveCall();
        }
        
        if (context.mounted) {
          navigationService.goBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: videoState.callState == CallState.connected 
            ? Colors.black 
            : null,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              VideoAppBar(
                onBack: () async {
                  if (videoState.callState == CallState.connected ||
                      videoState.callState == CallState.connecting) {
                    await ref.read(videoConferenceNotifierProvider.notifier).leaveCall();
                  }
                  
                  if (context.mounted) {
                    navigationService.goBack(context);
                  }
                },
                callState: videoState.callState,
              ),
              
              // Main Content
              Expanded(
                child: _buildMainContent(videoState),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMainContent(VideoConferenceState videoState) {
    switch (videoState.callState) {
      case CallState.idle:
        return const RoomJoinView();
      case CallState.connecting:
      case CallState.connected:
        return const CallView();
      case CallState.error:
        return _ErrorView(error: videoState.error);
    }
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.error});
  
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'An unexpected error occurred',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ref.read(videoConferenceNotifierProvider.notifier).reset(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}