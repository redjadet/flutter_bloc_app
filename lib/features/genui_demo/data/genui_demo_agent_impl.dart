import 'dart:async';

import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:genui/genui.dart' as genui;
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';

class GenUiDemoAgentImpl implements GenUiDemoAgent {
  GenUiDemoAgentImpl();

  bool _isInitialized = false;
  late final genui.A2uiMessageProcessor _messageProcessor;
  late final GoogleGenerativeAiContentGenerator _contentGenerator;
  late final genui.GenUiConversation _conversation;
  StreamSubscription<String>? _textResponsesSubscription;
  StreamSubscription<genui.ContentGeneratorError>? _errorsSubscription;
  final _surfaceEventsController =
      StreamController<GenUiSurfaceEvent>.broadcast();
  final _textResponsesController = StreamController<String>.broadcast();
  final _errorsController = StreamController<String>.broadcast();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    final apiKey = SecretConfig.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('GEMINI_API_KEY not configured');
    }

    // Build catalog
    final catalog = genui.CoreCatalogItems.asCatalog();

    // Create message processor
    _messageProcessor = genui.A2uiMessageProcessor(catalogs: [catalog]);

    // Create content generator
    _contentGenerator = GoogleGenerativeAiContentGenerator(
      catalog: catalog,
      systemInstruction: _systemInstruction,
      apiKey: apiKey,
    );

    // Create conversation
    _conversation = genui.GenUiConversation(
      contentGenerator: _contentGenerator,
      a2uiMessageProcessor: _messageProcessor,
      onSurfaceAdded: (final update) {
        _surfaceEventsController.add(
          GenUiSurfaceEvent.added(surfaceId: update.surfaceId),
        );
      },
      onSurfaceDeleted: (final update) {
        _surfaceEventsController.add(
          GenUiSurfaceEvent.removed(surfaceId: update.surfaceId),
        );
      },
    );

    // Forward streams
    _textResponsesSubscription = _contentGenerator.textResponseStream.listen(
      (final text) => _textResponsesController.add(text),
    );

    _errorsSubscription = _contentGenerator.errorStream.listen(
      (final error) => _errorsController.add(error.error.toString()),
    );

    _isInitialized = true;
  }

  @override
  Future<void> sendMessage(final String text) async =>
      _conversation.sendRequest(genui.UserMessage.text(text));

  @override
  Stream<GenUiSurfaceEvent> get surfaceEvents =>
      _surfaceEventsController.stream;

  @override
  Stream<String> get textResponses => _textResponsesController.stream;

  @override
  Stream<String> get errors => _errorsController.stream;

  @override
  genui.A2uiMessageProcessor? get hostHandle => _messageProcessor;

  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      await _textResponsesSubscription?.cancel();
      await _errorsSubscription?.cancel();
      _conversation.dispose();
      _messageProcessor.dispose();
      _contentGenerator.dispose();
    }
    await _surfaceEventsController.close();
    await _textResponsesController.close();
    await _errorsController.close();
  }

  static const String _systemInstruction = '''
You are a helpful assistant that generates dynamic Flutter UI.
When the user sends a message, respond by creating UI using the available
catalog widgets. Prefer concise, simple layouts and include text labels so the
user can understand the intent of the UI.
''';
}
