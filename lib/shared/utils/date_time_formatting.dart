import 'package:flutter/material.dart';

String formatDeviceDateTime(
  final BuildContext context,
  final DateTime utcOrLocal,
) {
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
  final BuildContext context,
  final DateTime start,
  final DateTime end,
) =>
    '${formatDeviceDateTime(context, start)} → ${formatDeviceDateTime(context, end)}';

// eof
// end
//
//
