import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_card.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

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
      child: TypeSafeBlocSelector<ThemeCubit, ThemeMode, ThemeMode>(
        selector: (final state) => state,
        builder: (final context, final currentMode) => SettingsCard<ThemeMode>(
          options: options,
          isSelected: (final mode) => mode == currentMode,
          onSelect: (final mode) => context.cubit<ThemeCubit>().setMode(mode),
        ),
      ),
    );
  }
}
