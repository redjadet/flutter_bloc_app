import 'dart:io';

bool badSync(String path) => File(path).existsSync();
