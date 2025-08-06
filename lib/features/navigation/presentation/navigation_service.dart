import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/app_routes.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

class NavigationService {
  /// Navigate to home screen
  void goToHome(BuildContext context) {
    context.goNamed(AppRoutes.homeName);
  }
  
  /// Navigate to lens mode screen
  void goToLens(BuildContext context) {
    context.pushNamed(AppRoutes.lensName);
  }
  
  /// Navigate to video conference screen
  void goToVideo(BuildContext context) {
    context.pushNamed(AppRoutes.videoName);
  }
  
  /// Navigate to settings screen
  void goToSettings(BuildContext context) {
    context.pushNamed(AppRoutes.settingsName);
  }
  
  /// Go back to previous screen or home if no previous screen
  void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goToHome(context);
    }
  }
  
  /// Replace current route with home
  void goToHomeAndClearStack(BuildContext context) {
    context.goNamed(AppRoutes.homeName);
  }
  
  /// Check if we can go back
  bool canGoBack(BuildContext context) {
    return context.canPop();
  }
  
  /// Get current route name
  String? getCurrentRouteName(BuildContext context) {
    final route = ModalRoute.of(context);
    return route?.settings.name;
  }
}