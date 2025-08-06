import 'package:equatable/equatable.dart';

import '../enums/app_language.dart';

class AppState extends Equatable {
  const AppState({
    required this.selectedLanguage,
    required this.isInitialized,
    required this.isLoading,
  });
  
  final AppLanguage selectedLanguage;
  final bool isInitialized;
  final bool isLoading;
  
  AppState copyWith({
    AppLanguage? selectedLanguage,
    bool? isInitialized,
    bool? isLoading,
  }) {
    return AppState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object?> get props => [
    selectedLanguage,
    isInitialized,
    isLoading,
  ];
}