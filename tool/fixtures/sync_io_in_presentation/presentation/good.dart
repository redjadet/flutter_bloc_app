import 'dart:io';

Future<bool> goodAsync(String path) => File(path).exists();
