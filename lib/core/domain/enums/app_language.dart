enum AppLanguage {
  asl('ASL', 'American Sign Language', 'United States, Canada', '45 MB', '94%'),
  gsl('GSL', 'Ghanaian Sign Language', 'Ghana', '42 MB', '91%');
  
  const AppLanguage(
    this.code,
    this.name,
    this.region,
    this.modelSize,
    this.accuracy,
  );
  
  final String code;
  final String name;
  final String region;
  final String modelSize;
  final String accuracy;
  
  String get description => '$region • Model: $modelSize • Accuracy: $accuracy';
  
  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.asl,
    );
  }
}