import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class GoodImage extends StatelessWidget {
  const GoodImage({super.key});
  @override
  Widget build(final BuildContext context) => CachedNetworkImageWidget(
    imageUrl: 'https://example.com/x.png',
    width: 48,
    height: 48,
    memCacheWidth: 48,
    memCacheHeight: 48,
  );
}
