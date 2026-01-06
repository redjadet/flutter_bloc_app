import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class _DatePickerResult {
  const _DatePickerResult.confirmed(DateTime this.date) : didConfirm = true;

  const _DatePickerResult.cleared() : date = null, didConfirm = true;

  final DateTime? date;
  final bool didConfirm;
}

String formatTodoDate(final DateTime date) {
  final DateTime localDate = date.toLocal();
  return '${localDate.year}-'
      '${localDate.month.toString().padLeft(2, '0')}-'
      '${localDate.day.toString().padLeft(2, '0')}';
}

Future<DateTime?> showAdaptiveTodoDatePicker({
  required final BuildContext context,
  required final bool isCupertino,
  required final DateTime? initialDate,
  required final DateTime firstDate,
  required final DateTime lastDate,
  required final String title,
  required final String cancelLabel,
  required final String clearLabel,
  required final String saveLabel,
}) async {
  // Normalize dates to compare only the date part (ignore time)
  DateTime normalizeDate(final DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Ensure initial date is within valid range
  DateTime resolvedInitial;
  if (initialDate == null) {
    // Use current date if no initial date provided
    resolvedInitial = DateTime.now();
  } else {
    resolvedInitial = initialDate;
  }

  // Normalize for comparison
  final DateTime normalizedInitial = normalizeDate(resolvedInitial);
  final DateTime normalizedFirst = normalizeDate(firstDate);
  final DateTime normalizedLast = normalizeDate(lastDate);

  // Clamp to valid range (compare dates only, not times)
  if (normalizedInitial.isBefore(normalizedFirst)) {
    // Before minimum date: use minimum date
    resolvedInitial = firstDate;
  } else if (normalizedInitial.isAfter(normalizedLast)) {
    // After maximum date: use maximum date
    resolvedInitial = lastDate;
  } else {
    // Same day as minimum or maximum: ensure full DateTime is within range
    if (resolvedInitial.isBefore(firstDate)) {
      // Same day but earlier time: use minimum date
      resolvedInitial = firstDate;
    } else if (resolvedInitial.isAfter(lastDate)) {
      // Same day but later time: use maximum date
      resolvedInitial = lastDate;
    } else {
      // Within range: keep the date but ensure it's not before minimum
      // For date-only pickers, we can normalize to start of day
      if (normalizedInitial == normalizedFirst &&
          resolvedInitial.isBefore(firstDate)) {
        resolvedInitial = firstDate;
      }
    }
  }

  DateTime selected = resolvedInitial;

  final _DatePickerResult? result = await showAdaptiveDialog<_DatePickerResult>(
    context: context,
    builder: (final context) => StatefulBuilder(
      builder: (final context, final setState) {
        // Ensure initialDateTime is not before minimumDate for CupertinoDatePicker
        final DateTime safeInitialDateTime = selected.isBefore(firstDate)
            ? firstDate
            : selected.isAfter(lastDate)
            ? lastDate
            : selected;

        final Widget picker = isCupertino
            ? SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: safeInitialDateTime,
                  minimumDate: firstDate,
                  maximumDate: lastDate,
                  onDateTimeChanged: (final DateTime value) {
                    setState(() {
                      selected = value;
                    });
                  },
                ),
              )
            : SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: selected,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (final DateTime value) {
                    setState(() {
                      selected = value;
                    });
                  },
                ),
              );

        final List<Widget> actions = [
          PlatformAdaptive.dialogAction(
            context: context,
            onPressed: () => Navigator.of(context).pop(),
            label: cancelLabel,
          ),
          if (initialDate != null)
            PlatformAdaptive.dialogAction(
              context: context,
              onPressed: () => Navigator.of(context).pop(
                const _DatePickerResult.cleared(),
              ),
              label: clearLabel,
            ),
          PlatformAdaptive.dialogAction(
            context: context,
            onPressed: () => Navigator.of(context).pop(
              _DatePickerResult.confirmed(selected),
            ),
            label: saveLabel,
          ),
        ];

        return isCupertino
            ? CupertinoAlertDialog(
                title: Text(title),
                content: Padding(
                  padding: EdgeInsets.only(top: context.responsiveGapS),
                  child: picker,
                ),
                actions: actions,
              )
            : AlertDialog(
                title: Text(title),
                content: picker,
                actions: actions,
              );
      },
    ),
  );

  if (result == null || !result.didConfirm) {
    return null;
  }
  return result.date;
}
