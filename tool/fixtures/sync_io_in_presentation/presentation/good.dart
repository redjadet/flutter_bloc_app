import 'dart:io';

Future<bool> goodAsync(final String path) => File(path).exists();
