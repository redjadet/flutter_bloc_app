/// Shared naming helpers for generated BLoC code.
library;

/// Lowercases the first character of [input].
String toCamelCase(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toLowerCase() + input.substring(1);
}
