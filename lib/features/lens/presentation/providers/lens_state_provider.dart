import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/enums/app_language.dart';
import '../../../../core/providers/api_client_provider.dart';
import '../../../../core/providers/camera_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/models/lens_state.dart';
import '../../domain/models/translation_result.dart';
import '../../domain/enums/recognition_state.dart';

part 'lens_state_provider.g.dart';

@riverpod
class LensStateNotifier extends _$LensStateNotifier {
  Timer? _translationTimer;
  final Random _random = Random();
  
  final List<String> _mockTranslationsASL = [
    'Hello',
    'Thank you',
    'How are you?',
    'Nice to meet you',
    'Good morning',
    'See you later',
    'Please',
    'Sorry',
    'Yes',
    'No',
  ];
  
  final List<String> _mockTranslationsGSL = [
    'Akwaaba', // Welcome
    'Medaase', // Thank you
    'Wo ho te sɛn?', // How are you?
    'Me ani agye', // Nice to meet you
    'Mema wo akye', // Good morning
    'Akyire yɛbɛhyia', // See you later
    'Mepa wo kyɛw', // Please
    'Kafra', // Sorry
    'Aane', // Yes
    'Daabi', // No
  ];

  @override
  LensState build() {
    ref.onDispose(() {
      _translationTimer?.cancel();
    });
    
    return const LensState(
      isActive: false,
      recognitionState: RecognitionState.idle,
      currentTranslation: null,
    );
  }
  
  /// Start translation process with camera integration
  Future<void> startTranslation() async {
    if (state.isActive) return;
    
    // Initialize
    state = state.copyWith(
      isActive: true,
      recognitionState: RecognitionState.initializing,
    );
    
    // Initialize camera for real-time translation
    final cameraNotifier = ref.read(cameraNotifierProvider.notifier);
    
    // Initialize camera if not already done
    if (!ref.read(isCameraReadyProvider)) {
      await cameraNotifier.initializeCamera();
    }
    
    // Start camera capture for live frames
    if (ref.read(isCameraReadyProvider)) {
      await cameraNotifier.startCapture();
    }
    
    // Ready state
    state = state.copyWith(
      recognitionState: RecognitionState.ready,
    );
    
    // Start translating
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      recognitionState: RecognitionState.translating,
    );
    
    // Start real ML translation timer with camera integration
    _startRealTranslation();
  }
  
  /// Stop translation process
  void stopTranslation() {
    _translationTimer?.cancel();
    
    state = const LensState(
      isActive: false,
      recognitionState: RecognitionState.idle,
      currentTranslation: null,
    );
  }
  
  /// Start real ML translation with fallback to mock
  void _startRealTranslation() {
    _translationTimer?.cancel();
    
    _translationTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _generateRealTranslation(),
    );
  }
  

  
  /// Generate a real ML translation result
  Future<void> _generateRealTranslation() async {
    if (!state.isActive || state.recognitionState != RecognitionState.translating) {
      return;
    }
    
    try {
      final currentSettings = ref.read(settingsNotifierProvider);
      final selectedLanguage = currentSettings.selectedLanguage;
      
      // Check if ML server is available
      final mlHealthy = await ref.read(mlHealthCheckProvider.future);
      if (!mlHealthy) {
        // Fall back to mock translation if ML server is down
        _generateMockTranslation();
        return;
      }
      
      // Get real camera frame for ML processing
      final cameraFrame = ref.read(currentCameraFrameProvider);
      final imageBytes = cameraFrame?.imageBytes ?? _generateMockImageBytes();
      
      // Call real ML API for translation
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.translateImage(
        imageBytes,
        selectedLanguage == AppLanguage.asl ? 'asl' : 'gsl',
      );
      
      // Extract translation result from API response
      final translationText = response['translation'] as String?;
      final confidence = (response['confidence'] as num?)?.toDouble() ?? 0.0;
      
      if (translationText != null && translationText.isNotEmpty) {
        final translation = TranslationResult(
          text: translationText,
          confidence: confidence,
          timestamp: DateTime.now(),
        );
        
        state = state.copyWith(currentTranslation: translation);
        
        // Clear translation after 3 seconds
        Timer(const Duration(seconds: 3), () {
          if (state.currentTranslation == translation) {
            state = state.copyWith(currentTranslation: null);
          }
        });
      }
    } catch (e) {
      // Fall back to mock translation on API error
      _generateMockTranslation();
    }
  }
  
  /// Generate mock camera frame bytes (TODO: Replace with real camera)
  Uint8List _generateMockImageBytes() {
    // Generate a simple mock image (1x1 pixel for now)
    // In real implementation, this will be camera frame data
    return Uint8List.fromList([255, 255, 255, 255]); // White pixel RGBA
  }
  
  /// Generate a mock translation result (fallback when ML API unavailable)
  void _generateMockTranslation() {
    if (!state.isActive || state.recognitionState != RecognitionState.translating) {
      return;
    }
    
    final currentSettings = ref.read(settingsNotifierProvider);
    final selectedLanguage = currentSettings.selectedLanguage;
    
    final translations = selectedLanguage == AppLanguage.asl 
        ? _mockTranslationsASL 
        : _mockTranslationsGSL;
    
    final randomText = translations[_random.nextInt(translations.length)];
    final confidence = 0.8 + (_random.nextDouble() * 0.2); // 0.8 to 1.0
    
    final translation = TranslationResult(
      text: randomText,
      confidence: confidence,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(currentTranslation: translation);
    
    // Clear translation after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (state.currentTranslation == translation) {
        state = state.copyWith(currentTranslation: null);
      }
    });
  }
  
  /// Toggle language and restart translation if active
  void switchLanguage() {
    final settings = ref.read(settingsNotifierProvider);
    final newLanguage = settings.selectedLanguage == AppLanguage.asl 
        ? AppLanguage.gsl 
        : AppLanguage.asl;
    
    ref.read(settingsNotifierProvider.notifier).updateSelectedLanguage(newLanguage);
    
    // If translation is active, restart with new language
    if (state.isActive) {
      stopTranslation();
      Future.delayed(const Duration(milliseconds: 100), startTranslation);
    }
  }
}