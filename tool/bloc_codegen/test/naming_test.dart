import 'package:bloc_codegen/src/naming.dart';
import 'package:test/test.dart';

void main() {
  test('toCamelCase lowercases the first character', () {
    expect(toCamelCase('Ready'), 'ready');
    expect(toCamelCase('A'), 'a');
    expect(toCamelCase(''), '');
  });
}
