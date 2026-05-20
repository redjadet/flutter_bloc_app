import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/cached_network_image_widget.dart';

class BadImage extends StatelessWidget {
  const BadImage({super.key});
  @override
  Widget build(final BuildContext context) => CachedNetworkImageWidget(
    imageUrl: 'https://example.com/x.png',
    width: 48,
    height: 48,
  );
}
