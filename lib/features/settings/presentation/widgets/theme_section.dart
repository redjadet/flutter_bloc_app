import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          builder: (context, currentMode) {
            return SettingsCard<ThemeMode>(
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
