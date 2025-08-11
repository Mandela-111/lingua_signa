import 'dart:async';
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../services/camera_service.dart';

part 'camera_provider.g.dart';

/// Camera state management with Riverpod integration
@riverpod
class CameraNotifier extends _$CameraNotifier {
  CameraService? _cameraService;
  StreamSubscription<Uint8List>? _frameSubscription;

  @override
  CameraState build() {
    // Initialize camera service
    _cameraService = CameraService();
    
    // Dispose camera service when provider is disposed
    ref.onDispose(() {
      _disposeCamera();
    });

    return const CameraState(
      isInitialized: false,
      isCapturing: false,
      hasPermission: false,
      currentFrame: null,
      error: null,
      frameCount: 0,
    );
  }

  /// Initialize camera with permissions
  Future<void> initializeCamera() async {
    if (state.isInitialized) return;

    try {
      // Set loading state
      state = state.copyWith(
        error: null,
      );

      final success = await _cameraService!.initialize();
      
      if (success) {
        state = state.copyWith(
          isInitialized: true,
          hasPermission: true,
          error: null,
        );
      } else {
        state = state.copyWith(
          isInitialized: false,
          hasPermission: false,
          error: 'Failed to initialize camera',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isInitialized: false,
        hasPermission: false,
        error: 'Camera initialization error: $e',
      );
    }
  }

  /// Start capturing camera frames for real-time translation
  Future<void> startCapture() async {
    if (!state.isInitialized || state.isCapturing) return;

    try {
      state = state.copyWith(
        isCapturing: true,
        error: null,
      );

      await _cameraService!.startCapture(
        onFrame: _onNewFrame,
        captureInterval: const Duration(milliseconds: 500), // 2 FPS for ML processing
      );
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        error: 'Failed to start camera capture: $e',
      );
    }
  }

  /// Stop capturing camera frames
  Future<void> stopCapture() async {
    if (!state.isCapturing) return;

    try {
      await _cameraService!.stopCapture();
      await _frameSubscription?.cancel();
      _frameSubscription = null;

      state = state.copyWith(
        isCapturing: false,
        currentFrame: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to stop camera capture: $e',
      );
    }
  }

  /// Handle new camera frame
  void _onNewFrame(Uint8List frameBytes) {
    if (!state.isCapturing) return;

    final frame = CameraFrame(
      imageBytes: frameBytes,
      timestamp: DateTime.now(),
      width: 640,
      height: 480,
      aspectRatio: 4/3,
    );

    state = state.copyWith(
      currentFrame: frame,
      frameCount: state.frameCount + 1,
    );
  }

  /// Get camera information
  Map<String, dynamic> getCameraInfo() {
    return _cameraService?.getCameraInfo() ?? {};
  }

  /// Toggle flash (for low light conditions)
  Future<void> toggleFlash() async {
    if (!state.isInitialized) return;
    
    try {
      await _cameraService!.toggleFlash();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to toggle flash: $e',
      );
    }
  }

  /// Switch between front and back cameras
  Future<void> switchCamera() async {
    if (!state.isInitialized) return;

    try {
      await _cameraService!.switchCamera();
      // Camera info might change after switching
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to switch camera: $e',
      );
    }
  }

  /// Get current frame for ML processing
  CameraFrame? getCurrentFrame() {
    return state.currentFrame;
  }

  /// Check if camera has flash capability
  Future<bool> hasFlash() async {
    if (!state.isInitialized) return false;
    return await _cameraService!.isFlashAvailable();
  }

  /// Dispose camera resources
  Future<void> _disposeCamera() async {
    await stopCapture();
    await _cameraService?.dispose();
    _cameraService = null;
  }

  /// Clear any camera errors
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Camera state data class
class CameraState extends Equatable {
  final bool isInitialized;
  final bool isCapturing;
  final bool hasPermission;
  final CameraFrame? currentFrame;
  final String? error;
  final int frameCount;

  const CameraState({
    required this.isInitialized,
    required this.isCapturing,
    required this.hasPermission,
    required this.currentFrame,
    required this.error,
    required this.frameCount,
  });

  /// Create a copy of this state with modified fields
  CameraState copyWith({
    bool? isInitialized,
    bool? isCapturing,
    bool? hasPermission,
    CameraFrame? currentFrame,
    String? error,
    int? frameCount,
  }) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      hasPermission: hasPermission ?? this.hasPermission,
      currentFrame: currentFrame ?? this.currentFrame,
      error: error ?? this.error,
      frameCount: frameCount ?? this.frameCount,
    );
  }

  /// Check if camera is ready for capture
  bool get isReady => isInitialized && hasPermission;

  /// Check if there's a recent frame (within last 2 seconds)
  bool get hasRecentFrame {
    if (currentFrame == null) return false;
    final now = DateTime.now();
    final frameDiff = now.difference(currentFrame!.timestamp);
    return frameDiff.inSeconds <= 2;
  }

  /// Get frames per second based on frame count
  double get averageFPS {
    if (frameCount == 0) return 0.0;
    // Rough FPS calculation (would need more sophisticated timing in production)
    return frameCount / (frameCount * 0.5); // Assuming 500ms intervals
  }

  @override
  List<Object?> get props => [
    isInitialized,
    isCapturing,
    hasPermission,
    currentFrame,
    error,
    frameCount,
  ];
}

/// Camera state selector providers for optimized rebuilds
@riverpod
bool isCameraReady(Ref ref) {
  return ref.watch(cameraNotifierProvider.select((state) => state.isReady));
}

@riverpod
bool isCameraCapturing(Ref ref) {
  return ref.watch(cameraNotifierProvider.select((state) => state.isCapturing));
}

@riverpod
CameraFrame? currentCameraFrame(Ref ref) {
  return ref.watch(cameraNotifierProvider.select((state) => state.currentFrame));
}

@riverpod
String? cameraError(Ref ref) {
  return ref.watch(cameraNotifierProvider.select((state) => state.error));
}

@riverpod
bool hasCameraPermission(Ref ref) {
  return ref.watch(cameraNotifierProvider.select((state) => state.hasPermission));
}

@riverpod
int cameraFrameCount(Ref ref) {
  return ref.watch(cameraNotifierProvider.select((state) => state.frameCount));
}

/// Camera statistics provider for demo dashboard
@riverpod
CameraStats cameraStats(Ref ref) {
  final state = ref.watch(cameraNotifierProvider);
  
  return CameraStats(
    isActive: state.isCapturing,
    frameCount: state.frameCount,
    averageFPS: state.averageFPS,
    lastFrameTime: state.currentFrame?.timestamp,
    hasRecentFrame: state.hasRecentFrame,
  );
}

/// Camera statistics data class for monitoring
class CameraStats extends Equatable {
  final bool isActive;
  final int frameCount;
  final double averageFPS;
  final DateTime? lastFrameTime;
  final bool hasRecentFrame;

  const CameraStats({
    required this.isActive,
    required this.frameCount,
    required this.averageFPS,
    required this.lastFrameTime,
    required this.hasRecentFrame,
  });

  @override
  List<Object?> get props => [
    isActive,
    frameCount,
    averageFPS,
    lastFrameTime,
    hasRecentFrame,
  ];
}
