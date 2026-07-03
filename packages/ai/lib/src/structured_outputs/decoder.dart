import 'schema.dart';
import 'validation_error.dart';

/// Decodes provider JSON maps into typed domain maps.
abstract interface class StructuredOutputDecoder {
  Map<String, Object?> decode({
    required OutputSchema schema,
    required Map<String, Object?> payload,
  });
}

class MapStructuredOutputDecoder implements StructuredOutputDecoder {
  @override
  Map<String, Object?> decode({
    required final OutputSchema schema,
    required final Map<String, Object?> payload,
  }) {
    for (final field in schema.fields) {
      if (field.required && !payload.containsKey(field.name)) {
        throw StructuredOutputValidationError(
          'Missing required field',
          field: field.name,
        );
      }
    }
    return Map<String, Object?>.from(payload);
  }
}
