import 'dart:async';
import 'dart:io';

bool isStaffDemoTransientNetworkError(final Object error) =>
    error is SocketException || error is TimeoutException;
