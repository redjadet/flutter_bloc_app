import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';

/// Returns a new list with [scapeId]'s favorite flag flipped.
List<Scape> toggleScapeFavorite(
  List<Scape> scapes,
  String scapeId,
) => scapes
    .map(
      (scape) => scape.id == scapeId
          ? scape.copyWith(isFavorite: !scape.isFavorite)
          : scape,
    )
    .toList();
