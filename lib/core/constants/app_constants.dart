class AppConstants {
  // App Information
  static const String appName = 'LinguaSigna';
  static const String appVersion = '1.0.0';
  static const String appDescription = 
      'Real-time sign language translation for ASL and GSL with integrated video conferencing';
  
  // Supported Languages
  static const List<String> supportedLanguages = ['ASL', 'GSL'];
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Camera Settings
  static const double defaultCameraAspectRatio = 16 / 9;
  static const int defaultCameraFPS = 30;
  
  // Translation Settings
  static const double defaultConfidenceThreshold = 0.7;
  static const int defaultTranslationTextSize = 18;
  static const Duration translationDisplayDuration = Duration(seconds: 3);
  
  // Video Call Settings
  static const String defaultVideoQuality = 'HD';
  static const int maxParticipants = 8;
  static const Duration callSetupTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String selectedLanguageKey = 'selected_language';
  static const String isAutoTranslateKey = 'is_auto_translate';
  static const String confidenceThresholdKey = 'confidence_threshold';
  static const String translationTextSizeKey = 'translation_text_size';
  static const String isHapticsEnabledKey = 'is_haptics_enabled';
  static const String isOfflineModeKey = 'is_offline_mode';
  
  // API Endpoints (for future use)
  static const String baseApiUrl = 'https://api.linguasigna.com';
  static const String mlApiEndpoint = '/ml/translate';
  static const String videoApiEndpoint = '/video/rooms';
  
  // Error Messages
  static const String cameraPermissionDenied = 'Camera permission is required for translation';
  static const String microphonePermissionDenied = 'Microphone permission is required for video calls';
  static const String networkError = 'Network connection error. Please try again';
  static const String translationError = 'Translation failed. Please try again';
  static const String videoCallError = 'Video call failed. Please check your connection';
  
  // Success Messages
  static const String settingsSaved = 'Settings saved successfully';
  static const String languageChanged = 'Language changed successfully';
  static const String callConnected = 'Call connected successfully';
  
  // Validation
  static const int minRoomIdLength = 4;
  static const int maxRoomIdLength = 8;
  static const String roomIdPattern = r'^[A-Z0-9]+$';
}