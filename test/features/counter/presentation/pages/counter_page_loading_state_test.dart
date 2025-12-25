import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/constants.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive_scope.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../test_helpers.dart' show FakeTimerService;

class _DelayedCounterRepository implements CounterRepository {
  _DelayedCounterRepository({required this.completer, required this.snapshot});

  final Completer<CounterSnapshot> completer;
  final CounterSnapshot snapshot;

  @override
  Future<CounterSnapshot> load() => completer.future;

  @override
  Future<void> save(final CounterSnapshot snapshot) async {}

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
  testWidgets('CounterPage toggles skeletons with loading state', (
    tester,
  ) async {
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
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResponsiveScope(
          child: BlocProvider<CounterCubit>.value(
            value: cubit,
            child: CounterPage(
              title: 'Counter',
              errorNotificationService: _FakeErrorNotificationService(),
              biometricAuthenticator: _FakeBiometricAuthenticator(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Iterable<Skeletonizer> loadingSkeletons = tester
        .widgetList(find.byWidgetPredicate((widget) => widget is Skeletonizer))
        .cast<Skeletonizer>();
    expect(loadingSkeletons.isNotEmpty, isTrue);
    expect(
      loadingSkeletons.every((final skeleton) => skeleton.enabled),
      isTrue,
    );

    completer.complete(snapshot);
    await tester.pump();
    await tester.pump();

    final Iterable<Skeletonizer> loadedSkeletons = tester
        .widgetList(find.byWidgetPredicate((widget) => widget is Skeletonizer))
        .cast<Skeletonizer>();
    expect(loadedSkeletons.isNotEmpty, isTrue);
    expect(
      loadedSkeletons.every((final skeleton) => !skeleton.enabled),
      isTrue,
    );
  });
}
