import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Map<String, String> localizedLabels = <String, String>{
      'en': l10n.languageEnglish,
      'tr': l10n.languageTurkish,
      'de': l10n.languageGerman,
      'fr': l10n.languageFrench,
      'es': l10n.languageSpanish,
      'ar': l10n.languageArabic,
    };

    return SettingsSection(
      title: l10n.languageSectionTitle,
      child: TypeSafeBlocSelector<LocaleCubit, Locale?, Locale?>(
        selector: (state) => state,
        builder: (context, currentLocale) {
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
            isSelected: (locale) => _sameLocale(locale, currentLocale),
            onSelect: (locale) =>
                context.cubit<LocaleCubit>().setLocale(locale),
          );
        },
      ),
    );
  }

  bool _sameLocale(Locale? a, Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode && a.countryCode == b.countryCode;
  }
}
