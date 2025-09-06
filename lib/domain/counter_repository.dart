import 'package:flutter_bloc_app/domain/counter_snapshot.dart';

/// Abstraction over counter persistence.
/// Enables substituting storage without changing business logic (DIP).
abstract class CounterRepository {
  Future<CounterSnapshot> load();
  Future<void> save(CounterSnapshot snapshot);
}
