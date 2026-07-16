/// Defensive JSON readers for AI Decision wire payloads.
///
/// Throws [FormatException] on missing/malformed required fields — never
/// leak raw cast/`TypeError` to callers.
Never _badAiDecision(final String key, final Object? value) =>
    throw FormatException('AI Decision JSON: invalid "$key" ($value)');

String requireAiDecisionString(
  final Map<String, dynamic> json,
  final String key,
) {
  final Object? value = json[key];
  if (value is! String || value.isEmpty) {
    _badAiDecision(key, value);
  }
  return value;
}

String? optionalAiDecisionString(
  final Map<String, dynamic> json,
  final String key,
) {
  final Object? value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    _badAiDecision(key, value);
  }
  return value;
}

double requireAiDecisionNumAsDouble(
  final Map<String, dynamic> json,
  final String key,
) {
  final Object? value = json[key];
  if (value is! num) {
    _badAiDecision(key, value);
  }
  return value.toDouble();
}

Map<String, dynamic> requireAiDecisionMap(
  final Map<String, dynamic> json,
  final String key,
) {
  final Object? value = json[key];
  if (value is! Map) {
    _badAiDecision(key, value);
  }
  return Map<String, dynamic>.from(value);
}

Map<String, dynamic> optionalAiDecisionMap(
  final Map<String, dynamic> json,
  final String key, {
  final Map<String, dynamic> fallback = const <String, dynamic>{},
}) {
  final Object? value = json[key];
  if (value == null) {
    return fallback;
  }
  if (value is! Map) {
    _badAiDecision(key, value);
  }
  return Map<String, dynamic>.from(value);
}

List<Map<String, dynamic>> requireAiDecisionMapList(
  final Map<String, dynamic> json,
  final String key, {
  final bool required = false,
}) {
  final Object? value = json[key];
  if (value == null) {
    if (required) {
      _badAiDecision(key, value);
    }
    return const <Map<String, dynamic>>[];
  }
  if (value is! List) {
    _badAiDecision(key, value);
  }
  final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
  for (var i = 0; i < value.length; i++) {
    final Object? element = value[i];
    if (element is! Map) {
      _badAiDecision('$key[$i]', element);
    }
    out.add(Map<String, dynamic>.from(element));
  }
  return List<Map<String, dynamic>>.unmodifiable(out);
}
