import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_locale.freezed.dart';

@freezed
abstract class AppLocale with _$AppLocale {
  const factory AppLocale({
    required final String languageCode,
    final String? countryCode,
  }) = _AppLocale;

  const AppLocale._();

  String get tag => switch (countryCode) {
    final code? when code.isNotEmpty => '${languageCode}_$code',
    _ => languageCode,
  };

  static AppLocale? fromTag(final String? tag) {
    if (tag == null || tag.isEmpty) {
      return null;
    }
    final List<String> parts = tag.split('_');
    if (parts.isEmpty) return null;
    if (parts.length == 1) {
      return AppLocale(languageCode: parts.first);
    }
    if (parts.length < 2) {
      return AppLocale(languageCode: parts.first);
    }
    return AppLocale(languageCode: parts.first, countryCode: parts[1]);
  }
}
