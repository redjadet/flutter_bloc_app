import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
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
      expect(repo.saved, ThemeMode.dark);

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
  });
}

class _InMemoryThemeRepository implements ThemeRepository {
  ThemeMode? saved;

  @override
  Future<ThemeMode?> load() async => null;

  @override
  Future<void> save(ThemeMode mode) async {
    saved = mode;
  }
}

class _InMemoryLocaleRepository implements LocaleRepository {
  Locale? saved;

  @override
  Future<Locale?> load() async => saved;

  @override
  Future<void> save(Locale? locale) async {
    saved = locale;
  }
}

class _InMemoryAppInfoRepository implements AppInfoRepository {
  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '1.2.3', buildNumber: '42');
}
