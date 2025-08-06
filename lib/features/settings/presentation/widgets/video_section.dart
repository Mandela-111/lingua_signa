import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/settings_provider.dart';

class VideoSection extends ConsumerWidget {
  const VideoSection({super.key});

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
                  Icons.videocam,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Video Bridge',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Join with Video
            SwitchListTile(
              title: const Text('Join with video enabled'),
              subtitle: const Text('Turn on camera when joining video calls'),
              value: settings.joinWithVideo,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateJoinWithVideo(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 8),
            
            // Join with Audio
            SwitchListTile(
              title: const Text('Join with audio enabled'),
              subtitle: const Text('Turn on microphone when joining video calls'),
              value: settings.joinWithAudio,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateJoinWithAudio(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 8),
            
            // HD Video
            SwitchListTile(
              title: const Text('HD video quality'),
              subtitle: const Text('Use higher quality video (uses more data)'),
              value: settings.hdVideoQuality,
              onChanged: (value) => ref.read(settingsNotifierProvider.notifier)
                  .updateHdVideoQuality(value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 16),
            
            // Video Layout
            Text(
              'Default Video Layout',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 12),
            
            _VideoLayoutOption(
              title: 'Grid View',
              subtitle: 'Equal sized participant windows',
              icon: Icons.grid_view,
              isSelected: settings.defaultVideoLayout == 'grid',
              onTap: () => ref.read(settingsNotifierProvider.notifier)
                  .updateDefaultVideoLayout('grid'),
            ),
            
            const SizedBox(height: 8),
            
            _VideoLayoutOption(
              title: 'Speaker View',
              subtitle: 'Focus on active speaker',
              icon: Icons.person,
              isSelected: settings.defaultVideoLayout == 'speaker',
              onTap: () => ref.read(settingsNotifierProvider.notifier)
                  .updateDefaultVideoLayout('speaker'),
            ),
          ],
        ),
      ),
    )
        .animate(delay: 200.ms)
        .slideX(begin: -0.2, end: 0)
        .fadeIn(duration: 400.ms);
  }
}

class _VideoLayoutOption extends StatelessWidget {
  const _VideoLayoutOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border.all(color: theme.colorScheme.primary)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}