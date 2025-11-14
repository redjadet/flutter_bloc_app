import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChartScrollable extends StatelessWidget {
  const ChartScrollable({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: EdgeInsets.all(context.responsiveGapL),
    children: children,
  );
}
