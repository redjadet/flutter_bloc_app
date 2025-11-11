import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Test helper for creating mock repositories
class MockCounterRepository implements CounterRepository {
  CounterSnapshot _snapshot;
  final bool _shouldThrowOnLoad;
  final bool _shouldThrowOnSave;
  StreamController<CounterSnapshot>? _watchController;

  MockCounterRepository({
    CounterSnapshot? snapshot,
    bool shouldThrowOnLoad = false,
    bool shouldThrowOnSave = false,
  }) : _snapshot = snapshot ?? const CounterSnapshot(userId: 'mock', count: 0),
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
    _snapshot = snapshot;
    _watchController?.add(_snapshot);
  }

  @override
  Stream<CounterSnapshot> watch() {
    _watchController ??= StreamController<CounterSnapshot>.broadcast(
      onListen: () {
        _watchController?.add(_snapshot);
      },
    );
    return _watchController!.stream;
  }
}

/// Test helper for wrapping widgets with necessary providers
Widget wrapWithProviders({
  required Widget child,
  CounterRepository? repository,
  ThemeMode initialThemeMode = ThemeMode.system,
}) => ScreenUtilInit(
  designSize: const Size(390, 844),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, _) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (ctx) =>
            CounterCubit(repository: repository ?? MockCounterRepository())
              ..loadInitial(),
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

/// Test helper for setting up SharedPreferences mock
void setupSharedPreferencesMock({Map<String, Object>? initialValues}) {
  SharedPreferences.setMockInitialValues(initialValues ?? <String, Object>{});
}

/// Overrides the shared Hugging Face HTTP client so tests can inject mocks.
///
/// This mutates the root GetIt scope and should be paired with manual cleanup
/// (e.g. rerunning `configureDependencies`). Prefer using
/// [runWithHuggingFaceHttpClientOverride] to keep overrides scoped.
@Deprecated('Prefer runWithHuggingFaceHttpClientOverride for scoped overrides.')
void overrideHuggingFaceHttpClient(
  http.Client client, {
  required String apiKey,
  required String model,
  required bool useChatCompletions,
}) {
  if (getIt.isRegistered<ChatRepository>()) {
    getIt.unregister<ChatRepository>();
  }
  if (getIt.isRegistered<HuggingFaceApiClient>()) {
    getIt.unregister<HuggingFaceApiClient>();
  }
  if (getIt.isRegistered<http.Client>()) {
    getIt.unregister<http.Client>();
  }

  _registerHuggingFaceDependencies(
    client,
    apiKey: apiKey,
    model: model,
    useChatCompletions: useChatCompletions,
  );
}

/// Runs [action] within a GetIt scope that overrides Hugging Face dependencies.
/// The provided [client] is automatically disposed if [closeClient] is true.
Future<T> runWithHuggingFaceHttpClientOverride<T>({
  required http.Client client,
  required String apiKey,
  required String model,
  required bool useChatCompletions,
  bool closeClient = true,
  required Future<T> Function() action,
}) async {
  getIt.pushNewScope(scopeName: 'huggingface-test-override');
  _registerHuggingFaceDependencies(
    client,
    apiKey: apiKey,
    model: model,
    useChatCompletions: useChatCompletions,
  );
  try {
    return await action();
  } finally {
    if (closeClient) {
      client.close();
    }
    await getIt.popScope();
  }
}

void _registerHuggingFaceDependencies(
  http.Client client, {
  required String apiKey,
  required String model,
  required bool useChatCompletions,
}) {
  getIt.registerSingleton<http.Client>(client);
  getIt.registerLazySingleton<HuggingFaceApiClient>(
    () =>
        HuggingFaceApiClient(httpClient: getIt<http.Client>(), apiKey: apiKey),
  );
  getIt.registerLazySingleton<HuggingFacePayloadBuilder>(
    () => const HuggingFacePayloadBuilder(),
  );
  getIt.registerLazySingleton<HuggingFaceResponseParser>(
    () => const HuggingFaceResponseParser(
      fallbackMessage: HuggingfaceChatRepository.fallbackMessage,
    ),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => HuggingfaceChatRepository(
      apiClient: getIt<HuggingFaceApiClient>(),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      model: model,
      useChatCompletions: useChatCompletions,
    ),
  );
}

class _FakeThemeRepository implements ThemeRepository {
  _FakeThemeRepository(this.initial) : _stored = _toPreference(initial);

  final ThemeMode initial;
  ThemePreference? _stored;

  ThemePreference? saved;

  @override
  Future<ThemePreference?> load() async => _stored;

  @override
  Future<void> save(ThemePreference mode) async {
    saved = mode;
    _stored = mode;
  }
}

ThemePreference _toPreference(final ThemeMode mode) => switch (mode) {
  ThemeMode.light => ThemePreference.light,
  ThemeMode.dark => ThemePreference.dark,
  ThemeMode.system => ThemePreference.system,
};

/// Simple fake timer service to drive periodic ticks deterministically in tests.
class FakeTimerService implements TimerService {
  final List<_PeriodicEntry> _periodicEntries = [];
  final List<_OneShotEntry> _oneShotEntries = [];

  @override
  TimerDisposable periodic(Duration interval, void Function() onTick) {
    final entry = _PeriodicEntry(interval, onTick);
    _periodicEntries.add(entry);
    return _FakeTimerHandle(() {
      if (entry.cancelled) {
        return;
      }
      entry.cancelled = true;
      _periodicEntries.remove(entry);
    });
  }

  @override
  TimerDisposable runOnce(Duration delay, void Function() onComplete) {
    final entry = _OneShotEntry(delay, onComplete);
    _oneShotEntries.add(entry);
    return _FakeTimerHandle(() {
      if (entry.cancelled) {
        return;
      }
      entry.cancelled = true;
      _oneShotEntries.remove(entry);
    });
  }

  /// Triggers all active periodic callbacks [times] times.
  void tick([int times = 1]) {
    for (int i = 0; i < times; i++) {
      final callbacks = _periodicEntries
          .where((e) => !e.cancelled)
          .map((e) => e.onTick)
          .toList();
      for (final cb in callbacks) {
        cb();
      }
    }
  }

  /// Advances fake time by [duration], triggering due timers.
  void elapse(Duration duration) {
    final int delta = duration.inMicroseconds;
    if (delta <= 0) {
      return;
    }

    for (final entry in List<_PeriodicEntry>.from(_periodicEntries)) {
      if (entry.cancelled) {
        continue;
      }
      entry.addElapsed(delta);
    }

    final pending = <_OneShotEntry>[];
    for (final entry in List<_OneShotEntry>.from(_oneShotEntries)) {
      if (entry.cancelled) {
        continue;
      }
      entry.remainingMicros -= delta;
      if (entry.remainingMicros <= 0) {
        entry.cancelled = true;
        pending.add(entry);
        _oneShotEntries.remove(entry);
      }
    }

    for (final entry in pending) {
      entry.onComplete();
    }
  }
}

class _PeriodicEntry {
  _PeriodicEntry(this.interval, this.onTick);
  final Duration interval;
  final void Function() onTick;
  bool cancelled = false;
  int _elapsedMicros = 0;

  void addElapsed(int deltaMicros) {
    if (interval.inMicroseconds <= 0) {
      return;
    }
    _elapsedMicros += deltaMicros;
    final int intervalMicros = interval.inMicroseconds;
    final int tickCount = _elapsedMicros ~/ intervalMicros;
    if (tickCount == 0) {
      return;
    }
    _elapsedMicros -= tickCount * intervalMicros;
    for (int i = 0; i < tickCount; i++) {
      onTick();
    }
  }
}

class _OneShotEntry {
  _OneShotEntry(Duration delay, this.onComplete)
    : remainingMicros = delay.inMicroseconds;
  final void Function() onComplete;
  int remainingMicros;
  bool cancelled = false;
}

class _FakeTimerHandle implements TimerDisposable {
  _FakeTimerHandle(this._onDispose);
  final void Function() _onDispose;
  @override
  void dispose() => _onDispose();
}
