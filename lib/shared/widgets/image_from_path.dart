import 'package:flutter/widgets.dart' show BoxFit;
import 'package:flutter_bloc_app/shared/widgets/image_from_path_stub.dart'
    if (dart.library.io) 'package:flutter_bloc_app/shared/widgets/image_from_path_io.dart'
    if (dart.library.html) 'package:flutter_bloc_app/shared/widgets/image_from_path_web.dart';
import 'package:flutter_bloc_app/shared/widgets/image_from_path_types.dart';

/// Renders an image from a runtime path returned by pickers/repos.
///
/// - On IO platforms, this is a local file path.
/// - On web, this is typically a blob/object URL.
ImageFromPathWidget imageFromPath({
  required String path,
  required BoxFit fit,
  required ObjectErrorWidgetBuilder errorBuilder,
}) => buildImageFromPath(path: path, fit: fit, errorBuilder: errorBuilder);
