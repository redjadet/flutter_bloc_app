import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChartScrollable extends StatelessWidget {
  const ChartScrollable({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: context.allGapL,
    itemCount: children.length,
    itemBuilder: (final context, final index) => children[index],
  );
}
