// Fixture: violation suppressed via check-ignore on previous line.
class SuppressedCubit {
  int _requestId = 0;

  bool _isRequestStillActive(int requestId) => requestId == _requestId;

  Future<bool> book() async {
    await Future<void>.value();
    // check-ignore: fixture documents intentional suppression
    if (!_isRequestStillActive(_requestId)) {
      return false;
    }
    return true;
  }
}
