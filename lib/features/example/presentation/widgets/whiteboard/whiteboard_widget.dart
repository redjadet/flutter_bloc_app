import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_painter.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_toolbar.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

/// An interactive whiteboard widget using CustomPainter for low-level rendering.
///
/// Features:
/// - Touch/pointer drawing with smooth strokes
/// - Multiple colors and stroke widths
/// - Clear and undo functionality
/// - Responsive design
class WhiteboardWidget extends StatefulWidget {
  const WhiteboardWidget({super.key});

  @override
  State<WhiteboardWidget> createState() => _WhiteboardWidgetState();
}

class _WhiteboardWidgetState extends State<WhiteboardWidget> {
  final List<WhiteboardStroke> _strokes = <WhiteboardStroke>[];
  final List<WhiteboardStroke> _undoStack = <WhiteboardStroke>[];
  Color? _currentColor;
  double _currentWidth = 3;
  WhiteboardStroke? _currentStroke;
  int _version = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentColor ??= Theme.of(context).colorScheme.onSurface;
  }

  Color get _effectiveColor =>
      _currentColor ?? Theme.of(context).colorScheme.onSurface;

  Future<void> _pickColor() async {
    final BuildContext pickerContext = context;
    final String chooseTitle = pickerContext.l10n.whiteboardChoosePenColor;
    final String pickHeading = pickerContext.l10n.whiteboardPickColor;
    final Color color = await showColorPickerDialog(
      context,
      _effectiveColor,
      title: Text(chooseTitle),
      heading: Text(pickHeading),
      subheading: const Text(''),
      wheelDiameter: 180,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.wheel: true,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
      },
    );
    if (!mounted) return;
    setState(() {
      _currentColor = color;
    });
  }

  void _startStroke(final Offset position) {
    setState(() {
      _currentStroke = WhiteboardStroke(
        points: <Offset>[position],
        color: _effectiveColor,
        width: _currentWidth,
      );
    });
  }

  void _updateStroke(final Offset position) {
    final WhiteboardStroke? stroke = _currentStroke;
    if (stroke == null) return;
    setState(() {
      _currentStroke = stroke.copyWith(
        points: <Offset>[...stroke.points, position],
      );
    });
  }

  void _endStroke() {
    final WhiteboardStroke? stroke = _currentStroke;
    if (stroke == null) return;
    setState(() {
      _strokes.add(stroke);
      _undoStack.clear(); // Clear undo stack when new stroke is added
      _currentStroke = null;
    });
  }

  void _clear() {
    setState(() {
      _undoStack.addAll(_strokes);
      _strokes.clear();
      _currentStroke = null;
      _version++;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;

    setState(() {
      _undoStack.add(_strokes.removeLast());
      _currentStroke = null;
      _version++;
    });
  }

  void _redo() {
    if (_undoStack.isEmpty) return;

    setState(() {
      _strokes.add(_undoStack.removeLast());
      _version++;
    });
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final List<WhiteboardStroke> allStrokes = switch (_currentStroke) {
      final s? => <WhiteboardStroke>[..._strokes, s],
      _ => _strokes,
    };

    return Column(
      children: <Widget>[
        // Toolbar
        WhiteboardToolbar(
          theme: theme,
          colors: colors,
          currentColor: _effectiveColor,
          currentWidth: _currentWidth,
          canUndo: _strokes.isNotEmpty,
          canRedo: _undoStack.isNotEmpty,
          canClear: allStrokes.isNotEmpty,
          onPickColor: _pickColor,
          onWidthChanged: (final value) {
            setState(() {
              _currentWidth = value;
            });
          },
          onUndo: _undo,
          onRedo: _redo,
          onClear: _clear,
        ),
        // Canvas
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (final details) {
              _startStroke(details.localPosition);
            },
            onPanUpdate: (final details) {
              _updateStroke(details.localPosition);
            },
            onPanEnd: (final details) {
              _endStroke();
            },
            child: LayoutBuilder(
              builder:
                  (
                    final context,
                    final constraints,
                  ) => RepaintBoundary(
                    child: CustomPaint(
                      key: ValueKey<int>(_version),
                      painter: WhiteboardPainter(
                        strokes: allStrokes,
                        backgroundColor: colors.surface,
                      ),
                      size: constraints.biggest,
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
