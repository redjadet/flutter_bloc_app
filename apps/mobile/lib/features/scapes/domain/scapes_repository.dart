import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';

/// Abstraction for loading scapes (e.g. for library/grid views).
abstract class ScapesRepository {
  /// Loads the list of scapes.
  Future<List<Scape>> loadScapes();
}
