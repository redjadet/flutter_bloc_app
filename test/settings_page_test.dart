import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/locale_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsPage', () {
    setUp(() async {
      await getIt.reset(dispose: true);
      getIt.registerSingleton<AppInfoRepository>(_InMemoryAppInfoRepository());
    });

    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    ThemeCubit createThemeCubit(ThemeRepository repository) {
      final ThemeCubit cubit = ThemeCubit(repository: repository);
      addTearDown(() => cubit.close());
      return cubit;
    }

    LocaleCubit createLocaleCubit(LocaleRepository repository) {
      final LocaleCubit cubit = LocaleCubit(repository: repository);
      addTearDown(() => cubit.close());
      return cubit;
    }

    testWidgets('changes theme mode and locale when selecting options', (
      WidgetTester tester,
    ) async {
      final _InMemoryThemeRepository repo = _InMemoryThemeRepository();
      final ThemeCubit themeCubit = createThemeCubit(repo);
      final _InMemoryLocaleRepository localeRepo = _InMemoryLocaleRepository();
      final LocaleCubit localeCubit = createLocaleCubit(localeRepo);

      final AppLocalizationsEn en = AppLocalizationsEn();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<LocaleCubit>.value(value: localeCubit),
            ],
            child: const SettingsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(themeCubit.state, ThemeMode.system);
      expect(localeCubit.state, isNull);

      await tester.tap(find.text(en.themeModeDark));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(themeCubit.state, ThemeMode.dark);
      expect(repo.saved, ThemePreference.dark);

      await tester.scrollUntilVisible(
        find.text(en.languageSpanish),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.languageSpanish));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(localeCubit.state?.languageCode, 'es');
      expect(localeRepo.saved?.languageCode, 'es');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('shows version and build number from repository', (
      WidgetTester tester,
    ) async {
      final _InMemoryThemeRepository themeRepo = _InMemoryThemeRepository();
      final ThemeCubit themeCubit = createThemeCubit(themeRepo);
      final _InMemoryLocaleRepository localeRepo = _InMemoryLocaleRepository();
      final LocaleCubit localeCubit = createLocaleCubit(localeRepo);
      final AppLocalizationsEn en = AppLocalizationsEn();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<LocaleCubit>.value(value: localeCubit),
            ],
            child: const SettingsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.scrollUntilVisible(
        find.text(en.appInfoVersionLabel),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text(en.appInfoVersionLabel), findsOneWidget);
      expect(find.text(en.appInfoBuildNumberLabel), findsOneWidget);
      expect(find.text('1.2.3'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('surfaces app info load errors and retries successfully', (
      WidgetTester tester,
    ) async {
      final _InMemoryThemeRepository themeRepo = _InMemoryThemeRepository();
      final ThemeCubit themeCubit = createThemeCubit(themeRepo);
      final _InMemoryLocaleRepository localeRepo = _InMemoryLocaleRepository();
      final LocaleCubit localeCubit = createLocaleCubit(localeRepo);
      final _FlakyAppInfoRepository appInfoRepo = _FlakyAppInfoRepository();

      getIt.unregister<AppInfoRepository>();
      getIt.registerSingleton<AppInfoRepository>(appInfoRepo);

      final AppLocalizationsEn en = AppLocalizationsEn();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>.value(value: themeCubit),
              BlocProvider<LocaleCubit>.value(value: localeCubit),
            ],
            child: const SettingsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.scrollUntilVisible(
        find.text(en.appInfoSectionTitle),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text(en.appInfoLoadErrorLabel), findsOneWidget);
      expect(find.text('Exception: Boom 1'), findsOneWidget);

      appInfoRepo.shouldFail = false;

      await tester.tap(find.text(en.appInfoRetryButtonLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(en.appInfoVersionLabel), findsOneWidget);
      expect(find.text('9.9.9'), findsOneWidget);
      expect(appInfoRepo.loadCount, 2);
    });
  });
}

class _InMemoryThemeRepository implements ThemeRepository {
  _InMemoryThemeRepository([ThemePreference? initial]) : _stored = initial;

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

class _InMemoryLocaleRepository implements LocaleRepository {
  _InMemoryLocaleRepository([AppLocale? initial]) : _stored = initial;

  AppLocale? _stored;
  AppLocale? saved;

  @override
  Future<AppLocale?> load() async => _stored;

  @override
  Future<void> save(AppLocale? locale) async {
    saved = locale;
    _stored = locale;
  }
}

class _InMemoryAppInfoRepository implements AppInfoRepository {
  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '1.2.3', buildNumber: '42');
}

class _FlakyAppInfoRepository implements AppInfoRepository {
  int loadCount = 0;
  bool shouldFail = true;

  @override
  Future<AppInfo> load() async {
    loadCount += 1;
    if (shouldFail) {
      throw Exception('Boom $loadCount');
    }
    return const AppInfo(version: '9.9.9', buildNumber: '77');
  }
}
