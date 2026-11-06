/// High-level lifecycle for eSIM / porting / billing cards.
enum LineLifecycleStatus { unknown, pending, active, attention, blocked }

/// Snapshot of business-line account surfaces shown as status cards.
class const LineStatusSnapshot({
  required final LineLifecycleStatus esim,
  required final LineLifecycleStatus porting,
  required final LineLifecycleStatus billing,
  final String? esimDetail,
  final String? portingDetail,
  final String? billingDetail,
}) {
  factory initial() => const LineStatusSnapshot(
    esim: LineLifecycleStatus.unknown,
    porting: LineLifecycleStatus.unknown,
    billing: LineLifecycleStatus.unknown,
  );
}
