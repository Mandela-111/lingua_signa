import 'package:equatable/equatable.dart';

import 'translation_result.dart';
import '../enums/recognition_state.dart';

class LensState extends Equatable {
  const LensState({
    required this.isActive,
    required this.recognitionState,
    required this.currentTranslation,
  });
  
  final bool isActive;
  final RecognitionState recognitionState;
  final TranslationResult? currentTranslation;
  
  LensState copyWith({
    bool? isActive,
    RecognitionState? recognitionState,
    TranslationResult? currentTranslation,
  }) {
    return LensState(
      isActive: isActive ?? this.isActive,
      recognitionState: recognitionState ?? this.recognitionState,
      currentTranslation: currentTranslation ?? this.currentTranslation,
    );
  }
  
  @override
  List<Object?> get props => [
    isActive,
    recognitionState,
    currentTranslation,
  ];
}