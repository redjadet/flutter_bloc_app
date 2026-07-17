import 'package:flutter_bloc_app/features/search/domain/search_result.dart';

/// Wire DTO for [SearchResult] Hive cache payloads.
class SearchResultDto {
  const SearchResultDto({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
  });

  SearchResultDto.fromDomain(final SearchResult result)
    : id = result.id,
      imageUrl = result.imageUrl,
      title = result.title,
      description = result.description;

  factory SearchResultDto.fromJson(final Map<String, dynamic> json) => SearchResultDto(
    id: json['id'] as String,
    imageUrl: json['imageUrl'] as String,
    title: json['title'] as String?,
    description: json['description'] as String?,
  );

  final String id;
  final String imageUrl;
  final String? title;
  final String? description;

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
