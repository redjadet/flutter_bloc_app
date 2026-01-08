import 'package:flutter/material.dart';

@immutable
class LibraryAsset {
  const LibraryAsset({
    required this.name,
    required this.type,
    required this.durationLabel,
    required this.formatLabel,
    this.thumbnailAssetPath,
    this.backgroundColor,
  });

  final String name;
  final String type;
  final String durationLabel;
  final String formatLabel;
  final String? thumbnailAssetPath;
  final Color? backgroundColor;

  bool get isAudio => type.toLowerCase() == 'sound';
}

@immutable
class LibraryCategory {
  const LibraryCategory({required this.label});

  final String label;
}
