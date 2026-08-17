import 'package:material_ui/material_ui.dart';

String formatDeviceDateTime(BuildContext context, DateTime utcOrLocal) {
  final DateTime local = utcOrLocal.toLocal();
  final MaterialLocalizations material = MaterialLocalizations.of(context);
  final String date = material.formatShortDate(local);
  final String time = material.formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
  return '$date $time';
}

String formatDeviceTimeRange(
  BuildContext context,
  DateTime start,
  DateTime end,
) =>
    '${formatDeviceDateTime(context, start)} → ${formatDeviceDateTime(context, end)}';
