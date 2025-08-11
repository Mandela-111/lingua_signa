import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

part 'api_client_provider.g.dart';

/// Provides singleton instance of ApiClient for dependency injection
/// This enables clean architecture and easy testing/mocking
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final client = ApiClient();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    client.dispose();
  });
  
  return client;
}

/// Provides backend health check status
/// Updates automatically and can be watched by UI components
@riverpod
Future<bool> backendHealthCheck(Ref ref) async {
  final apiClient = ref.read(apiClientProvider);
  
  try {
    return await apiClient.checkBackendHealth();
  } catch (e) {
    // Return false if health check fails
    return false;
  }
}

/// Provides ML server health check status
/// Updates automatically and can be watched by UI components
@riverpod
Future<bool> mlHealthCheck(Ref ref) async {
  final apiClient = ref.read(apiClientProvider);
  
  try {
    return await apiClient.checkMLHealth();
  } catch (e) {
    // Return false if health check fails
    return false;
  }
}

/// Provides overall system health status
/// Combines backend and ML health checks
@riverpod
Future<SystemHealth> systemHealthCheck(Ref ref) async {
  final backendHealthFuture = ref.watch(backendHealthCheckProvider.future);
  final mlHealthFuture = ref.watch(mlHealthCheckProvider.future);
  
  try {
    final results = await Future.wait([
      backendHealthFuture,
      mlHealthFuture,
    ]);
    
    final backendHealth = results[0];
    final mlHealth = results[1];
    
    return SystemHealth(
      backendOnline: backendHealth,
      mlOnline: mlHealth,
      overallStatus: backendHealth && mlHealth 
          ? SystemStatus.online 
          : SystemStatus.degraded,
    );
  } catch (e) {
    return const SystemHealth(
      backendOnline: false,
      mlOnline: false,
      overallStatus: SystemStatus.offline,
    );
  }
}

/// System health data class
class SystemHealth {
  final bool backendOnline;
  final bool mlOnline;
  final SystemStatus overallStatus;
  
  const SystemHealth({
    required this.backendOnline,
    required this.mlOnline,
    required this.overallStatus,
  });
  
  /// Check if system is fully operational
  bool get isHealthy => overallStatus == SystemStatus.online;
  
  /// Get human-readable status message
  String get statusMessage {
    switch (overallStatus) {
      case SystemStatus.online:
        return 'All systems operational';
      case SystemStatus.degraded:
        return 'Some services unavailable';
      case SystemStatus.offline:
        return 'Systems offline';
    }
  }
  
  /// Get status color indicator
  String get statusColor {
    switch (overallStatus) {
      case SystemStatus.online:
        return '#4CAF50';  // Green
      case SystemStatus.degraded:
        return '#FF9800';  // Orange
      case SystemStatus.offline:
        return '#F44336';  // Red
    }
  }
}

/// System status enumeration
enum SystemStatus {
  online,
  degraded,
  offline,
}
