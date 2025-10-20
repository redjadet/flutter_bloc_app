import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final List<SettingsOption<ThemeMode>> options = <SettingsOption<ThemeMode>>[
      SettingsOption(label: l10n.themeModeSystem, value: ThemeMode.system),
      SettingsOption(label: l10n.themeModeLight, value: ThemeMode.light),
      SettingsOption(label: l10n.themeModeDark, value: ThemeMode.dark),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.themeSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapS),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (final context, final currentMode) =>
              SettingsCard<ThemeMode>(
                options: options,
                isSelected: (final mode) => mode == currentMode,
                onSelect: (final mode) =>
                    context.read<ThemeCubit>().setMode(mode),
              ),
        ),
      ],
    );
  }
}
