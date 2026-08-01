import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';

/// Leaf I/O for counter persistence (Hive local or REST/RTDB remote).
///
/// The domain repository facade owns the application-facing contract; use this
/// narrower port for adapters that only read/write storage or network.
abstract class CounterDataSource {
  Future<CounterSnapshot> load();
  Future<void> save(final CounterSnapshot snapshot);
  Stream<CounterSnapshot> watch();
}
