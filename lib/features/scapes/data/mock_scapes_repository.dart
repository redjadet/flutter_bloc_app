import 'dart:math';

import 'package:flutter_bloc_app/features/scapes/domain/scape.dart';
import 'package:flutter_bloc_app/features/scapes/domain/scapes_repository.dart';

/// Mock implementation of [ScapesRepository] that returns deterministic sample data.
class MockScapesRepository implements ScapesRepository {
  @override
  Future<List<Scape>> loadScapes() async {
    final random = Random(42);
    const colors = <String>[
      'pink',
      'orange',
      'green',
      'yellow',
      'purple',
      'blue',
    ];

    return List.generate(6, (final index) {
      final color = colors[index % colors.length];
      return Scape(
        id: 'scape_$index',
        name: 'Scape Name ${index + 1}',
        imageUrl: 'https://picsum.photos/seed/$color$index/400/400',
        duration: Duration(seconds: random.nextInt(3600)),
        assetCount: random.nextInt(100),
      );
    });
  }
}
