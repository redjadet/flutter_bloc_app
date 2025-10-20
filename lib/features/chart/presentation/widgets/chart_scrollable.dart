import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ChartScrollable extends StatelessWidget {
  const ChartScrollable({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.all(UI.gapL),
    children: children,
  );
}
