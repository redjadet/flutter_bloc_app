import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status_repository.dart';

/// Stub eSIM / porting / billing statuses for design-system cards.
///
/// Detail copy is left null so presentation can use l10n fallbacks.
class StubLineStatusRepository implements LineStatusRepository {
  const new({
    this.snapshot = const LineStatusSnapshot(
      esim: LineLifecycleStatus.active,
      porting: LineLifecycleStatus.pending,
      billing: LineLifecycleStatus.attention,
    ),
  });

  final LineStatusSnapshot snapshot;

  @override
  Future<LineStatusSnapshot> fetch() async => snapshot;
}
