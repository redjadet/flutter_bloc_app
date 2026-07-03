import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_shift_defaults.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_week_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StaffDemoShiftDefaults', () {
    test('defaultWindowUtc applies lead time and duration', () {
      final DateTime now = DateTime.utc(2026, 6, 23, 10, 0);
      final window = StaffDemoShiftDefaults.defaultWindowUtc(now);

      expect(window.startAtUtc, now.add(StaffDemoShiftDefaults.leadTime));
      expect(
        window.endAtUtc,
        window.startAtUtc.add(StaffDemoShiftDefaults.duration),
      );
    });
  });

  group('StaffDemoWeekCalendar', () {
    test('weekStartUtc returns Monday 00:00 UTC', () {
      final DateTime wednesday = DateTime.utc(2026, 6, 24, 15, 30);
      final DateTime start = StaffDemoWeekCalendar.weekStartUtc(wednesday);

      expect(start, DateTime.utc(2026, 6, 22));
    });

    test('weekDaysUtc returns seven consecutive UTC days', () {
      final DateTime start = DateTime.utc(2026, 6, 22);
      final days = StaffDemoWeekCalendar.weekDaysUtc(start);

      expect(days, hasLength(7));
      expect(days.first, start);
      expect(days.last, DateTime.utc(2026, 6, 28));
    });
  });
}
