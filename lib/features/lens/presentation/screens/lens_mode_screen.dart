import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../navigation/presentation/navigation_service.dart';
import '../widgets/lens_app_bar.dart';
import '../widgets/camera_view.dart';
import '../widgets/lens_controls.dart';
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
          child: Column(
            children: [
              // Status Bar
              LensAppBar(
                onBack: () {
                  if (lensState.isActive) {
                    ref.read(lensStateNotifierProvider.notifier).stopTranslation();
                  }
                  navigationService.goBack(context);
                },
              ),
              
              // Camera View
              const Expanded(
                child: CameraView(),
              ),
              
              // Controls
              const LensControls(),
            ],
          ),
        ),
      ),
    );
  }
}