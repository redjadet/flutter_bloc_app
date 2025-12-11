import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Preset width configuration for whiteboard strokes.
class WidthPreset {
  const WidthPreset({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final double value;
  final IconData icon;
}

/// Default width presets for the whiteboard toolbar.
const List<WidthPreset> defaultWidthPresets = <WidthPreset>[
  WidthPreset(label: 'Thin', value: 2, icon: Icons.remove),
  WidthPreset(label: 'Medium', value: 5, icon: Icons.horizontal_rule),
  WidthPreset(label: 'Thick', value: 10, icon: Icons.drag_handle),
  WidthPreset(label: 'Extra', value: 15, icon: Icons.format_bold),
];

/// A button widget for selecting a preset stroke width.
class WidthPresetButton extends StatelessWidget {
  const WidthPresetButton({
    required this.preset,
    required this.isSelected,
    required this.currentColor,
    required this.colors,
    required this.theme,
    required this.onTap,
    super.key,
  });

  final WidthPreset preset;
  final bool isSelected;
  final Color currentColor;
  final ColorScheme colors;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Tooltip(
    message: '${preset.label} (${preset.value.toStringAsFixed(0)}px)',
    child: Material(
      color: isSelected
          ? colors.primaryContainer
          : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                preset.icon,
                size: 16,
                color: isSelected
                    ? colors.onPrimaryContainer
                    : colors.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                preset.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colors.onPrimaryContainer
                      : colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// An action button for the whiteboard toolbar (Undo, Redo, Clear).
class WhiteboardActionButton extends StatelessWidget {
  const WhiteboardActionButton({
    required this.label,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(final BuildContext context) => Tooltip(
    message: tooltip,
    child: PlatformAdaptive.textButton(
      context: context,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18),
          SizedBox(width: context.responsiveHorizontalGapS),
          Text(label),
        ],
      ),
    ),
  );
}
