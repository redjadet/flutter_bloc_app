import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/domain/theme_repository.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsPage', () {
    testWidgets('changes theme mode when selecting an option', (
      WidgetTester tester,
    ) async {
      final _InMemoryThemeRepository repo = _InMemoryThemeRepository();
      final ThemeCubit cubit = ThemeCubit(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<ThemeCubit>.value(
            value: cubit,
            child: const SettingsPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(cubit.state, ThemeMode.system);

      await tester.tap(find.text('Dark'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(cubit.state, ThemeMode.dark);
      expect(repo.saved, ThemeMode.dark);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await cubit.close();
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
