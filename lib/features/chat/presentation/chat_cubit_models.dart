part of 'chat_cubit.dart';

List<String> _buildModelList(
  final String? initialModel,
  final List<String>? supportedModels,
) {
  final LinkedHashSet<String> ordered = LinkedHashSet<String>();
  void add(final String? value) {
    if (value == null) return;
    final String trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      ordered.add(trimmed);
    }
  }

  add(initialModel);
  if (supportedModels != null) {
    supportedModels.forEach(add);
  }
  add('openai/gpt-oss-20b');
  add('openai/gpt-oss-120b');

  return ordered.toList(growable: false);
}

String _resolveInitialModel(
  final String? initialModel,
  final List<String>? supportedModels,
) {
  final String? trimmed = _normalize(initialModel);
  if (trimmed != null) return trimmed;
  final List<String> models = _buildModelList(initialModel, supportedModels);
  return models.first;
}

String? _normalize(final String? value) {
  if (value == null) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
