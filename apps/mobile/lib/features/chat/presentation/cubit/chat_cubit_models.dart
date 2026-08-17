part of 'chat_cubit.dart';

List<String> _buildModelList(
  String? initialModel,
  List<String>? supportedModels,
) {
  final LinkedHashSet<String> ordered = LinkedHashSet<String>();
  void add(String? value) {
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
  add(kChatOrchestrationAutoModelId);
  add('openai/gpt-oss-20b');
  add('openai/gpt-oss-120b');

  return ordered.toList(growable: false);
}

String _resolveInitialModel(
  String? initialModel,
  List<String>? supportedModels,
) {
  final String? trimmed = _normalize(initialModel);
  if (trimmed != null) return trimmed;
  final List<String> models = _buildModelList(initialModel, supportedModels);
  // Defensive check: should never be empty as _buildModelList always adds defaults
  if (models.isEmpty) {
    return 'openai/gpt-oss-20b';
  }
  return models.first;
}

String? _normalize(String? value) {
  if (value == null) return null;
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
