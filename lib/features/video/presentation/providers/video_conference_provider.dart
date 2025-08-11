import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/video_conference_state.dart';
import '../../domain/models/participant.dart';
import '../../domain/enums/call_state.dart';
import '../../../lens/domain/models/translation_result.dart';
import '../../../lens/domain/enums/recognition_state.dart';
import '../../../../core/domain/enums/app_language.dart';
import '../../../../core/providers/api_client_provider.dart';
import '../../../../core/providers/camera_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

part 'video_conference_provider.g.dart';

@riverpod
class VideoConferenceNotifier extends _$VideoConferenceNotifier {
  Timer? _callTimer;
  Timer? _translationTimer;
  final Random _random = Random();

  // Translation state
  RecognitionState _translationState = RecognitionState.idle;
  TranslationResult? _currentTranslation;

  final List<String> _mockParticipantNames = [
    'Alice Johnson',
    'Bob Smith',
    'Carol Williams',
    'David Brown',
    'Emma Davis',
    'Frank Wilson',
  ];

  @override
  VideoConferenceState build() {
    ref.onDispose(() {
      _callTimer?.cancel();
      _translationTimer?.cancel();
    });

    return const VideoConferenceState(
      callState: CallState.idle,
      roomId: '',
      participants: [],
      isLocalVideoEnabled: true,
      isLocalAudioEnabled: true,
      callDuration: Duration.zero,
      error: null,
    );
  }

  /// Join a video call room
  Future<void> joinRoom(String roomId) async {
    if (roomId.isEmpty || roomId.length < 4) {
      state = state.copyWith(
        callState: CallState.error,
        error: 'Room ID must be at least 4 characters',
      );
      return;
    }

    // Set connecting state
    state = state.copyWith(
      callState: CallState.connecting,
      roomId: roomId,
      error: null,
    );

    try {
      // Simulate connection delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate mock participants
      final participantCount = _random.nextInt(3) + 1; // 1-3 participants
      final participants = List.generate(participantCount, (index) {
        final name =
            _mockParticipantNames[_random.nextInt(
              _mockParticipantNames.length,
            )];
        return Participant(
          id: 'participant_$index',
          name: name,
          isVideoEnabled: _random.nextBool(),
          isAudioEnabled: _random.nextBool(),
          isMuted: !_random.nextBool(),
        );
      });

      // Set connected state
      state = state.copyWith(
        callState: CallState.connected,
        participants: participants,
      );

      // Start call timer
      _startCallTimer();

      // Start real-time translation during video calls
      _startRealTimeTranslation();
    } catch (e) {
      state = state.copyWith(
        callState: CallState.error,
        error: 'Failed to join room: ${e.toString()}',
      );
    }
  }

  /// Leave the current call
  Future<void> leaveCall() async {
    _callTimer?.cancel();
    _translationTimer?.cancel();

    // Reset translation state
    _translationState = RecognitionState.idle;
    _currentTranslation = null;

    state = const VideoConferenceState(
      callState: CallState.idle,
      roomId: '',
      participants: [],
      isLocalVideoEnabled: true,
      isLocalAudioEnabled: true,
      callDuration: Duration.zero,
      error: null,
    );
  }

  /// Toggle local video
  void toggleLocalVideo() {
    state = state.copyWith(isLocalVideoEnabled: !state.isLocalVideoEnabled);
  }

  /// Toggle local audio
  void toggleLocalAudio() {
    state = state.copyWith(isLocalAudioEnabled: !state.isLocalAudioEnabled);
  }

  /// Reset to initial state
  void reset() {
    _callTimer?.cancel();

    state = const VideoConferenceState(
      callState: CallState.idle,
      roomId: '',
      participants: [],
      isLocalVideoEnabled: true,
      isLocalAudioEnabled: true,
      callDuration: Duration.zero,
      error: null,
    );
  }

  /// Start call duration timer
  void _startCallTimer() {
    _callTimer?.cancel();

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.callState == CallState.connected) {
        state = state.copyWith(callDuration: Duration(seconds: timer.tick));
      } else {
        timer.cancel();
      }
    });
  }

  /// Start real-time translation during video calls
  void _startRealTimeTranslation() {
    _translationTimer?.cancel();
    _translationState = RecognitionState.initializing;

    // Initialize camera for video translation
    Future.delayed(const Duration(milliseconds: 500), () {
      _translationState = RecognitionState.ready;

      // Start translation processing
      Future.delayed(const Duration(milliseconds: 300), () {
        _translationState = RecognitionState.translating;
        _startTranslationProcessing();
      });
    });
  }

  /// Process camera frames for real-time translation
  void _startTranslationProcessing() {
    _translationTimer?.cancel();

    _translationTimer = Timer.periodic(
      const Duration(seconds: 3), // Process every 3 seconds during calls
      (timer) async {
        if (state.callState != CallState.connected ||
            _translationState != RecognitionState.translating) {
          timer.cancel();
          return;
        }

        try {
          // Get current settings
          final settings = ref.read(settingsNotifierProvider);
          final selectedLanguage = settings.selectedLanguage;

          // Get camera frame for ML processing
          final cameraFrame = ref.read(currentCameraFrameProvider);
          final imageBytesList = cameraFrame?.imageBytes ?? _generateMockImageBytes();
          final imageBytes = imageBytesList is Uint8List ? imageBytesList : Uint8List.fromList(imageBytesList);

          // Call real ML API for translation
          final apiClient = ref.read(apiClientProvider);
          final response = await apiClient.translateImage(
            imageBytes,
            selectedLanguage == AppLanguage.asl ? 'asl' : 'gsl',
          );

          if (response['success'] == true) {
            final translationText = response['translation'] as String;
            final confidence = (response['confidence'] as num).toDouble();

            // Update current translation
            _currentTranslation = TranslationResult(
              text: translationText,
              confidence: confidence,
              timestamp: DateTime.now(),
            );

            // Clear translation after 4 seconds (longer for video calls)
            Timer(const Duration(seconds: 4), () {
              if (_currentTranslation?.timestamp ==
                  _currentTranslation?.timestamp) {
                _currentTranslation = null;
              }
            });
          }
        } catch (e) {
          // Fallback to mock translation for demo purposes
          _generateMockVideoTranslation(
            ref.read(settingsNotifierProvider).selectedLanguage,
          );
        }
      },
    );
  }

  /// Generate mock translation for video calls demo
  void _generateMockVideoTranslation(AppLanguage language) {
    final mockTranslationsASL = [
      'Hello everyone!',
      'Can you see me clearly?',
      'Thank you for joining',
      'Let me share my screen',
      'Any questions?',
      'Perfect!',
    ];

    final mockTranslationsGSL = [
      'Akwaaba obiaa!', // Hello everyone!
      'Mu tumi hu me yiye?', // Can you see me clearly?
      'Medaase se mo baa', // Thank you for joining
      'Momma me nkyɛre me screen', // Let me share my screen
      'Mo wɔ nsɛmmisa bi?', // Any questions?
      'Ɛyɛ adwo!', // Perfect!
    ];

    final translations = language == AppLanguage.asl
        ? mockTranslationsASL
        : mockTranslationsGSL;
    final randomText = translations[_random.nextInt(translations.length)];
    final confidence = 0.85 + (_random.nextDouble() * 0.15); // 0.85 to 1.0

    _currentTranslation = TranslationResult(
      text: randomText,
      confidence: confidence,
      timestamp: DateTime.now(),
    );

    // Clear translation after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (_currentTranslation?.text == randomText) {
        _currentTranslation = null;
      }
    });
  }

  /// Generate mock image bytes for ML processing
  List<int> _generateMockImageBytes() {
    // Generate mock image data for demo purposes
    return List.generate(1024, (index) => _random.nextInt(256));
  }

  /// Get current translation state for UI
  RecognitionState get translationState => _translationState;

  /// Get current translation result for UI
  TranslationResult? get currentTranslation => _currentTranslation;

  /// Toggle translation during video call
  void toggleTranslation() {
    if (_translationState == RecognitionState.idle) {
      _startRealTimeTranslation();
    } else {
      _translationTimer?.cancel();
      _translationState = RecognitionState.idle;
      _currentTranslation = null;
    }
  }
}
