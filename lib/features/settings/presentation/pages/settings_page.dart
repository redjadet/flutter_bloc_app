import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/presentation/locale_cubit.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settingsPageTitle)),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: UI.hgapL, vertical: UI.gapM),
        children: <Widget>[
          const _ThemeSection(),
          SizedBox(height: UI.gapL),
          const _LanguageSection(),
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final List<_Option<ThemeMode>> options = <_Option<ThemeMode>>[
      _Option(label: l10n.themeModeSystem, value: ThemeMode.system),
      _Option(label: l10n.themeModeLight, value: ThemeMode.light),
      _Option(label: l10n.themeModeDark, value: ThemeMode.dark),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.themeSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapS),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, currentMode) {
            return _SettingsCard(
              options: options,
              isSelected: (mode) => mode == currentMode,
              onSelect: (mode) => context.read<ThemeCubit>().setMode(mode),
            );
          },
        ),
      ],
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Map<String, String> localizedLabels = <String, String>{
      'en': l10n.languageEnglish,
      'tr': l10n.languageTurkish,
      'de': l10n.languageGerman,
      'fr': l10n.languageFrench,
      'es': l10n.languageSpanish,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.languageSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapS),
        BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, currentLocale) {
            final List<_Option<Locale?>> options = <_Option<Locale?>>[
              _Option(label: l10n.languageSystemDefault, value: null),
              for (final Locale locale in AppLocalizations.supportedLocales)
                _Option(
                  label: localizedLabels[locale.languageCode] ?? locale.languageCode,
                  value: locale,
                ),
            ];

            return _SettingsCard<Locale?>(
              options: options,
              isSelected: (locale) => _sameLocale(locale, currentLocale),
              onSelect: (locale) => context.read<LocaleCubit>().setLocale(locale),
            );
          },
        ),
      ],
    );
  }

  bool _sameLocale(Locale? a, Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}

class _SettingsCard<T> extends StatelessWidget {
  const _SettingsCard({required this.options, required this.isSelected, required this.onSelect});

  final List<_Option<T>> options;
  final bool Function(T value) isSelected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const Divider(height: 0),
            _SettingsTile(
              label: options[i].label,
              selected: isSelected(options[i].value),
              onTap: () => onSelect(options[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _Option<T> {
  const _Option({required this.label, required this.value});

  final String label;
  final T value;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      title: Text(label),
      trailing: selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: onTap,
      selectedTileColor: theme.colorScheme.surfaceContainerHighest,
      selected: selected,
    );
  }
}
