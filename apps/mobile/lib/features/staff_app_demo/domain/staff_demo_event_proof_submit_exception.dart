class StaffDemoEventProofOfflineEnqueuedException implements Exception {
  const new();
}

/// Local proof asset missing at submit time (photo or signature).
class StaffDemoProofFileMissingException implements Exception {
  new(this.message);

  final String message;

  @override
  String toString() => message;
}
