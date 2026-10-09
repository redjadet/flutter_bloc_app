import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final AppLocalizationsEn l10n = AppLocalizationsEn();

  group('shouldShowSyncBanner', () {
    test('shows when offline, syncing, metadata, or pending UI enabled', () {
      expect(
        shouldShowSyncBanner(
          isOffline: true,
          isSyncing: false,
          pendingCount: 0,
        ),
        isTrue,
      );
      expect(
        shouldShowSyncBanner(
          isOffline: false,
          isSyncing: true,
          pendingCount: 0,
        ),
        isTrue,
      );
      expect(
        shouldShowSyncBanner(
          isOffline: false,
          isSyncing: false,
          pendingCount: 0,
          hasMetadata: true,
        ),
        isTrue,
      );
    });

    test(
      'hides when online idle with no metadata (default pending UI off)',
      () {
        expect(
          shouldShowSyncBanner(
            isOffline: false,
            isSyncing: false,
            pendingCount: 3,
          ),
          isFalse,
        );
      },
    );
  });

  group('syncBannerTitleAndMessage', () {
    test('offline wins over syncing', () {
      final (String title, String message) = syncBannerTitleAndMessage(
        l10n,
        isOffline: true,
        isSyncing: true,
        pendingCount: 2,
      );
      expect(title, l10n.syncStatusOfflineTitle);
      expect(message, l10n.syncStatusOfflineMessage(2));
    });

    test('syncing when online', () {
      final (String title, String message) = syncBannerTitleAndMessage(
        l10n,
        isOffline: false,
        isSyncing: true,
        pendingCount: 1,
      );
      expect(title, l10n.syncStatusSyncingTitle);
      expect(message, l10n.syncStatusSyncingMessage(1));
    });

    test('empty when idle and pending queue UI is off by default', () {
      final (String title, String message) = syncBannerTitleAndMessage(
        l10n,
        isOffline: false,
        isSyncing: false,
        pendingCount: 4,
      );
      expect(title, isEmpty);
      expect(message, isEmpty);
    });
  });
}
