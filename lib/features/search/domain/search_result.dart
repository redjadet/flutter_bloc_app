import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';
part 'search_result.g.dart';

@freezed
abstract class SearchResult with _$SearchResult {
  const factory SearchResult({
    required final String id,
    required final String imageUrl,
    final String? title,
    final String? description,
  }) = _SearchResult;

  factory SearchResult.fromJson(final Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
