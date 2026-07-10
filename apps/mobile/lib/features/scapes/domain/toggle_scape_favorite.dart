import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';

/// Returns a new list with [scapeId]'s favorite flag flipped.
List<Scape> toggleScapeFavorite(
  final List<Scape> scapes,
  final String scapeId,
) => scapes
    .map(
      (final scape) => scape.id == scapeId
          ? scape.copyWith(isFavorite: !scape.isFavorite)
          : scape,
    )
    .toList();
