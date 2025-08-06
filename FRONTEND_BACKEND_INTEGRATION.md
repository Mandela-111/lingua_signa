# LinguaSigna Frontend-Backend Integration Guide

**Version**: 1.0  
**Date**: 2025-08-06  
**Integration Level**: Senior-Level Architecture  
**Status**: 🔧 Ready for Implementation

---

## 🎯 Integration Overview

This guide details how our **optimized Flutter frontend** will seamlessly integrate with backend services while maintaining our **clean architecture**, **zero technical debt**, and **production-ready quality**.

### Core Integration Principles
- **Maintain Clean Architecture** - Repository pattern with clear separation
- **Type Safety Throughout** - Generated models and API clients
- **Performance First** - Efficient data fetching and caching
- **Error Resilience** - Comprehensive error handling and offline support
- **Real-time Capabilities** - WebSocket integration for live features

---

## 🏗️ Current Frontend Architecture (Optimized)

### Existing Structure (Already Production-Ready)
```
lib/
├── core/
│   ├── providers/          # ✅ Global state (Riverpod 2.x)
│   ├── domain/            # ✅ Models and enums
│   └── theme/             # ✅ Material 3 theming
├── features/
│   ├── lens/              # ✅ Translation feature
│   ├── video/             # ✅ Video conferencing
│   ├── settings/          # ✅ User settings (optimized)
│   └── navigation/        # ✅ GoRouter navigation
└── main.dart              # ✅ App entry point
```

### Integration Strategy
We'll **extend** our existing architecture without breaking changes:
```
lib/
├── core/
│   ├── providers/         # ✅ Keep existing + add API providers
│   ├── domain/           # ✅ Keep existing + add API models  
│   ├── data/             # 🆕 Add repository layer
│   │   ├── repositories/ # 🆕 API abstractions
│   │   ├── services/     # 🆕 HTTP/WebSocket clients
│   │   └── models/       # 🆕 API response models
│   └── network/          # 🆕 Network configuration
├── features/             # ✅ Keep all existing + enhance
```

---

## 🔌 Repository Pattern Implementation

### 1. Abstract Repository Interfaces
```dart
// lib/core/domain/repositories/translation_repository.dart
abstract class TranslationRepository {
  Future<TranslationSession> startSession({
    required AppLanguage language,
    required String userId,
  });
  
  Future<TranslationResult> translateFrame({
    required String sessionId,
    required Uint8List frameData,
  });
  
  Future<void> endSession(String sessionId);
  
  Stream<TranslationResult> watchTranslations(String sessionId);
}

// lib/core/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<User> authenticate({
    required String email,
    required String password,
  });
  
  Future<UserSettings> getUserSettings(String userId);
  
  Future<void> updateSettings({
    required String userId,
    required UserSettings settings,
  });
  
  Stream<User> watchUserUpdates(String userId);
}

// lib/core/domain/repositories/video_repository.dart
abstract class VideoRepository {
  Future<VideoRoom> createRoom({
    required String userId,
    required VideoRoomConfig config,
  });
  
  Future<VideoRoom> joinRoom({
    required String roomCode,
    required String userId,
  });
  
  Future<void> leaveRoom(String roomId);
  
  Stream<List<Participant>> watchParticipants(String roomId);
  Stream<CallEvent> watchCallEvents(String roomId);
}
```

### 2. Concrete Repository Implementations
```dart
// lib/core/data/repositories/translation_repository_impl.dart
@riverpod
class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl({
    required this.apiClient,
    required this.wsClient,
  });
  
  final ApiClient apiClient;
  final WebSocketClient wsClient;

  @override
  Future<TranslationSession> startSession({
    required AppLanguage language,
    required String userId,
  }) async {
    try {
      final response = await apiClient.post('/translation/sessions', {
        'userId': userId,
        'language': language.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return TranslationSession.fromJson(response.data);
    } on ApiException catch (e) {
      throw TranslationException('Failed to start session: ${e.message}');
    }
  }

  @override
  Future<TranslationResult> translateFrame({
    required String sessionId,
    required Uint8List frameData,
  }) async {
    try {
      final response = await apiClient.post(
        '/translation/translate',
        {
          'sessionId': sessionId,
          'frameData': base64Encode(frameData),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      return TranslationResult.fromJson(response.data);
    } on ApiException catch (e) {
      throw TranslationException('Translation failed: ${e.message}');
    }
  }

  @override
  Stream<TranslationResult> watchTranslations(String sessionId) {
    return wsClient
        .connect('/translation/stream')
        .where((event) => event['sessionId'] == sessionId)
        .map((data) => TranslationResult.fromJson(data))
        .handleError((error) {
      throw TranslationException('Stream error: $error');
    });
  }
}
```

---

## 🔄 Provider Integration Strategy

### 1. Enhanced Providers (Extend Existing)
```dart
// lib/features/lens/presentation/providers/lens_state_provider.dart
// ENHANCE existing provider with API integration

@riverpod
class LensStateNotifier extends _$LensStateNotifier {
  Timer? _translationTimer;
  StreamSubscription<TranslationResult>? _translationStream;

  // Keep existing mock functionality for offline mode
  final Random _random = Random();
  final List<String> _mockTranslationsASL = [
    // ... existing mock data
  ];

  @override
  LensState build() {
    ref.onDispose(() {
      _translationTimer?.cancel();
      _translationStream?.cancel();
    });
    
    return const LensState(
      isActive: false,
      recognitionState: RecognitionState.idle,
      currentTranslation: null,
    );
  }

  /// Enhanced startTranslation with API integration
  Future<void> startTranslation() async {
    if (state.isActive) return;
    
    // Initialize
    state = state.copyWith(
      isActive: true,
      recognitionState: RecognitionState.initializing,
    );

    try {
      final user = ref.read(authStateProvider);
      final settings = ref.read(settingsNotifierProvider);
      
      if (user != null) {
        // API Mode: Real translation
        await _startApiTranslation(user.id, settings.selectedLanguage);
      } else {
        // Offline Mode: Mock translation (existing functionality)
        await _startMockTranslation();
      }
    } catch (e) {
      state = state.copyWith(
        recognitionState: RecognitionState.error,
      );
      // Handle error appropriately
    }
  }

  /// New API-based translation
  Future<void> _startApiTranslation(String userId, AppLanguage language) async {
    final repository = ref.read(translationRepositoryProvider);
    
    // Start session with backend
    final session = await repository.startSession(
      userId: userId,
      language: language,
    );
    
    // Ready state
    state = state.copyWith(
      recognitionState: RecognitionState.ready,
      sessionId: session.id, // Add sessionId to state
    );
    
    // Start real-time translation stream
    _translationStream = repository
        .watchTranslations(session.id)
        .listen((result) {
      state = state.copyWith(currentTranslation: result);
      
      // Clear after display time
      Timer(const Duration(seconds: 3), () {
        if (state.currentTranslation == result) {
          state = state.copyWith(currentTranslation: null);
        }
      });
    });
    
    // Start translating
    state = state.copyWith(
      recognitionState: RecognitionState.translating,
    );
    
    // Start camera frame processing
    _startFrameCapture();
  }

  /// Existing mock translation (keep for offline)
  Future<void> _startMockTranslation() async {
    // ... existing mock implementation
  }
}
```

### 2. Authentication Provider
```dart
// lib/core/providers/auth_provider.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Try to restore session from storage
    _tryRestoreSession();
    
    return const AuthState(
      user: null,
      isLoading: false,
      isAuthenticated: false,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final repository = ref.read(userRepositoryProvider);
      final user = await repository.authenticate(
        email: email,
        password: password,
      );
      
      // Store credentials securely
      await _storeSession(user);
      
      state = state.copyWith(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
      
      // Sync settings from backend
      await _syncUserSettings(user.id);
      
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _syncUserSettings(String userId) async {
    try {
      final repository = ref.read(userRepositoryProvider);
      final backendSettings = await repository.getUserSettings(userId);
      
      // Update local settings with backend data
      ref.read(settingsNotifierProvider.notifier)
          .syncFromBackend(backendSettings);
    } catch (e) {
      // Handle sync error gracefully
      print('Settings sync failed: $e');
    }
  }
}
```

### 3. Enhanced Settings Provider (Extend Existing)
```dart
// lib/features/settings/presentation/providers/settings_provider.dart
// ENHANCE existing optimized provider with API sync

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() {
    return AppSettings.initial();
  }

  /// Existing local update methods (keep all existing)
  void updateSelectedLanguage(AppLanguage language) {
    state = state.copyWith(selectedLanguage: language);
    _syncToBackend(); // Add backend sync
  }

  // ... keep all existing update methods and add sync

  /// New: Sync settings to backend
  Future<void> _syncToBackend() async {
    final user = ref.read(authStateProvider);
    if (user == null) return; // Offline mode
    
    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.updateSettings(
        userId: user.id,
        settings: _mapToBackendSettings(state),
      );
    } catch (e) {
      // Handle sync error gracefully - settings still work locally
      print('Settings sync failed: $e');
    }
  }

  /// New: Sync settings from backend
  Future<void> syncFromBackend(UserSettings backendSettings) async {
    state = _mapFromBackendSettings(backendSettings);
  }

  UserSettings _mapToBackendSettings(AppSettings local) {
    return UserSettings(
      selectedLanguage: local.selectedLanguage,
      isAutoTranslate: local.isAutoTranslate,
      translationTextSize: local.translationTextSize,
      // ... map all fields
    );
  }

  AppSettings _mapFromBackendSettings(UserSettings backend) {
    return state.copyWith(
      selectedLanguage: backend.selectedLanguage,
      isAutoTranslate: backend.isAutoTranslate,
      translationTextSize: backend.translationTextSize,
      // ... map all fields
    );
  }
}
```

---

## 🌐 Network Layer Implementation

### 1. HTTP Client Configuration
```dart
// lib/core/network/api_client.dart
@riverpod
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.authStorage,
  }) {
    _setupInterceptors();
  }

  final String baseUrl;
  final AuthStorage authStorage;
  late final Dio _dio;

  void _setupInterceptors() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await authStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            // Retry original request
            final clonedRequest = error.requestOptions;
            final response = await _dio.request(
              clonedRequest.path,
              options: Options(
                method: clonedRequest.method,
                headers: clonedRequest.headers,
              ),
              data: clonedRequest.data,
              queryParameters: clonedRequest.queryParameters,
            );
            handler.resolve(response);
            return;
          }
          // Logout user if refresh fails
          ref.read(authNotifierProvider.notifier).signOut();
        }
        handler.next(error);
      },
    ));

    // Logging interceptor (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger());
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) =>
      _dio.get<T>(path, queryParameters: params);

  Future<Response<T>> post<T>(String path, dynamic data) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, dynamic data) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) =>
      _dio.delete<T>(path);
}
```

### 2. WebSocket Client
```dart
// lib/core/network/websocket_client.dart
@riverpod
class WebSocketClient {
  WebSocketClient({
    required this.baseUrl,
    required this.authStorage,
  });

  final String baseUrl;
  final AuthStorage authStorage;
  IOWebSocketChannel? _channel;
  final Map<String, StreamController> _streams = {};

  Future<void> connect() async {
    final token = await authStorage.getAccessToken();
    final wsUrl = baseUrl.replaceFirst('http', 'ws');
    
    _channel = IOWebSocketChannel.connect(
      '$wsUrl?token=$token',
      pingInterval: const Duration(seconds: 30),
    );
    
    _channel!.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnection,
    );
  }

  Stream<Map<String, dynamic>> subscribe(String topic) {
    if (!_streams.containsKey(topic)) {
      _streams[topic] = StreamController<Map<String, dynamic>>.broadcast();
    }
    
    // Send subscription message
    _send({
      'type': 'subscribe',
      'topic': topic,
    });
    
    return _streams[topic]!.stream;
  }

  void _send(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message) as Map<String, dynamic>;
      final topic = data['topic'] as String?;
      
      if (topic != null && _streams.containsKey(topic)) {
        _streams[topic]!.add(data['payload']);
      }
    } catch (e) {
      print('WebSocket message parse error: $e');
    }
  }
}
```

---

## 📱 Real-time Features Integration

### 1. Camera Frame Processing
```dart
// lib/features/lens/data/services/camera_service.dart
@riverpod
class CameraService {
  CameraController? _controller;
  StreamSubscription<CameraImage>? _imageStream;

  Future<void> startCapture({
    required Function(Uint8List) onFrame,
    int fps = 10, // Process 10 frames per second
  }) async {
    if (_controller == null) {
      await _initializeCamera();
    }

    await _controller!.startImageStream((image) {
      // Throttle frame processing
      if (_shouldProcessFrame()) {
        final frameData = _convertImageToBytes(image);
        onFrame(frameData);
      }
    });
  }

  bool _shouldProcessFrame() {
    // Implement frame throttling logic
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastProcess = _lastFrameTime ?? 0;
    const interval = 100; // 100ms = 10fps
    
    if (now - lastProcess > interval) {
      _lastFrameTime = now;
      return true;
    }
    return false;
  }

  Uint8List _convertImageToBytes(CameraImage image) {
    // Convert CameraImage to bytes for API
    // Implementation depends on image format
    return Uint8List(0); // Placeholder
  }
}
```

### 2. Video Room Integration
```dart
// lib/features/video/presentation/providers/video_conference_provider.dart
// ENHANCE existing provider with real WebRTC

@riverpod
class VideoConferenceNotifier extends _$VideoConferenceNotifier {
  Timer? _callTimer;
  WebRTCService? _webrtcService;
  StreamSubscription<CallEvent>? _eventStream;

  @override
  VideoConferenceState build() {
    ref.onDispose(() {
      _callTimer?.cancel();
      _eventStream?.cancel();
      _webrtcService?.dispose();
    });
    
    return const VideoConferenceState(/* ... existing */);
  }

  /// Enhanced joinRoom with real backend
  Future<void> joinRoom(String roomId) async {
    if (roomId.isEmpty || roomId.length < 4) {
      state = state.copyWith(
        callState: CallState.error,
        error: 'Room ID must be at least 4 characters',
      );
      return;
    }

    state = state.copyWith(
      callState: CallState.connecting,
      roomId: roomId,
      error: null,
    );

    try {
      final user = ref.read(authStateProvider);
      
      if (user != null) {
        // API Mode: Real video calling
        await _joinRealRoom(roomId, user.id);
      } else {
        // Offline Mode: Mock functionality (existing)
        await _joinMockRoom(roomId);
      }
    } catch (e) {
      state = state.copyWith(
        callState: CallState.error,
        error: 'Failed to join room: ${e.toString()}',
      );
    }
  }

  Future<void> _joinRealRoom(String roomCode, String userId) async {
    final repository = ref.read(videoRepositoryProvider);
    
    // Join room via backend
    final room = await repository.joinRoom(
      roomCode: roomCode,
      userId: userId,
    );
    
    // Initialize WebRTC
    _webrtcService = ref.read(webRTCServiceProvider);
    await _webrtcService!.joinRoom(room.id);
    
    // Listen to call events
    _eventStream = repository.watchCallEvents(room.id).listen((event) {
      _handleCallEvent(event);
    });
    
    // Listen to participant updates
    repository.watchParticipants(room.id).listen((participants) {
      state = state.copyWith(participants: participants);
    });
    
    state = state.copyWith(
      callState: CallState.connected,
      participants: room.participants,
    );
    
    _startCallTimer();
  }

  Future<void> _joinMockRoom(String roomId) async {
    // Existing mock implementation for offline mode
    // ... keep existing mock functionality
  }
}
```

---

## 🔒 Security & Error Handling

### 1. Secure Token Storage
```dart
// lib/core/data/services/auth_storage.dart
@riverpod
class AuthStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  Future<String?> getAccessToken() async {
    try {
      return await FlutterSecureStorage().read(key: _accessTokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await FlutterSecureStorage().write(key: _accessTokenKey, value: accessToken);
    await FlutterSecureStorage().write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await FlutterSecureStorage().delete(key: _accessTokenKey);
    await FlutterSecureStorage().delete(key: _refreshTokenKey);
    await FlutterSecureStorage().delete(key: _userKey);
  }
}
```

### 2. Global Error Handling
```dart
// lib/core/providers/error_provider.dart
@riverpod
class ErrorNotifier extends _$ErrorNotifier {
  @override
  ErrorState build() {
    return const ErrorState(errors: []);
  }

  void handleError(dynamic error, {String? context}) {
    final appError = _mapToAppError(error, context);
    
    state = state.copyWith(
      errors: [...state.errors, appError],
    );
    
    // Auto-dismiss after 5 seconds
    Timer(const Duration(seconds: 5), () {
      dismissError(appError.id);
    });
    
    // Log error for monitoring
    _logError(appError);
  }

  void dismissError(String errorId) {
    state = state.copyWith(
      errors: state.errors.where((e) => e.id != errorId).toList(),
    );
  }

  AppError _mapToAppError(dynamic error, String? context) {
    if (error is ApiException) {
      return AppError(
        id: const Uuid().v4(),
        type: ErrorType.network,
        message: error.message,
        context: context,
        timestamp: DateTime.now(),
      );
    } else if (error is TranslationException) {
      return AppError(
        id: const Uuid().v4(),
        type: ErrorType.translation,
        message: error.message,
        context: context,
        timestamp: DateTime.now(),
      );
    }
    
    // Fallback for unknown errors
    return AppError(
      id: const Uuid().v4(),
      type: ErrorType.unknown,
      message: error.toString(),
      context: context,
      timestamp: DateTime.now(),
    );
  }
}
```

---

## 📊 Offline Support & Caching

### 1. Cache Implementation
```dart
// lib/core/data/services/cache_service.dart
@riverpod
class CacheService {
  static const _translationCacheKey = 'translation_cache';
  static const _userCacheKey = 'user_cache';
  
  final Hive _hive = Hive;

  Future<void> initialize() async {
    await _hive.openBox('app_cache');
  }

  Future<void> cacheTranslationSession(TranslationSession session) async {
    final box = _hive.box('app_cache');
    final cached = box.get(_translationCacheKey, defaultValue: <String, dynamic>{});
    cached[session.id] = session.toJson();
    await box.put(_translationCacheKey, cached);
  }

  Future<TranslationSession?> getCachedSession(String sessionId) async {
    final box = _hive.box('app_cache');
    final cached = box.get(_translationCacheKey, defaultValue: <String, dynamic>{});
    final sessionData = cached[sessionId];
    
    return sessionData != null 
        ? TranslationSession.fromJson(sessionData) 
        : null;
  }

  Future<void> syncWhenOnline() async {
    // Sync cached data when connectivity returns
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      await _syncCachedData();
    }
  }
}
```

### 2. Connectivity-Aware Providers
```dart
// lib/core/providers/connectivity_provider.dart
@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  StreamSubscription<ConnectivityResult>? _subscription;

  @override
  ConnectivityState build() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      
      state = state.copyWith(isOnline: isOnline);
      
      if (isOnline && !state.wasOnline) {
        // Just came online - trigger sync
        _triggerSync();
      }
      
      state = state.copyWith(wasOnline: isOnline);
    });
    
    return const ConnectivityState(isOnline: true, wasOnline: true);
  }

  void _triggerSync() {
    // Trigger sync across all relevant providers
    ref.read(cacheServiceProvider).syncWhenOnline();
  }
}
```

---

## 🎯 Integration Summary

### ✅ What We Keep (Zero Breaking Changes)
- **All existing optimized widgets** - no changes needed
- **Provider selectors** - continue working perfectly  
- **Navigation architecture** - GoRouter + PopScope patterns
- **Theme system** - Material 3 implementation
- **State management** - Riverpod 2.x with code generation

### 🆕 What We Add (Clean Extensions)
- **Repository layer** - abstract interfaces + implementations
- **Network clients** - HTTP + WebSocket with proper error handling
- **Authentication flow** - JWT with secure storage
- **Real-time capabilities** - WebSocket streams for live features
- **Offline support** - caching + sync when online
- **Error handling** - comprehensive error management

### 🚀 Benefits Achieved
- **Seamless offline-to-online** transition
- **Type-safe API integration** throughout
- **Performance maintained** with efficient caching
- **User experience preserved** with graceful degradation
- **Architecture integrity** with clean separation of concerns

---

**Ready for backend integration without compromising our optimized frontend!** 🎉
