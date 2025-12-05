@Skip(
  'Excluded from default flutter test run; intentionally throws to show SnackBar path',
)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class ThrowingRepo implements CounterRepository {
  @override
  Future<CounterSnapshot> load() async {
    throw Exception('load failed');
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    throw Exception('save failed');
  }

  @override
  Stream<CounterSnapshot> watch() =>
      Stream<CounterSnapshot>.error(Exception('watch failed'));
}

void main() {
  testWidgets('shows SnackBar on load error and clears error', (tester) async {
    await initializeDateFormatting('en');
    final CounterCubit cubit = CounterCubit(
      repository: ThrowingRepo(),
      startTicker: false,
    );
    addTearDown(() => cubit.close());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(
              create: (_) => ThemeCubit(
                repository: _FakeThemeRepository(ThemeMode.system),
              ),
            ),
          ],
          child: MaterialApp(
            home: CounterPage(
              title: 'Test Home',
              errorNotificationService: _FakeErrorNotificationService(),
              biometricAuthenticator: _FakeBiometricAuthenticator(),
            ),
          ),
        ),
      ),
    );

    // Trigger load error
    await cubit.loadInitial();

    // Let the BlocListener react and display SnackBar
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository(this.initial);

  final ThemeMode initial;

  @override
  Future<ThemePreference?> load() async => _toPreference(initial);

  @override
  Future<void> save(ThemePreference mode) async {}
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

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  @override
  Future<bool> authenticate({String? localizedReason}) async => true;
}

ThemePreference _toPreference(final ThemeMode mode) => switch (mode) {
  ThemeMode.light => ThemePreference.light,
  ThemeMode.dark => ThemePreference.dark,
  ThemeMode.system => ThemePreference.system,
};
