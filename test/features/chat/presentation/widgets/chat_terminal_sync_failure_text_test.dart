import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_terminal_sync_failure_text.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final AppLocalizationsEn l10n = AppLocalizationsEn();

  test('auth_required maps to chatAuthRefreshRequired', () {
    expect(terminalSyncFailureMessage(l10n, 'auth_required'), l10n.chatAuthRefreshRequired);
  });

  test('token_missing maps to chatTokenMissing', () {
    expect(terminalSyncFailureMessage(l10n, 'token_missing'), l10n.chatTokenMissing);
  });

  test('forbidden maps to chatSwitchAccount', () {
    expect(terminalSyncFailureMessage(l10n, 'forbidden'), l10n.chatSwitchAccount);
  });

  test('rate_limited maps to chatSessionEnded', () {
    expect(terminalSyncFailureMessage(l10n, 'rate_limited'), l10n.chatSessionEnded);
  });

  test('invalid_request maps to chatSessionEnded', () {
    expect(terminalSyncFailureMessage(l10n, 'invalid_request'), l10n.chatSessionEnded);
  });

  test('unknown code maps to chatSessionEnded', () {
    expect(terminalSyncFailureMessage(l10n, 'upstream_timeout'), l10n.chatSessionEnded);
  });
}
