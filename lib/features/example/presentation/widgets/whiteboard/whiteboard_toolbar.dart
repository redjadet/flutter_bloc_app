import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_toolbar_helpers.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Toolbar for the whiteboard with color picker, width presets, and labeled actions.
class WhiteboardToolbar extends StatelessWidget {
  const WhiteboardToolbar({
    required this.theme,
    required this.colors,
    required this.currentColor,
    required this.currentWidth,
    required this.canUndo,
    required this.canRedo,
    required this.canClear,
    required this.onPickColor,
    required this.onWidthChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    super.key,
  });

  final ThemeData theme;
  final ColorScheme colors;
  final Color currentColor;
  final double currentWidth;
  final bool canUndo;
  final bool canRedo;
  final bool canClear;
  final VoidCallback onPickColor;
  final ValueChanged<double> onWidthChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;

  @override
  Widget build(final BuildContext context) => Container(
    padding: EdgeInsets.all(context.responsiveGapS),
    decoration: BoxDecoration(
      color: colors.surfaceContainerHighest,
      border: Border(
        bottom: BorderSide(
          color: colors.outline.withValues(alpha: 0.2),
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // First row: Color and width controls
        Wrap(
          spacing: context.responsiveHorizontalGapM,
          runSpacing: context.responsiveGapS,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _buildColorButton(context),
            _buildWidthControls(context),
          ],
        ),
        SizedBox(height: context.responsiveGapS),
        // Second row: Action buttons
        Wrap(
          spacing: context.responsiveHorizontalGapS,
          runSpacing: context.responsiveGapXS,
          children: <Widget>[
            WhiteboardActionButton(
              label: 'Undo',
              icon: Icons.undo,
              tooltip: 'Undo last stroke',
              onPressed: canUndo ? onUndo : null,
            ),
            WhiteboardActionButton(
              label: 'Redo',
              icon: Icons.redo,
              tooltip: 'Redo last undone stroke',
              onPressed: canRedo ? onRedo : null,
            ),
            WhiteboardActionButton(
              label: 'Clear',
              icon: Icons.clear_all,
              tooltip: 'Clear all strokes',
              onPressed: canClear ? onClear : null,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildColorButton(final BuildContext context) => Tooltip(
    message: 'Choose pen color',
    child: PlatformAdaptive.filledButton(
      key: const ValueKey('whiteboard-color-button'),
      context: context,
      onPressed: onPickColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
          SizedBox(width: context.responsiveHorizontalGapS),
          const Icon(Icons.palette_outlined, size: 18),
          SizedBox(width: context.responsiveHorizontalGapS),
          const Text('Pen color'),
        ],
      ),
    ),
  );

  Widget _buildWidthControls(final BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 400),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Stroke width',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: context.responsiveHorizontalGapS),
            // Visual preview of stroke width
            Container(
              width: 40,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Container(
                width: currentWidth.clamp(2, 20),
                height: currentWidth.clamp(2, 20),
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${currentWidth.toStringAsFixed(0)}px',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveGapXS),
        // Preset buttons
        Wrap(
          spacing: context.responsiveHorizontalGapS,
          runSpacing: context.responsiveGapXS,
          children: defaultWidthPresets
              .map<Widget>(
                (final WidthPreset preset) => WidthPresetButton(
                  preset: preset,
                  isSelected: (currentWidth - preset.value).abs() < 0.5,
                  currentColor: currentColor,
                  colors: colors,
                  theme: theme,
                  onTap: () => onWidthChanged(preset.value),
                ),
              )
              .toList(),
        ),
        SizedBox(height: context.responsiveGapXS),
        // Slider for fine control
        Slider.adaptive(
          value: currentWidth,
          min: 1,
          max: 20,
          divisions: 19,
          label: '${currentWidth.toStringAsFixed(0)}px',
          onChanged: onWidthChanged,
        ),
      ],
    ),
  );
}
