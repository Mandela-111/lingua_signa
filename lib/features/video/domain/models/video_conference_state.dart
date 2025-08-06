import 'package:equatable/equatable.dart';

import 'participant.dart';
import '../enums/call_state.dart';

class VideoConferenceState extends Equatable {
  const VideoConferenceState({
    required this.callState,
    required this.roomId,
    required this.participants,
    required this.isLocalVideoEnabled,
    required this.isLocalAudioEnabled,
    required this.callDuration,
    required this.error,
  });
  
  final CallState callState;
  final String roomId;
  final List<Participant> participants;
  final bool isLocalVideoEnabled;
  final bool isLocalAudioEnabled;
  final Duration callDuration;
  final String? error;
  
  VideoConferenceState copyWith({
    CallState? callState,
    String? roomId,
    List<Participant>? participants,
    bool? isLocalVideoEnabled,
    bool? isLocalAudioEnabled,
    Duration? callDuration,
    String? error,
  }) {
    return VideoConferenceState(
      callState: callState ?? this.callState,
      roomId: roomId ?? this.roomId,
      participants: participants ?? this.participants,
      isLocalVideoEnabled: isLocalVideoEnabled ?? this.isLocalVideoEnabled,
      isLocalAudioEnabled: isLocalAudioEnabled ?? this.isLocalAudioEnabled,
      callDuration: callDuration ?? this.callDuration,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [
    callState,
    roomId,
    participants,
    isLocalVideoEnabled,
    isLocalAudioEnabled,
    callDuration,
    error,
  ];
}