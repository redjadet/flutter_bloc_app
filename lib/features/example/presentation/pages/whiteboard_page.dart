import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_widget.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

/// Page showcasing the whiteboard widget with CustomPainter.
class WhiteboardPage extends StatelessWidget {
  const WhiteboardPage({super.key});

  @override
  Widget build(final BuildContext context) => const CommonPageLayout(
    title: 'Whiteboard',
    body: WhiteboardWidget(),
  );
}
