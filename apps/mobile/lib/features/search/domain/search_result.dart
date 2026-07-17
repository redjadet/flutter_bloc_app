import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';

@freezed
abstract class SearchResult with _$SearchResult {
  const factory SearchResult({
    required final String id,
    required final String imageUrl,
    final String? title,
    final String? description,
  }) = _SearchResult;
}
