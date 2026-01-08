import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';

class LibraryWordmark extends StatelessWidget {
  const LibraryWordmark({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(final BuildContext context) => Container(
    height: EpochSpacing.wordmarkHeight,
    alignment: Alignment.center,
    child: Text(
      title.toUpperCase(),
      style: EpochTextStyles.wordmark(context),
    ),
  );
}
