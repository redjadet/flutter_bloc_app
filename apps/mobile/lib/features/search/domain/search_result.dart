import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';

@freezed
abstract class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String id,
    required String imageUrl,
    String? title,
    String? description,
  }) = _SearchResult;
}
