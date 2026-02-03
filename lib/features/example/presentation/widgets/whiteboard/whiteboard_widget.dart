import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_painter.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_toolbar.dart';

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
  Color _currentColor = Colors.black;
  double _currentWidth = 3;
  WhiteboardStroke? _currentStroke;
  int _version = 0;

  Future<void> _pickColor() async {
    final Color color = await showColorPickerDialog(
      context,
      _currentColor,
      title: const Text('Choose pen color'),
      heading: const Text('Pick a color'),
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
        color: _currentColor,
        width: _currentWidth,
      );
    });
  }

  void _updateStroke(final Offset position) {
    if (_currentStroke == null) return;

    setState(() {
      _currentStroke = _currentStroke!.copyWith(
        points: <Offset>[..._currentStroke!.points, position],
      );
    });
  }

  void _endStroke() {
    if (_currentStroke == null) return;

    setState(() {
      _strokes.add(_currentStroke!);
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
    final List<WhiteboardStroke> allStrokes = _currentStroke != null
        ? <WhiteboardStroke>[..._strokes, _currentStroke!]
        : _strokes;

    return Column(
      children: <Widget>[
        // Toolbar
        WhiteboardToolbar(
          theme: theme,
          colors: colors,
          currentColor: _currentColor,
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
