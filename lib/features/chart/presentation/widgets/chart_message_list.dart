import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class ChartMessageList extends StatelessWidget {
  const ChartMessageList({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChartScrollable(
      children: [
        SizedBox(height: UI.gapL * 2),
        Center(child: Text(message, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}
