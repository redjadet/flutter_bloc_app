import 'dart:async';

bool isStaffDemoTransientNetworkError(final Object error) {
  if (error is TimeoutException) {
    return true;
  }
  // Firebase / http clients may throw ClientException without a direct http dep.
  final String typeName = error.runtimeType.toString();
  return typeName == 'ClientException' || typeName.endsWith('.ClientException');
}
