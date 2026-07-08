import 'package:flutter/widgets.dart';

import 'cached_network_image_widget.dart';
import 'image_from_path_types.dart';

ImageFromPathWidget buildImageFromPath({
  required String path,
  required BoxFit fit,
  required ObjectErrorWidgetBuilder errorBuilder,
}) {
  return CachedNetworkImageWidget(
    imageUrl: path,
    fit: fit,
    errorWidget: (final context, final _, final error) =>
        errorBuilder(context, error, null),
  );
}
