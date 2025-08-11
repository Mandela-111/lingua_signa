import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../navigation/presentation/navigation_service.dart';
import '../widgets/settings_app_bar.dart';
import '../widgets/language_section.dart';
import '../widgets/translation_section.dart';
import '../widgets/video_section.dart';
import '../widgets/accessibility_section.dart';
import '../widgets/about_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.watch(navigationServiceProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (context.mounted) {
          navigationService.goBack(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              SettingsAppBar(onBack: () => navigationService.goBack(context)),

              // Settings Content
              const Expanded(child: _SettingsContent()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language Settings
          LanguageSection()
              .animate(delay: 100.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Translation Settings
          TranslationSection()
              .animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Video Settings
          VideoSection()
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Accessibility Settings
          AccessibilitySection()
              .animate(delay: 400.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // About Section
          AboutSection()
              .animate(delay: 500.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}
