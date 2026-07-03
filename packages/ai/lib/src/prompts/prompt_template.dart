import 'prompt_version.dart';

/// Versioned prompt template without provider coupling.
class PromptTemplate {
  const PromptTemplate({
    required this.id,
    required this.version,
    required this.body,
    this.variables = const [],
  });

  final String id;
  final PromptVersion version;
  final String body;
  final List<String> variables;

  String render(final Map<String, String> values) {
    var rendered = body;
    for (final key in variables) {
      rendered = rendered.replaceAll('{{$key}}', values[key] ?? '');
    }
    return rendered;
  }
}
