import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SuppressedImage extends StatelessWidget {
  const SuppressedImage({super.key});

  @override
  // check-ignore: fixture documents warn-only suppression
  Widget build(final BuildContext context) => CachedNetworkImageWidget(
    imageUrl: 'https://example.com/x.png',
    width: 48,
    height: 48,
  );
}
