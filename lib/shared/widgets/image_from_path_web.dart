import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/shared/widgets/cached_network_image_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/image_from_path_types.dart';

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
