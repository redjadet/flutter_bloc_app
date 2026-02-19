import 'package:freezed_annotation/freezed_annotation.dart';

part 'scape.freezed.dart';

/// Represents a scape item in the library.
@freezed
abstract class Scape with _$Scape {
  const factory Scape({
    required final String id,
    required final String name,
    required final String imageUrl,
    required final Duration duration,
    required final int assetCount,
    @Default(false) final bool isFavorite,
  }) = _Scape;

  const Scape._();

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
