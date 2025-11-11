import 'package:equatable/equatable.dart';

class AppLocale extends Equatable {
  const AppLocale({
    required this.languageCode,
    this.countryCode,
  });

  final String languageCode;
  final String? countryCode;

  String get tag => countryCode == null || countryCode!.isEmpty
      ? languageCode
      : '${languageCode}_$countryCode';

  static AppLocale? fromTag(final String? tag) {
    if (tag == null || tag.isEmpty) {
      return null;
    }
    final parts = tag.split('_');
    if (parts.isEmpty) return null;
    if (parts.length == 1) {
      return AppLocale(languageCode: parts.first);
    }
    return AppLocale(languageCode: parts.first, countryCode: parts[1]);
  }

  @override
  List<Object?> get props => [languageCode, countryCode];
}
