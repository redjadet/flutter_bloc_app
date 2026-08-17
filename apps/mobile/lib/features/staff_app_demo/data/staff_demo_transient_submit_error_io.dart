import 'dart:async';
import 'dart:io';

bool isStaffDemoTransientNetworkError(Object error) =>
    error is SocketException || error is TimeoutException;
