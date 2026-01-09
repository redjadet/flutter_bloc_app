/// Represents a scape item in the library.
class Scape {
  const Scape({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.duration,
    required this.assetCount,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String imageUrl;
  final Duration duration;
  final int assetCount;
  final bool isFavorite;

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Scape copyWith({
    final String? id,
    final String? name,
    final String? imageUrl,
    final Duration? duration,
    final int? assetCount,
    final bool? isFavorite,
  }) => Scape(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    duration: duration ?? this.duration,
    assetCount: assetCount ?? this.assetCount,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
