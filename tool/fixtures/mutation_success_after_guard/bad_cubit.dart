// Fixture: false failure when guard superseded after successful mutation.
class BadCubit {
  int _requestId = 0;

  bool _isRequestStillActive(int requestId) => requestId == _requestId;

  Future<bool> book() async {
    await Future<void>.value();
    if (!_isRequestStillActive(_requestId)) {
      return false;
    }
    return true;
  }
}
