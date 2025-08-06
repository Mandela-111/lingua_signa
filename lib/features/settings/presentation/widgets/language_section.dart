import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/domain/enums/app_language.dart';
import '../providers/settings_provider.dart';

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sign Language',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Language Options
            ...AppLanguage.values.map((language) {
              final isSelected = language == settings.selectedLanguage;
              
              return _LanguageOption(
                language: language,
                isSelected: isSelected,
                onTap: () => ref.read(settingsNotifierProvider.notifier)
                    .updateSelectedLanguage(language),
              );
            }),
            
            const SizedBox(height: 12),
            
            // Additional Options
            SwitchListTile(
              title: const Text('Auto-detect language'),
              subtitle: const Text('Automatically identify the sign language being used'),
              value: settings.isAutoDetectLanguage,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateAutoDetectLanguage(value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideX(begin: -0.2, end: 0)
        .fadeIn(duration: 400.ms);
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });
  
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Language Flag/Icon
            Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  language.code,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Language Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    language.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
                  .fadeIn(duration: 200.ms),
          ],
        ),
      ),
    );
  }
}