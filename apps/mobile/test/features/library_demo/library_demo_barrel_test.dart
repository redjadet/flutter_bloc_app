import 'package:flutter_bloc_app/features/library_demo/library_demo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('library_demo barrel exposes public API types', () {
    expect(LibraryDemoPage, isA<Type>());
    expect(LibraryDemoBody, isA<Type>());
  });
}
