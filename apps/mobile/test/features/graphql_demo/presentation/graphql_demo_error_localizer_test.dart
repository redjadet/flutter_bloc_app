import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_error_localizer.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utilities/utilities.dart';

void main() {
  final AppLocalizationsEn l10n = AppLocalizationsEn();

  test('maps NetworkError offline to network l10n', () {
    expect(
      graphqlDemoErrorMessage(
        l10n,
        const NetworkError(message: 'x', kind: NetworkErrorKind.offline),
      ),
      l10n.graphqlSampleNetworkError,
    );
  });

  test('maps StorageError to data l10n', () {
    expect(
      graphqlDemoErrorMessage(
        l10n,
        const StorageError(message: 'x', kind: StorageErrorKind.read),
      ),
      l10n.graphqlSampleDataError,
    );
  });

  test('falls back to generic when message empty', () {
    expect(
      graphqlDemoErrorMessage(l10n, const UnknownError(message: '  ')),
      l10n.graphqlSampleGenericError,
    );
  });
}
