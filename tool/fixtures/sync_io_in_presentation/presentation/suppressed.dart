import 'dart:io';

// check-ignore: fixture documents intentional sync for compute worker
bool suppressedSync(final String path) => File(path).existsSync();
