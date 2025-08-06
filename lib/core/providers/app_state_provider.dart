import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/app_state.dart';
import '../domain/enums/app_language.dart';

part 'app_state_provider.g.dart';

@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    return const AppState(
      selectedLanguage: AppLanguage.asl,
      isInitialized: true,
      isLoading: false,
    );
  }
  
  /// Set the selected sign language
  void setSelectedLanguage(AppLanguage language) {
    state = state.copyWith(selectedLanguage: language);
  }
  
  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
  
  /// Set initialization state
  void setInitialized(bool isInitialized) {
    state = state.copyWith(isInitialized: isInitialized);
  }
  
  /// Reset app state to defaults
  void reset() {
    state = const AppState(
      selectedLanguage: AppLanguage.asl,
      isInitialized: true,
      isLoading: false,
    );
  }
}