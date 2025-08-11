// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isCameraReadyHash() => r'fec9c9f974c77b0812e1e1f284a239529732bbb6';

/// Camera state selector providers for optimized rebuilds
///
/// Copied from [isCameraReady].
@ProviderFor(isCameraReady)
final isCameraReadyProvider = AutoDisposeProvider<bool>.internal(
  isCameraReady,
  name: r'isCameraReadyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isCameraReadyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsCameraReadyRef = AutoDisposeProviderRef<bool>;
String _$isCameraCapturingHash() => r'e852a9a755cc3b995ebee5196b8e5a7318dea425';

/// See also [isCameraCapturing].
@ProviderFor(isCameraCapturing)
final isCameraCapturingProvider = AutoDisposeProvider<bool>.internal(
  isCameraCapturing,
  name: r'isCameraCapturingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isCameraCapturingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsCameraCapturingRef = AutoDisposeProviderRef<bool>;
String _$currentCameraFrameHash() =>
    r'99acc5ab604345d7259791d33befdcd4d1f61cd1';

/// See also [currentCameraFrame].
@ProviderFor(currentCameraFrame)
final currentCameraFrameProvider = AutoDisposeProvider<CameraFrame?>.internal(
  currentCameraFrame,
  name: r'currentCameraFrameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCameraFrameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentCameraFrameRef = AutoDisposeProviderRef<CameraFrame?>;
String _$cameraErrorHash() => r'fbd09099e319292720bf513e317ce68aed6ea8df';

/// See also [cameraError].
@ProviderFor(cameraError)
final cameraErrorProvider = AutoDisposeProvider<String?>.internal(
  cameraError,
  name: r'cameraErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cameraErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CameraErrorRef = AutoDisposeProviderRef<String?>;
String _$hasCameraPermissionHash() =>
    r'e60b59d64cac34ed60c7f6c67f628a67e4511c68';

/// See also [hasCameraPermission].
@ProviderFor(hasCameraPermission)
final hasCameraPermissionProvider = AutoDisposeProvider<bool>.internal(
  hasCameraPermission,
  name: r'hasCameraPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasCameraPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasCameraPermissionRef = AutoDisposeProviderRef<bool>;
String _$cameraFrameCountHash() => r'7b125912b88b0444328d7d714e7d5b5434dbc2ef';

/// See also [cameraFrameCount].
@ProviderFor(cameraFrameCount)
final cameraFrameCountProvider = AutoDisposeProvider<int>.internal(
  cameraFrameCount,
  name: r'cameraFrameCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cameraFrameCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CameraFrameCountRef = AutoDisposeProviderRef<int>;
String _$cameraStatsHash() => r'ceaa6b689b31b927d569fe0d29a6a974bdff42f6';

/// Camera statistics provider for demo dashboard
///
/// Copied from [cameraStats].
@ProviderFor(cameraStats)
final cameraStatsProvider = AutoDisposeProvider<CameraStats>.internal(
  cameraStats,
  name: r'cameraStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cameraStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CameraStatsRef = AutoDisposeProviderRef<CameraStats>;
String _$cameraNotifierHash() => r'1bc29a31300e74354ba359f2fe803f9da15fb878';

/// Camera state management with Riverpod integration
///
/// Copied from [CameraNotifier].
@ProviderFor(CameraNotifier)
final cameraNotifierProvider =
    AutoDisposeNotifierProvider<CameraNotifier, CameraState>.internal(
      CameraNotifier.new,
      name: r'cameraNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cameraNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CameraNotifier = AutoDisposeNotifier<CameraState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
