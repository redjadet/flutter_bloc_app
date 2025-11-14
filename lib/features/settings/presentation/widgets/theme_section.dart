import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_card.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final List<SettingsOption<ThemeMode>> options = <SettingsOption<ThemeMode>>[
      SettingsOption(label: l10n.themeModeSystem, value: ThemeMode.system),
      SettingsOption(label: l10n.themeModeLight, value: ThemeMode.light),
      SettingsOption(label: l10n.themeModeDark, value: ThemeMode.dark),
    ];

    return SettingsSection(
      title: l10n.themeSectionTitle,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (final context, final currentMode) => SettingsCard<ThemeMode>(
          options: options,
          isSelected: (final mode) => mode == currentMode,
          onSelect: (final mode) => context.read<ThemeCubit>().setMode(mode),
        ),
      ),
    );
  }
}
