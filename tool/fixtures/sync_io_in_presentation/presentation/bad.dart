import 'dart:io';

bool badSync(final String path) => File(path).existsSync();
