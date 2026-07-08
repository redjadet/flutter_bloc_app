import 'package:flutter/widgets.dart' show BoxFit;

import 'image_from_path_stub.dart'
    if (dart.library.io) 'image_from_path_io.dart'
    if (dart.library.html) 'image_from_path_web.dart';
import 'image_from_path_types.dart';

/// Renders an image from a runtime path returned by pickers/repos.
///
/// - On IO platforms, this is a local file path.
/// - On web, this is typically a blob/object URL.
ImageFromPathWidget imageFromPath({
  required String path,
  required BoxFit fit,
  required ObjectErrorWidgetBuilder errorBuilder,
}) => buildImageFromPath(path: path, fit: fit, errorBuilder: errorBuilder);
