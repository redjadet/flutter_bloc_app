import 'dart:async';

import 'package:design_system/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/config/app_constants.dart';
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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../helpers/memory/leak_safe_test_widgets.dart';
import '../../../../test_helpers.dart' show FakeTimerService;

class _DelayedCounterRepository
    with CounterRepositoryNoPendingSync
    implements CounterRepository {
  _DelayedCounterRepository({required this.completer, required this.snapshot});

  final Completer<CounterSnapshot> completer;
  final CounterSnapshot snapshot;

  @override
  Future<CounterSnapshot> load() => completer.future;

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
  leakSafeTestWidgets(
    'CounterPage toggles skeletons with loading state',
    (tester) async {
      await tester.binding.setSurfaceSize(AppConstants.designSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final Completer<CounterSnapshot> completer = Completer<CounterSnapshot>();
      final CounterSnapshot snapshot = const CounterSnapshot(
        userId: 'tester',
        count: 3,
      );
      final CounterRepository repository = _DelayedCounterRepository(
        completer: completer,
        snapshot: snapshot,
      );
      final CounterCubit cubit = CounterCubit(
        repository: repository,
        timerService: FakeTimerService(),
        startTicker: false,
      );
      addTearDown(cubit.close);

      unawaited(cubit.loadInitial());

      await tester.pumpWidget(
        MaterialApp(
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
      await tester.pump();

      final Iterable<Skeletonizer> loadingSkeletons = tester
          .widgetList(
            find.byWidgetPredicate((widget) => widget is Skeletonizer),
          )
          .cast<Skeletonizer>();
      expect(loadingSkeletons.isNotEmpty, isTrue);
      expect(loadingSkeletons.every((skeleton) => skeleton.enabled), isTrue);

      completer.complete(snapshot);
      await tester.pump();
      await tester.pump();

      final Iterable<Skeletonizer> loadedSkeletons = tester
          .widgetList(
            find.byWidgetPredicate((widget) => widget is Skeletonizer),
          )
          .cast<Skeletonizer>();
      expect(loadedSkeletons.isNotEmpty, isTrue);
      expect(loadedSkeletons.every((skeleton) => !skeleton.enabled), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
    ignoredNotDisposedClasses: <String>[
      ...memoryLeakHarnessLayerClasses,
      // package:confetti internals survive controller disposal in widget tests.
      'ParticleSystem',
    ],
  );
}
