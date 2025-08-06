import 'package:equatable/equatable.dart';

class TranslationResult extends Equatable {
  const TranslationResult({
    required this.text,
    required this.confidence,
    required this.timestamp,
  });
  
  final String text;
  final double confidence;
  final DateTime timestamp;
  
  @override
  List<Object?> get props => [text, confidence, timestamp];
}