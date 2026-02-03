import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';

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

  if (isCupertino) {
    // Use modal bottom sheet for iOS - CupertinoAlertDialog is too constrained
    final _DatePickerResult?
    result = await showCupertinoModalPopup<_DatePickerResult>(
      context: context,
      builder: (final popupContext) => StatefulBuilder(
        builder: (final context, final setState) {
          // Ensure initialDateTime is not before minimumDate for CupertinoDatePicker
          final DateTime safeInitialDateTime = selected.isBefore(firstDate)
              ? firstDate
              : selected.isAfter(lastDate)
              ? lastDate
              : selected;

          final theme = Theme.of(context);
          return Container(
            height: 350,
            padding: const EdgeInsets.only(top: 6),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Date Picker
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: safeInitialDateTime,
                      minimumDate: firstDate,
                      maximumDate: lastDate,
                      onDateTimeChanged: (final value) {
                        setState(() {
                          selected = value;
                        });
                      },
                    ),
                  ),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        onPressed: () => NavigationUtils.maybePop(popupContext),
                        child: Text(cancelLabel),
                      ),
                      if (initialDate != null)
                        CupertinoButton(
                          onPressed: () => NavigationUtils.maybePop(
                            popupContext,
                            result: const _DatePickerResult.cleared(),
                          ),
                          child: Text(clearLabel),
                        ),
                      CupertinoButton(
                        onPressed: () => NavigationUtils.maybePop(
                          popupContext,
                          result: _DatePickerResult.confirmed(selected),
                        ),
                        child: Text(saveLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (result == null || !result.didConfirm) {
      return null;
    }
    return result.date;
  }

  // Material dialog for Android
  final _DatePickerResult? result = await showDialog<_DatePickerResult>(
    context: context,
    builder: (final context) => StatefulBuilder(
      builder: (final context, final setState) {
        final Widget picker = SizedBox(
          height: 320,
          child: CalendarDatePicker(
            initialDate: selected,
            firstDate: firstDate,
            lastDate: lastDate,
            onDateChanged: (final value) {
              setState(() {
                selected = value;
              });
            },
          ),
        );

        final List<Widget> actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelLabel),
          ),
          if (initialDate != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(
                const _DatePickerResult.cleared(),
              ),
              child: Text(clearLabel),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              _DatePickerResult.confirmed(selected),
            ),
            child: Text(saveLabel),
          ),
        ];

        return AlertDialog(
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
