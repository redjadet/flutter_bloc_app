import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/icon_label_row.dart';

/// Stroke width presets (logical pixels) for whiteboard toolbar.
const double kStrokeWidthThin = 2;
const double kStrokeWidthMedium = 5;
const double kStrokeWidthThick = 10;
const double kStrokeWidthExtra = 15;

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

/// Returns width presets with localized labels for the whiteboard toolbar.
List<WidthPreset> defaultWidthPresetsFor(final AppLocalizations l10n) =>
    <WidthPreset>[
      WidthPreset(
        label: l10n.whiteboardStrokeWidthThin,
        value: kStrokeWidthThin,
        icon: Icons.remove,
      ),
      WidthPreset(
        label: l10n.whiteboardStrokeWidthMedium,
        value: kStrokeWidthMedium,
        icon: Icons.horizontal_rule,
      ),
      WidthPreset(
        label: l10n.whiteboardStrokeWidthThick,
        value: kStrokeWidthThick,
        icon: Icons.drag_handle,
      ),
      WidthPreset(
        label: l10n.whiteboardStrokeWidthExtra,
        value: kStrokeWidthExtra,
        icon: Icons.format_bold,
      ),
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
    message: preset.label,
    child: Material(
      color: isSelected
          ? colors.primaryContainer
          : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(UI.radiusS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UI.radiusS),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: UI.horizontalGapM,
            vertical: UI.gapS,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UI.radiusS),
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
                size: UI.iconS,
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
      child: IconLabelRow(icon: icon, label: label, iconSize: UI.iconS),
    ),
  );
}
