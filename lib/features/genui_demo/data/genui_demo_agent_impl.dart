import 'dart:async';

import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:genui/genui.dart' as genui;
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';

class GenUiDemoAgentImpl implements GenUiDemoAgent {
  GenUiDemoAgentImpl();

  bool _isInitialized = false;
  late final genui.GenUiManager _genUiManager;
  late final GoogleGenerativeAiContentGenerator _contentGenerator;
  late final genui.GenUiConversation _conversation;
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

    // Create GenUI manager
    _genUiManager = genui.GenUiManager(catalog: catalog);

    // Create content generator
    _contentGenerator = GoogleGenerativeAiContentGenerator(
      catalog: catalog,
      systemInstruction: _systemInstruction,
      apiKey: apiKey,
    );

    // Create conversation
    _conversation = genui.GenUiConversation(
      contentGenerator: _contentGenerator,
      genUiManager: _genUiManager,
      onSurfaceAdded: (final genui.SurfaceAdded update) {
        _surfaceEventsController.add(
          GenUiSurfaceEvent.added(surfaceId: update.surfaceId),
        );
      },
      onSurfaceDeleted: (final genui.SurfaceRemoved update) {
        _surfaceEventsController.add(
          GenUiSurfaceEvent.removed(surfaceId: update.surfaceId),
        );
      },
      onTextResponse: (final String text) {
        _textResponsesController.add(text);
      },
      onError: (final genui.ContentGeneratorError error) {
        _errorsController.add(error.error.toString());
      },
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
  genui.GenUiManager? get hostHandle => _genUiManager;

  @override
  Future<void> dispose() async {
    if (_isInitialized) {
      _conversation.dispose();
      _genUiManager.dispose();
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
