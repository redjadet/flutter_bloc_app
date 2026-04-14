import 'dart:io' show File;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/shared/widgets/image_from_path_types.dart';

ImageFromPathWidget buildImageFromPath({
  required String path,
  required BoxFit fit,
  required ObjectErrorWidgetBuilder errorBuilder,
}) {
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (context, error, stackTrace) =>
        errorBuilder(context, error, stackTrace),
  );
}
