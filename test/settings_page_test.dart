import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/domain/locale_repository.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/presentation/locale_cubit.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsPage', () {
    testWidgets('changes theme mode and locale when selecting options', (
      WidgetTester tester,
    ) async {
      final _InMemoryThemeRepository repo = _InMemoryThemeRepository();
      final ThemeCubit themeCubit = ThemeCubit(repository: repo);
      final _InMemoryLocaleRepository localeRepo = _InMemoryLocaleRepository();
      final LocaleCubit localeCubit = LocaleCubit(repository: localeRepo);

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

      await tester.tap(find.text(en.languageSpanish));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(localeCubit.state?.languageCode, 'es');
      expect(localeRepo.saved?.languageCode, 'es');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await themeCubit.close();
      await localeCubit.close();
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
