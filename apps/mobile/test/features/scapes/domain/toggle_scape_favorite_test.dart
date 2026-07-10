import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/domain/toggle_scape_favorite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Scape a = Scape(
    id: 'a',
    name: 'A',
    imageUrl: 'https://example.com/a.png',
    duration: Duration(minutes: 1),
    assetCount: 1,
  );
  const Scape b = Scape(
    id: 'b',
    name: 'B',
    imageUrl: 'https://example.com/b.png',
    duration: Duration(minutes: 2),
    assetCount: 2,
    isFavorite: true,
  );

  test('toggles favorite on matching id', () {
    final List<Scape> result = toggleScapeFavorite(<Scape>[a, b], 'a');
    expect(result[0].isFavorite, isTrue);
    expect(result[1].isFavorite, isTrue);
  });

  test('toggles favorite off when already favorite', () {
    final List<Scape> result = toggleScapeFavorite(<Scape>[a, b], 'b');
    expect(result[0].isFavorite, isFalse);
    expect(result[1].isFavorite, isFalse);
  });

  test('unknown id leaves favorites unchanged', () {
    final List<Scape> result = toggleScapeFavorite(<Scape>[a, b], 'missing');
    expect(result[0].isFavorite, a.isFavorite);
    expect(result[1].isFavorite, b.isFavorite);
  });
}
