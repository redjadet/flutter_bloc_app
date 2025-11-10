@Skip(
  'Excluded from default flutter test run; intentionally throws to show SnackBar path',
)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
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
          child: const MaterialApp(home: CounterPage(title: 'Test Home')),
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
  Future<ThemeMode?> load() async => initial;
  @override
  Future<void> save(ThemeMode mode) async {}
}
