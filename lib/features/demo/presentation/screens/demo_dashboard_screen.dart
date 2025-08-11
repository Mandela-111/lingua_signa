import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../navigation/presentation/navigation_service.dart';

class DemoDashboardScreen extends ConsumerWidget {
  const DemoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationService = ref.watch(navigationServiceProvider);
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Demo Header
            SliverToBoxAdapter(
              child: _DemoHeader(
                onBack: () => navigationService.goBack(context),
              ),
            ),
            
            // Demo Features Grid
            const SliverToBoxAdapter(
              child: _DemoFeaturesGrid(),
            ),
            
            // Demo Stats
            const SliverToBoxAdapter(
              child: _DemoStats(),
            ),
            
            // Demo Actions
            SliverToBoxAdapter(
              child: _DemoActions(
                navigationService: navigationService,
              ),
            ),
            
            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoHeader extends StatelessWidget {
  const _DemoHeader({required this.onBack});
  
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                // Back Button
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    foregroundColor: colorScheme.onSurface,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.3, end: 0),
                
                const SizedBox(width: 16),
                
                // Title
                Expanded(
                  child: Text(
                    'LinguaSigna Demo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),
                ),
                
                // Live Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .fade(duration: 800.ms, begin: 1.0, end: 0.3)
                          .then()
                          .fade(duration: 800.ms, begin: 0.3, end: 1.0),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.3, end: 0),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Subtitle
            Text(
              'Academic Project Demonstration\nReal-time ASL & GSL Translation Platform',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _DemoFeaturesGrid extends StatelessWidget {
  const _DemoFeaturesGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Core Features',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          )
              .animate(delay: 800.ms)
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _DemoFeatureCard(
                icon: Icons.camera_alt,
                title: 'Live Camera\nTranslation',
                subtitle: 'Real-time ASL/GSL',
                color: colorScheme.primary,
                animationDelay: 1000.ms,
              ),
              _DemoFeatureCard(
                icon: Icons.video_call,
                title: 'Video Bridge\nConferencing',
                subtitle: 'Integrated translation',
                color: colorScheme.secondary,
                animationDelay: 1200.ms,
              ),
              _DemoFeatureCard(
                icon: Icons.translate,
                title: 'ML-Powered\nEngine',
                subtitle: 'Advanced recognition',
                color: colorScheme.tertiary,
                animationDelay: 1400.ms,
              ),
              _DemoFeatureCard(
                icon: Icons.accessibility,
                title: 'Accessibility\nFirst',
                subtitle: 'Inclusive design',
                color: colorScheme.error,
                animationDelay: 1600.ms,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoFeatureCard extends StatelessWidget {
  const _DemoFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.animationDelay,
  });
  
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

class _DemoStats extends StatelessWidget {
  const _DemoStats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'Languages',
            value: '2',
            subtitle: 'ASL & GSL',
            animationDelay: 1800.ms,
          ),
          _StatItem(
            label: 'Accuracy',
            value: '95%',
            subtitle: 'ML Recognition',
            animationDelay: 2000.ms,
          ),
          _StatItem(
            label: 'Latency',
            value: '<200ms',
            subtitle: 'Real-time',
            animationDelay: 2200.ms,
          ),
        ],
      ),
    )
        .animate(delay: 1600.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.animationDelay,
  });
  
  final String label;
  final String value;
  final String subtitle;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      )
          .animate(delay: animationDelay)
          .fadeIn(duration: 500.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
    );
  }
}

class _DemoActions extends StatelessWidget {
  const _DemoActions({required this.navigationService});
  
  final NavigationService navigationService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Demo Access',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          )
              .animate(delay: 2400.ms)
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _DemoActionButton(
            icon: Icons.camera_alt,
            label: 'Start Lens Mode Demo',
            subtitle: 'Live camera translation',
            color: colorScheme.primary,
            onTap: () => navigationService.goToLens(context),
            animationDelay: 2600.ms,
          ),
          
          const SizedBox(height: 12),
          
          _DemoActionButton(
            icon: Icons.video_call,
            label: 'Launch Video Bridge',
            subtitle: 'Video conferencing with translation',
            color: colorScheme.secondary,
            onTap: () => navigationService.goToVideo(context),
            animationDelay: 2800.ms,
          ),
          
          const SizedBox(height: 12),
          
          _DemoActionButton(
            icon: Icons.settings,
            label: 'Configuration Panel',
            subtitle: 'Adjust settings and preferences',
            color: colorScheme.tertiary,
            onTap: () => navigationService.goToSettings(context),
            animationDelay: 3000.ms,
          ),
        ],
      ),
    );
  }
}

class _DemoActionButton extends StatelessWidget {
  const _DemoActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.animationDelay,
  });
  
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.2, end: 0);
  }
}
