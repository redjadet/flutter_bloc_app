import 'package:feature_flags/feature_flags.dart';
import 'package:test/test.dart';

class _FakeRenderOrchestrationRemoteTokenPort
    implements RenderOrchestrationRemoteTokenPort {
  _FakeRenderOrchestrationRemoteTokenPort(this._token);

  String? _token;
  int refreshCount = 0;

  @override
  String? readDevToken() => _token;

  @override
  Future<void> forceRefresh() async {
    refreshCount += 1;
  }
}

void main() {
  test('exposes nullable token and refresh capability', () async {
    final _FakeRenderOrchestrationRemoteTokenPort withToken =
        _FakeRenderOrchestrationRemoteTokenPort('abc');
    expect(withToken.readDevToken(), 'abc');

    final _FakeRenderOrchestrationRemoteTokenPort missing =
        _FakeRenderOrchestrationRemoteTokenPort(null);
    expect(missing.readDevToken(), isNull);

    await withToken.forceRefresh();
    expect(withToken.refreshCount, 1);
  });
}
