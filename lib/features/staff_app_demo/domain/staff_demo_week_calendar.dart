/// Week calendar helpers for staff demo availability forms.
class StaffDemoWeekCalendar {
  const StaffDemoWeekCalendar._();

  static DateTime weekStartUtc([final DateTime? now]) {
    final DateTime utc = (now ?? DateTime.now()).toUtc();
    final int weekday = utc.weekday; // Mon=1..Sun=7
    return DateTime.utc(utc.year, utc.month, utc.day).subtract(
      Duration(days: weekday - 1),
    );
  }

  static List<DateTime> weekDaysUtc(final DateTime weekStartUtc) =>
      List<DateTime>.generate(
        7,
        (final index) => weekStartUtc.add(Duration(days: index)),
        growable: false,
      );
}
