enum CallState {
  idle,
  connecting,
  connected,
  error,
}

extension CallStateExtension on CallState {
  String get displayName {
    switch (this) {
      case CallState.idle:
        return 'Ready to Join';
      case CallState.connecting:
        return 'Connecting...';
      case CallState.connected:
        return 'Connected';
      case CallState.error:
        return 'Connection Error';
    }
  }
  
  bool get isActive {
    return this == CallState.connecting || this == CallState.connected;
  }
}