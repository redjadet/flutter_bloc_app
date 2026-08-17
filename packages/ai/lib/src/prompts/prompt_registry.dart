import 'prompt_template.dart';

/// In-memory prompt registry for tests and adapters.
class PromptRegistry {
  final Map<String, PromptTemplate> _templates = {};

  void register(PromptTemplate template) {
    _templates['${template.id}@${template.version}'] = template;
  }

  PromptTemplate? lookup(String id, String version) =>
      _templates['$id@$version'];
}
