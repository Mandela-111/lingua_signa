import 'package:flutter/material.dart';

enum RecognitionState {
  idle,
  initializing,
  ready,
  translating,
  error,
}

extension RecognitionStateExtension on RecognitionState {
  String get message {
    switch (this) {
      case RecognitionState.idle:
        return 'Tap the camera button to start translating';
      case RecognitionState.initializing:
        return 'Starting camera and loading model...';
      case RecognitionState.ready:
        return 'Ready to translate. Start signing!';
      case RecognitionState.translating:
        return 'Listening for signs...';
      case RecognitionState.error:
        return 'Error occurred. Please try again.';
    }
  }
  
  Color get indicatorColor {
    switch (this) {
      case RecognitionState.idle:
        return Colors.grey;
      case RecognitionState.initializing:
        return Colors.yellow;
      case RecognitionState.ready:
      case RecognitionState.translating:
        return Colors.green;
      case RecognitionState.error:
        return Colors.red;
    }
  }
}