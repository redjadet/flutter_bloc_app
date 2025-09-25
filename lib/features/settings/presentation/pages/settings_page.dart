import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/presentation/locale_cubit.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settingsPageTitle),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: UI.horizontalGapL,
          vertical: UI.gapM,
        ),
        children: <Widget>[
          const _AccountSection(),
          SizedBox(height: UI.gapL),
          const _ThemeSection(),
          SizedBox(height: UI.gapL),
          const _LanguageSection(),
          SizedBox(height: UI.gapL),
          TextButton(
            onPressed: () => throw Exception(),
            child: const Text('Throw Test Exception'),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool firebaseReady = Firebase.apps.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.accountSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapS),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UI.cardPadH,
              vertical: UI.cardPadV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!firebaseReady)
                  Text(l10n.accountSignedOutLabel)
                else
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      final User? user = snapshot.data;
                      if (user == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(l10n.accountSignedOutLabel),
                            SizedBox(height: UI.gapM),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => context.go(AppRoutes.authPath),
                                child: Text(l10n.accountSignInButton),
                              ),
                            ),
                          ],
                        );
                      }

                      final bool isGuest = user.isAnonymous;
                      final String? trimmedName = user.displayName?.trim();
                      String displayName = user.email ?? user.uid;
                      if (trimmedName != null && trimmedName.isNotEmpty) {
                        displayName = trimmedName;
                      }

                      final String? email = user.email?.trim();

                      if (isGuest) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.accountGuestLabel,
                              style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: UI.gapS),
                            Text(
                              l10n.accountGuestDescription,
                              style: theme.textTheme.bodySmall,
                            ),
                            SizedBox(height: UI.gapM),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => context.go(AppRoutes.authPath),
                                child: Text(l10n.accountUpgradeButton),
                              ),
                            ),
                            SizedBox(height: UI.gapS),
                            const SizedBox(
                              width: double.infinity,
                              child: SignOutButton(
                                variant: ButtonVariant.outlined,
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.accountSignedInAs(displayName),
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (email != null && email.isNotEmpty) ...<Widget>[
                            SizedBox(height: UI.gapS),
                            Text(email, style: theme.textTheme.bodySmall),
                          ],
                          SizedBox(height: UI.gapM),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () =>
                                  context.push(AppRoutes.profilePath),
                              child: Text(l10n.accountManageButton),
                            ),
                          ),
                          SizedBox(height: UI.gapS),
                          const SizedBox(
                            width: double.infinity,
                            child: SignOutButton(
                              variant: ButtonVariant.outlined,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
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
                  label:
                      localizedLabels[locale.languageCode] ??
                      locale.languageCode,
                  value: locale,
                ),
            ];

            return _SettingsCard<Locale?>(
              options: options,
              isSelected: (locale) => _sameLocale(locale, currentLocale),
              onSelect: (locale) =>
                  context.read<LocaleCubit>().setLocale(locale),
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
  const _SettingsCard({
    required this.options,
    required this.isSelected,
    required this.onSelect,
  });

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
  const _SettingsTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
      selectedTileColor: theme.colorScheme.surfaceContainerHighest,
      selected: selected,
    );
  }
}
