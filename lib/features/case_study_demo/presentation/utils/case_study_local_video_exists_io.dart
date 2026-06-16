import 'dart:io';

import 'package:flutter/foundation.dart';

bool _caseStudyLocalVideoExistsSync(final String path) => File(
  path,
).existsSync(); // check-ignore: sync worker for compute off UI isolate

/// Whether a local video file exists; uses `compute` off the UI isolate.
Future<bool> caseStudyLocalVideoExists(final String path) =>
    compute(_caseStudyLocalVideoExistsSync, path);
