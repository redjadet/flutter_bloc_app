import 'package:design_system/responsive.dart';
import 'package:material_ui/material_ui.dart';

class ChartScrollable extends StatelessWidget {
  const ChartScrollable({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: context.allGapL,
    children: children,
  );
}
