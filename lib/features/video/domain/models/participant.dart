import 'package:equatable/equatable.dart';

class Participant extends Equatable {
  const Participant({
    required this.id,
    required this.name,
    required this.isVideoEnabled,
    required this.isAudioEnabled,
    required this.isMuted,
  });
  
  final String id;
  final String name;
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final bool isMuted;
  
  Participant copyWith({
    String? id,
    String? name,
    bool? isVideoEnabled,
    bool? isAudioEnabled,
    bool? isMuted,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isMuted: isMuted ?? this.isMuted,
    );
  }
  
  @override
  List<Object?> get props => [id, name, isVideoEnabled, isAudioEnabled, isMuted];
}