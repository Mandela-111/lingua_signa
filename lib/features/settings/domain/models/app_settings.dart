import 'package:equatable/equatable.dart';

import '../../../../core/domain/enums/app_language.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.selectedLanguage,
    required this.isAutoTranslate,
    required this.translationTextSize,
    required this.joinWithVideo,
    required this.joinWithAudio,
    required this.showConfidence,
    required this.saveHistory,
    required this.isAutoDetectLanguage,
    required this.hdVideoQuality,
    required this.defaultVideoLayout,
    required this.highContrast,
    required this.largeText,
    required this.reduceMotion,
    required this.hapticFeedback,
    required this.voiceFeedback,
  });
  
  final AppLanguage selectedLanguage;
  final bool isAutoTranslate;
  final int translationTextSize;
  final bool joinWithVideo;
  final bool joinWithAudio;
  final bool showConfidence;
  final bool saveHistory;
  final bool isAutoDetectLanguage;
  final bool hdVideoQuality;
  final String defaultVideoLayout;
  final bool highContrast;
  final bool largeText;
  final bool reduceMotion;
  final int hapticFeedback;
  final bool voiceFeedback;
  
  factory AppSettings.initial() {
    return const AppSettings(
      selectedLanguage: AppLanguage.asl,
      isAutoTranslate: true,
      translationTextSize: 18,
      joinWithVideo: true,
      joinWithAudio: true,
      showConfidence: true,
      saveHistory: true,
      isAutoDetectLanguage: false,
      hdVideoQuality: false,
      defaultVideoLayout: 'grid',
      highContrast: false,
      largeText: false,
      reduceMotion: false,
      hapticFeedback: 1,
      voiceFeedback: false,
    );
  }
  
  AppSettings copyWith({
    AppLanguage? selectedLanguage,
    bool? isAutoTranslate,
    int? translationTextSize,
    bool? joinWithVideo,
    bool? joinWithAudio,
    bool? showConfidence,
    bool? saveHistory,
    bool? isAutoDetectLanguage,
    bool? hdVideoQuality,
    String? defaultVideoLayout,
    bool? highContrast,
    bool? largeText,
    bool? reduceMotion,
    int? hapticFeedback,
    bool? voiceFeedback,
  }) {
    return AppSettings(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isAutoTranslate: isAutoTranslate ?? this.isAutoTranslate,
      translationTextSize: translationTextSize ?? this.translationTextSize,
      joinWithVideo: joinWithVideo ?? this.joinWithVideo,
      joinWithAudio: joinWithAudio ?? this.joinWithAudio,
      showConfidence: showConfidence ?? this.showConfidence,
      saveHistory: saveHistory ?? this.saveHistory,
      isAutoDetectLanguage: isAutoDetectLanguage ?? this.isAutoDetectLanguage,
      hdVideoQuality: hdVideoQuality ?? this.hdVideoQuality,
      defaultVideoLayout: defaultVideoLayout ?? this.defaultVideoLayout,
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      voiceFeedback: voiceFeedback ?? this.voiceFeedback,
    );
  }
  
  @override
  List<Object?> get props => [
    selectedLanguage,
    isAutoTranslate,
    translationTextSize,
    joinWithVideo,
    joinWithAudio,
    showConfidence,
    saveHistory,
    isAutoDetectLanguage,
    hdVideoQuality,
    defaultVideoLayout,
    highContrast,
    largeText,
    reduceMotion,
    hapticFeedback,
    voiceFeedback,
  ];
}