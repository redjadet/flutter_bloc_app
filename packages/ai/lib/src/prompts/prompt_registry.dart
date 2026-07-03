import 'prompt_template.dart';

/// In-memory prompt registry for tests and adapters.
class PromptRegistry {
  final Map<String, PromptTemplate> _templates = {};

  void register(final PromptTemplate template) {
    _templates['${template.id}@${template.version}'] = template;
  }

  PromptTemplate? lookup(final String id, final String version) =>
      _templates['$id@$version'];
}
