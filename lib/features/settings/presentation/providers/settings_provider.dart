import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/enums/app_language.dart';
import '../../domain/models/app_settings.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() {
    return AppSettings.initial();
  }
  
  /// Update selected sign language
  void updateSelectedLanguage(AppLanguage language) {
    state = state.copyWith(selectedLanguage: language);
  }
  
  /// Update auto-translate setting
  void updateAutoTranslate(bool enabled) {
    state = state.copyWith(isAutoTranslate: enabled);
  }
  
  /// Update translation text size
  void updateTranslationTextSize(int size) {
    state = state.copyWith(translationTextSize: size);
  }
  
  /// Update join with video setting
  void updateJoinWithVideo(bool enabled) {
    state = state.copyWith(joinWithVideo: enabled);
  }
  
  /// Update join with audio setting
  void updateJoinWithAudio(bool enabled) {
    state = state.copyWith(joinWithAudio: enabled);
  }
  
  /// Update show confidence setting
  void updateShowConfidence(bool enabled) {
    state = state.copyWith(showConfidence: enabled);
  }
  
  /// Update save history setting
  void updateSaveHistory(bool enabled) {
    state = state.copyWith(saveHistory: enabled);
  }
  
  /// Update auto-detect language setting
  void updateAutoDetectLanguage(bool enabled) {
    state = state.copyWith(isAutoDetectLanguage: enabled);
  }
  
  /// Update HD video quality setting
  void updateHdVideoQuality(bool enabled) {
    state = state.copyWith(hdVideoQuality: enabled);
  }
  
  /// Update default video layout
  void updateDefaultVideoLayout(String layout) {
    state = state.copyWith(defaultVideoLayout: layout);
  }
  
  /// Update high contrast setting
  void updateHighContrast(bool enabled) {
    state = state.copyWith(highContrast: enabled);
  }
  
  /// Update large text setting
  void updateLargeText(bool enabled) {
    state = state.copyWith(largeText: enabled);
  }
  
  /// Update reduce motion setting
  void updateReduceMotion(bool enabled) {
    state = state.copyWith(reduceMotion: enabled);
  }
  
  /// Update haptic feedback level
  void updateHapticFeedback(int level) {
    state = state.copyWith(hapticFeedback: level);
  }
  
  /// Update voice feedback setting
  void updateVoiceFeedback(bool enabled) {
    state = state.copyWith(voiceFeedback: enabled);
  }
  
  /// Reset all settings to defaults
  void resetToDefaults() {
    state = AppSettings.initial();
  }
}