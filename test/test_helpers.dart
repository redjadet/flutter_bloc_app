import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';

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
          create: (ctx) =>
              CounterCubit(repository: repository ?? MockCounterRepository())..loadInitial(),
        ),
        BlocProvider(
          create: (_) =>
              ThemeCubit(repository: _FakeThemeRepository(initialThemeMode))
                ..emit(initialThemeMode),
        ),
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

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository(this.initial);
  final ThemeMode initial;
  ThemeMode? saved;
  @override
  Future<ThemeMode?> load() async => initial;
  @override
  Future<void> save(ThemeMode mode) async {
    saved = mode;
  }
}

/// Simple fake timer service to drive periodic ticks deterministically in tests.
class FakeTimerService implements TimerService {
  final List<_Entry> _entries = [];

  @override
  TimerDisposable periodic(Duration interval, void Function() onTick) {
    final entry = _Entry(interval, onTick);
    _entries.add(entry);
    return _FakeTimerHandle(() {
      entry.cancelled = true;
      _entries.remove(entry);
    });
  }

  /// Triggers all active periodic callbacks [times] times.
  void tick([int times = 1]) {
    for (int i = 0; i < times; i++) {
      final callbacks =
          _entries.where((e) => !e.cancelled).map((e) => e.onTick).toList();
      for (final cb in callbacks) {
        cb();
      }
    }
  }
}

class _Entry {
  _Entry(this.interval, this.onTick);
  final Duration interval;
  final void Function() onTick;
  bool cancelled = false;
}

class _FakeTimerHandle implements TimerDisposable {
  _FakeTimerHandle(this._onDispose);
  final void Function() _onDispose;
  @override
  void dispose() => _onDispose();
}
