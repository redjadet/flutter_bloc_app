import 'dart:io';

// check-ignore: fixture documents intentional sync for compute worker
bool suppressedSync(String path) => File(path).existsSync();
