import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_connection_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_realtime_client.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/cubit/carrier_line_cubit.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/cubit/carrier_line_state.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/presentation/pages/carrier_line_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCarrierLineCubit extends MockCubit<CarrierLineState>
    implements CarrierLineCubit {}

class _FakeRealtimeClient implements CarrierRealtimeClient {
  @override
  Uri get endpoint => Uri.parse('wss://line.example.invalid/v1');

  @override
  Stream<CarrierConnectionStatus> get connectionStates =>
      const Stream<CarrierConnectionStatus>.empty();

  @override
  CarrierConnectionStatus get currentStatus =>
      CarrierConnectionStatus.connected;

  @override
  String? get lastError => null;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockCarrierLineCubit cubit;

  setUp(() {
    cubit = _MockCarrierLineCubit();
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.close()).thenAnswer((_) async {});
    when(() => cubit.realtimeClient).thenReturn(_FakeRealtimeClient());
    when(() => cubit.connectRealtime()).thenAnswer((_) async {});
    when(() => cubit.disconnectRealtime()).thenAnswer((_) async {});
    when(() => cubit.markRead(any())).thenAnswer((_) async {});
  });

  testWidgets(
    'acceptance: renders simulated banner, status cards, inbox; no push UI',
    (WidgetTester tester) async {
      when(() => cubit.state).thenReturn(
        CarrierLineState(
          isLoading: false,
          connection: CarrierConnectionStatus.connected,
          lineStatus: const LineStatusSnapshot(
            esim: LineLifecycleStatus.active,
            porting: LineLifecycleStatus.pending,
            billing: LineLifecycleStatus.active,
            esimDetail: 'Active fixture',
            portingDetail: 'Pending fixture',
            billingDetail: 'Current fixture',
          ),
          inbox: <CarrierInboxItem>[
            CarrierInboxItem(
              id: '1',
              kind: CarrierInboxKind.call,
              peerLabel: 'Acme',
              preview: 'Missed',
              occurredAt: DateTime.utc(2026, 1, 1),
              isUnread: true,
            ),
          ],
        ),
      );

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (BuildContext context, Widget? child) => MaterialApp(
            localizationsDelegates: appLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<CarrierLineCubit>.value(
              value: cubit,
              child: const CarrierLineDemoPage(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('carrier-line-connection-banner')),
        findsOneWidget,
      );
      expect(find.textContaining('Simulated'), findsWidgets);
      expect(
        find.byKey(const ValueKey<String>('carrier-line-esim-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('carrier-line-porting-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('carrier-line-billing-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('carrier-line-push-composed-note')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('carrier-line-push-card')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('carrier-line-push-register')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('carrier-line-inbox-1')),
        findsOneWidget,
      );
    },
  );
}
