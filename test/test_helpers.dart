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
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
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
}) {
  return ScreenUtilInit(
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
}

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
      final callbacks = _entries
          .where((e) => !e.cancelled)
          .map((e) => e.onTick)
          .toList();
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
