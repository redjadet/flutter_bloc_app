import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/whiteboard/whiteboard_widget.dart';

/// Page showcasing the whiteboard widget with CustomPainter.
class WhiteboardPage extends StatelessWidget {
  const WhiteboardPage({super.key});

  @override
  Widget build(final BuildContext context) => CommonPageLayout(
    title: context.l10n.whiteboardPageTitle,
    body: const WhiteboardWidget(),
  );
}
