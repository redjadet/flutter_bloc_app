/// JSON-schema-like field descriptor (provider-neutral).
class SchemaField {
  const SchemaField({
    required this.name,
    required this.type,
    this.required = true,
  });

  final String name;
  final String type;
  final bool required;
}

class OutputSchema {
  const OutputSchema({required this.fields});

  final List<SchemaField> fields;
}
