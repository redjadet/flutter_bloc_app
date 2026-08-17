import 'package:design_system/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../test_helpers.dart' show FakeTimerService;

class _ImmediateCounterRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
  const _ImmediateCounterRepository(this.snapshot);

  final CounterSnapshot snapshot;

  @override
  Future<CounterSnapshot> load() async => snapshot;

  @override
  Future<void> save(CounterSnapshot snapshot) async {}

  @override
  Stream<CounterSnapshot> watch() async* {
    yield snapshot;
  }
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  @override
  Future<bool> authenticate({String? localizedReason}) async => true;
}

class _FakeErrorNotificationService implements ErrorNotificationService {
  @override
  Future<void> showAlertDialog(
    BuildContext context,
    String title,
    String message,
  ) async {}

  @override
  Future<void> showSnackBar(BuildContext context, String message) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CounterPage Arabic RTL at 360 logical pixels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const CounterSnapshot snapshot = CounterSnapshot(
      userId: 'tester',
      count: 2,
    );
    final CounterCubit cubit = CounterCubit(
      repository: const _ImmediateCounterRepository(snapshot),
      timerService: FakeTimerService(),
      startTicker: false,
    );
    addTearDown(cubit.close);
    await cubit.loadInitial();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResponsiveScope(
          child: BlocProvider<CounterCubit>.value(
            value: cubit,
            child: CounterPage(
              title: 'Counter',
              errorNotificationService: _FakeErrorNotificationService(),
              biometricAuthenticator: _FakeBiometricAuthenticator(),
              showFlavorBadge: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.byType(CounterPage))),
      TextDirection.rtl,
    );
    expect(find.byType(CounterPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CounterPage), const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
