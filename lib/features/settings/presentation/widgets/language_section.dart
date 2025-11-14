import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/locale_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_card.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final Map<String, String> localizedLabels = <String, String>{
      'en': l10n.languageEnglish,
      'tr': l10n.languageTurkish,
      'de': l10n.languageGerman,
      'fr': l10n.languageFrench,
      'es': l10n.languageSpanish,
    };

    return SettingsSection(
      title: l10n.languageSectionTitle,
      child: BlocSelector<LocaleCubit, Locale?, Locale?>(
        selector: (final state) => state,
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
    );
  }

  bool _sameLocale(final Locale? a, final Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}
