import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/home_header.dart';
import '../widgets/main_actions.dart';
import '../widgets/quick_stats.dart';
import '../widgets/settings_access.dart';
import '../widgets/demo_access.dart';
import '../widgets/footer_info.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            const SliverToBoxAdapter(
              child: HomeHeader(),
            ),
            
            // Main Actions
            const SliverToBoxAdapter(
              child: MainActions(),
            ),
            
            // Quick Stats
            const SliverToBoxAdapter(
              child: QuickStats(),
            ),
            
            // Settings Access
            const SliverToBoxAdapter(
              child: SettingsAccess(),
            ),
            
            // Demo Access
            const SliverToBoxAdapter(
              child: DemoAccess(),
            ),
            
            // Footer Info
            const SliverToBoxAdapter(
              child: FooterInfo(),
            ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}