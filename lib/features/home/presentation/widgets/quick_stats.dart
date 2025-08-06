import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '2',
              label: 'Languages',
            )
                .animate(delay: 1200.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              value: '24/7',
              label: 'Offline Ready',
            )
                .animate(delay: 1400.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });
  
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}