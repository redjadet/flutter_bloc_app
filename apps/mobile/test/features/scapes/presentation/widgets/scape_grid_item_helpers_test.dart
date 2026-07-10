import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/scapes/presentation/widgets/scape_grid_item_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fitTitleStyle shrinks oversized titles', () {
    final TextStyle fitted = fitTitleStyle(
      baseStyle: const TextStyle(fontSize: 40),
      text: 'A very long scape title that should shrink',
      maxWidth: 40,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    );

    expect(fitted.fontSize, isNotNull);
    expect(fitted.fontSize! < 40, isTrue);
  });

  test('fitTitleStyle keeps short titles near base size', () {
    final TextStyle fitted = fitTitleStyle(
      baseStyle: const TextStyle(fontSize: 18),
      text: 'Hi',
      maxWidth: 200,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    );

    expect(fitted.fontSize, 18);
  });
}
