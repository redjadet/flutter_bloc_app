import 'dart:math';

/// Generates a unique change identifier for offline-first sync operations.
String generateOfflineChangeId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
    Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
