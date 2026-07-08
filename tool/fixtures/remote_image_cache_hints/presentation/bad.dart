import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BadImage extends StatelessWidget {
  const BadImage({super.key});
  @override
  Widget build(final BuildContext context) => CachedNetworkImageWidget(
    imageUrl: 'https://example.com/x.png',
    width: 48,
    height: 48,
  );
}
