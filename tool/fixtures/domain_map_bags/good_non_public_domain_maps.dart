/// Fixture: private and method-local Maps are not public domain contracts.
class GoodNonPublicDomainMaps {
  const GoodNonPublicDomainMaps(this._privatePayload);

  final Map<String, dynamic> _privatePayload;

  int payloadSize() {
    final Map<String, dynamic> localPayload = _privatePayload;
    return localPayload.length;
  }
}
