// Fixture: superseded guard after mutation still reports success.
class GoodCubit {
  int _requestId = 0;

  bool _isRequestStillActive(int requestId) => requestId == _requestId;

  Future<bool> book() async {
    await Future<void>.value();
    if (!_isRequestStillActive(_requestId)) {
      return true;
    }
    return true;
  }
}
