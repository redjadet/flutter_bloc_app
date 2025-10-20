import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/locale_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(final BuildContext context) {
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
          builder: (final context, final currentLocale) {
            final List<SettingsOption<Locale?>> options =
                <SettingsOption<Locale?>>[
                  SettingsOption(
                    label: l10n.languageSystemDefault,
                    value: null,
                  ),
                  for (final Locale locale in AppLocalizations.supportedLocales)
                    SettingsOption(
                      label:
                          localizedLabels[locale.languageCode] ??
                          locale.languageCode,
                      value: locale,
                    ),
                ];

            return SettingsCard<Locale?>(
              options: options,
              isSelected: (final locale) => _sameLocale(locale, currentLocale),
              onSelect: (final locale) =>
                  context.read<LocaleCubit>().setLocale(locale),
            );
          },
        ),
      ],
    );
  }

  bool _sameLocale(final Locale? a, final Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}
