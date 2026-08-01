import 'package:flutter_bloc_app/features/counter/domain/counter_data_source.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_diagnostics_port.dart';

export 'counter_data_source.dart';
export 'counter_sync_diagnostics_port.dart';

/// Abstraction over counter persistence (domain-facing facade).
///
/// Enables substituting OfflineFirst / local-only backends without changing
/// presentation. Leaf Hive/REST adapters implement [CounterDataSource];
/// sync inspector APIs live on [CounterSyncDiagnosticsPort].
abstract class CounterRepository implements CounterDataSource {}
