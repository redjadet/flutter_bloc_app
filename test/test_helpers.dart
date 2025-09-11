import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/data/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test helper for creating mock repositories
class MockCounterRepository implements CounterRepository {
  final CounterSnapshot _snapshot;
  final bool _shouldThrowOnLoad;
  final bool _shouldThrowOnSave;

  MockCounterRepository({
    CounterSnapshot? snapshot,
    bool shouldThrowOnLoad = false,
    bool shouldThrowOnSave = false,
  }) : _snapshot = snapshot ?? const CounterSnapshot(count: 0),
       _shouldThrowOnLoad = shouldThrowOnLoad,
       _shouldThrowOnSave = shouldThrowOnSave;

  @override
  Future<CounterSnapshot> load() async {
    if (_shouldThrowOnLoad) {
      throw Exception('Mock load error');
    }
    return _snapshot;
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    if (_shouldThrowOnSave) {
      throw Exception('Mock save error');
    }
    // Mock save - do nothing
  }
}

/// Test helper for wrapping widgets with necessary providers
Widget wrapWithProviders({
  required Widget child,
  CounterRepository? repository,
  ThemeMode initialThemeMode = ThemeMode.system,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CounterCubit(repository: repository)..loadInitial(),
        ),
        BlocProvider(create: (_) => ThemeCubit()..emit(initialThemeMode)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
}

/// Test helper for setting up SharedPreferences mock
void setupSharedPreferencesMock({Map<String, Object>? initialValues}) {
  SharedPreferences.setMockInitialValues(initialValues ?? <String, Object>{});
}
