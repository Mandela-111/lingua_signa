// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiClientHash() => r'a4dadde8e3b89d500b9b5f57854496462051729e';

/// Provides singleton instance of ApiClient for dependency injection
/// This enables clean architecture and easy testing/mocking
///
/// Copied from [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = Provider<ApiClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiClientRef = ProviderRef<ApiClient>;
String _$backendHealthCheckHash() =>
    r'3ec7f87c251ebe5950d1c8129087eff6c21d445e';

/// Provides backend health check status
/// Updates automatically and can be watched by UI components
///
/// Copied from [backendHealthCheck].
@ProviderFor(backendHealthCheck)
final backendHealthCheckProvider = AutoDisposeFutureProvider<bool>.internal(
  backendHealthCheck,
  name: r'backendHealthCheckProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backendHealthCheckHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackendHealthCheckRef = AutoDisposeFutureProviderRef<bool>;
String _$mlHealthCheckHash() => r'8032e37b82b4820634050ed1d9cf7f8d82e7fffd';

/// Provides ML server health check status
/// Updates automatically and can be watched by UI components
///
/// Copied from [mlHealthCheck].
@ProviderFor(mlHealthCheck)
final mlHealthCheckProvider = AutoDisposeFutureProvider<bool>.internal(
  mlHealthCheck,
  name: r'mlHealthCheckProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mlHealthCheckHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MlHealthCheckRef = AutoDisposeFutureProviderRef<bool>;
String _$systemHealthCheckHash() => r'91f577463c2e8c767bc3c3064e36da0392e32217';

/// Provides overall system health status
/// Combines backend and ML health checks
///
/// Copied from [systemHealthCheck].
@ProviderFor(systemHealthCheck)
final systemHealthCheckProvider =
    AutoDisposeFutureProvider<SystemHealth>.internal(
      systemHealthCheck,
      name: r'systemHealthCheckProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$systemHealthCheckHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SystemHealthCheckRef = AutoDisposeFutureProviderRef<SystemHealth>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
