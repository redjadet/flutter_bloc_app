import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';

class ChartMessageList extends StatelessWidget {
  const ChartMessageList({required this.message, super.key});

  final String message;

  @override
  Widget build(final BuildContext context) => ChartScrollable(
    children: <Widget>[
      SizedBox(height: UI.gapL),
      AppMessage(message: message),
    ],
  );
}
