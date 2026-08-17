import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:material_ui/material_ui.dart';

class ChartMessageList extends StatelessWidget {
  const ChartMessageList({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => ChartScrollable(
    children: <Widget>[
      SizedBox(height: context.responsiveGapL),
      AppMessage(message: message),
    ],
  );
}
