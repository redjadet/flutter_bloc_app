/// Defensive JSON readers for GraphQL country wire payloads.
Never _badGraphql(final String key, final Object? value) =>
    throw FormatException('GraphQL JSON: invalid "$key" ($value)');

String requireGraphqlString(
  final Map<String, dynamic> json,
  final String key,
) {
  final Object? value = json[key];
  if (value is! String || value.isEmpty) {
    _badGraphql(key, value);
  }
  return value;
}

String? optionalGraphqlString(
  final Map<String, dynamic> json,
  final String key,
) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    _badGraphql(key, value);
  }
  return value;
}

Map<String, dynamic> requireGraphqlMap(
  final Map<String, dynamic> json,
  final String key,
) {
  final Object? value = json[key];
  if (value is! Map) {
    _badGraphql(key, value);
  }
  return Map<String, dynamic>.from(value);
}
