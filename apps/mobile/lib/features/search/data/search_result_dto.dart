import 'package:flutter_bloc_app/features/search/domain/search_result.dart';

/// Wire DTO for [SearchResult] Hive cache payloads.
class const SearchResultDto({
  required final String id,
  required final String imageUrl,
  final String? title,
  final String? description,
}) {
  SearchResultDto.fromDomain(SearchResult result)
    : this(
        id: result.id,
        imageUrl: result.imageUrl,
        title: result.title,
        description: result.description,
      );

  factory SearchResultDto.fromJson(Map<String, dynamic> json) =>
      SearchResultDto(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String,
        title: json['title'] as String?,
        description: json['description'] as String?,
      );

  SearchResult toDomain() => SearchResult(
    id: id,
    imageUrl: imageUrl,
    title: title,
    description: description,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'imageUrl': imageUrl,
    'title': title,
    'description': description,
  };
}
