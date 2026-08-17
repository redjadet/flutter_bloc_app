import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_sync_queue_inspector_sheet.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    required List<CounterSyncQueueEntry> entries,
  }) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final AppLocalizations l10n = AppLocalizations.of(context);
              return Scaffold(
                body: CounterSyncQueueInspectorSheet(
                  entries: entries,
                  l10n: l10n,
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows empty message', (tester) async {
    await pumpSheet(tester, entries: const <CounterSyncQueueEntry>[]);
    expect(find.text('No pending operations.'), findsOneWidget);
  });

  testWidgets('lists queue entries', (tester) async {
    await pumpSheet(
      tester,
      entries: const <CounterSyncQueueEntry>[
        CounterSyncQueueEntry(id: 'op-1', entityType: 'counter', retryCount: 2),
      ],
    );
    expect(find.byKey(const ValueKey<String>('sync-op-op-1')), findsOneWidget);
    expect(find.text('op-1'), findsOneWidget);
  });
}
