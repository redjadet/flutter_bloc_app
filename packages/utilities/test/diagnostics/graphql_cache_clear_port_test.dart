import 'package:test/test.dart';
import 'package:utilities/utilities.dart';

class _FakeGraphqlCacheClearPort implements GraphqlCacheClearPort {
  bool cleared = false;

  @override
  Future<void> clear() async {
    cleared = true;
  }
}

void main() {
  test('GraphqlCacheClearPort.clear completes', () async {
    final _FakeGraphqlCacheClearPort port = _FakeGraphqlCacheClearPort();
    await port.clear();
    expect(port.cleared, isTrue);
  });
}
