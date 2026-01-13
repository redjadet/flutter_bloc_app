import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class SettingsOption<T> {
  const SettingsOption({required this.label, required this.value});

  final String label;
  final T value;
}

class SettingsCard<T> extends StatelessWidget {
  const SettingsCard({
    required this.options,
    required this.isSelected,
    required this.onSelect,
    super.key,
  });

  final List<SettingsOption<T>> options;
  final bool Function(T value) isSelected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(final BuildContext context) => Card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
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
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return PlatformAdaptive.listTile(
      context: context,
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
