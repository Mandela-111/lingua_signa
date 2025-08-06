import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/video_conference_state.dart';
import '../../domain/models/participant.dart';
import '../../domain/enums/call_state.dart';

part 'video_conference_provider.g.dart';

@riverpod
class VideoConferenceNotifier extends _$VideoConferenceNotifier {
  Timer? _callTimer;
  final Random _random = Random();
  
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
        final name = _mockParticipantNames[_random.nextInt(_mockParticipantNames.length)];
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
    state = state.copyWith(
      isLocalVideoEnabled: !state.isLocalVideoEnabled,
    );
  }
  
  /// Toggle local audio
  void toggleLocalAudio() {
    state = state.copyWith(
      isLocalAudioEnabled: !state.isLocalAudioEnabled,
    );
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
    
    _callTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (state.callState == CallState.connected) {
          state = state.copyWith(
            callDuration: Duration(seconds: timer.tick),
          );
        } else {
          timer.cancel();
        }
      },
    );
  }
}