import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('formatDeviceDateTime matches MaterialLocalizations', (
    final tester,
  ) async {
    const Locale locale = Locale('en', 'US');
    final DateTime when = DateTime.utc(2024, 6, 15, 14, 30);

    late String actual;
    late String expected;

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        home: MediaQuery(
          data: const MediaQueryData(alwaysUse24HourFormat: true),
          child: Builder(
            builder: (final context) {
              actual = formatDeviceDateTime(context, when);
              final DateTime local = when.toLocal();
              final MaterialLocalizations material = MaterialLocalizations.of(
                context,
              );
              expected =
                  '${material.formatShortDate(local)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true)}';
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(actual, expected);
  });

  testWidgets('formatDeviceTimeRange joins with arrow', (final tester) async {
    const Locale locale = Locale('en', 'US');
    final DateTime start = DateTime.utc(2024, 6, 15, 14, 30);
    final DateTime end = DateTime.utc(2024, 6, 15, 15, 45);

    late String actual;
    late String expected;

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        home: MediaQuery(
          data: const MediaQueryData(alwaysUse24HourFormat: true),
          child: Builder(
            builder: (final context) {
              actual = formatDeviceTimeRange(context, start, end);
              expected =
                  '${formatDeviceDateTime(context, start)} → ${formatDeviceDateTime(context, end)}';
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(actual, expected);
  });
}
