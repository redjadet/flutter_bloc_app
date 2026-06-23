/// Default UTC window for manager shift-assignment compose flows.
class StaffDemoShiftDefaults {
  const StaffDemoShiftDefaults._();

  static const Duration leadTime = Duration(minutes: 30);
  static const Duration duration = Duration(hours: 4);

  static ({DateTime startAtUtc, DateTime endAtUtc}) defaultWindowUtc([
    final DateTime? now,
  ]) {
    final DateTime startAtUtc = (now ?? DateTime.now()).toUtc().add(leadTime);
    return (
      startAtUtc: startAtUtc,
      endAtUtc: startAtUtc.add(duration),
    );
  }
}
