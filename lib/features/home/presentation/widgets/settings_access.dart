import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../navigation/presentation/navigation_service.dart';

class SettingsAccess extends ConsumerWidget {
  const SettingsAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.watch(navigationServiceProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: OutlinedButton.icon(
        onPressed: () => navigationService.goToSettings(context),
        icon: const Icon(Icons.settings),
        label: const Text('Settings & Preferences'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )
          .animate(delay: 1600.ms)
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.2, end: 0),
    );
  }
}