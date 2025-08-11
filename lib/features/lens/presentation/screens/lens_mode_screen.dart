import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../navigation/presentation/navigation_service.dart';
import '../widgets/enhanced_camera_view.dart';
import '../providers/lens_state_provider.dart';

class LensModeScreen extends ConsumerWidget {
  const LensModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.watch(navigationServiceProvider);
    final lensState = ref.watch(lensStateNotifierProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (lensState.isActive) {
          ref.read(lensStateNotifierProvider.notifier).stopTranslation();
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
              // Enhanced Camera View (full screen)
              const EnhancedCameraView(),
              
              // Back button overlay
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () {
                    if (lensState.isActive) {
                      ref.read(lensStateNotifierProvider.notifier).stopTranslation();
                    }
                    navigationService.goBack(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}