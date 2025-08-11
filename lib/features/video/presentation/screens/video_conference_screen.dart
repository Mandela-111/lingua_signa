import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../navigation/presentation/navigation_service.dart';
import '../widgets/enhanced_video_conference_view.dart';
import '../providers/video_conference_provider.dart';
import '../../domain/enums/call_state.dart';

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
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Enhanced Video Conference View (full screen)
              const EnhancedVideoConferenceView(),
              
              // Optional back button overlay (handled by enhanced view)
            ],
          ),
        ),
      ),
    );
  }
  
}