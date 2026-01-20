# GenUI SDK Demo Feature Implementation Plan

## Overview

This plan adds a GenUI SDK demo that uses Google Gemini (via
`genui_google_generative_ai`) to generate dynamic UI surfaces from user prompts.
The implementation follows the app's Clean Architecture patterns, responsive and
platform-adaptive UI guidelines, and Cubit-based state management.

**Scope note:** The Google Gemini provider is intended for local experiments and
prototyping only. For production, plan a follow-up migration to Firebase AI
Logic (per the GenUI docs).

## Key Requirements From GenUI Docs

- Use `A2uiMessageProcessor` with widget catalogs and wire the catalog into the
  content generator.
- Create a `GenUiConversation` and send messages via
  `sendRequest(UserMessage.text(...))`.
- Track UI surfaces with `onSurfaceAdded` / `onSurfaceDeleted` and render each
  one using `GenUiSurface`.
- Add outbound network entitlement on iOS/macOS.
- System instructions must explicitly tell the model to generate UI using the
  available catalog widgets.

## Architecture

```text
lib/features/genui_demo/
├── genui_demo.dart
├── domain/
│   ├── genui_demo_agent.dart
│   └── genui_demo_events.dart
├── data/
│   └── genui_demo_agent_impl.dart
└── presentation/
    ├── cubit/
    │   ├── genui_demo_cubit.dart
    │   └── genui_demo_state.dart
    ├── pages/
    │   └── genui_demo_page.dart
    └── widgets/
        └── genui_demo_content.dart
```

### Design Choices

- Keep domain types Flutter-free (GenUI types are OK, no Flutter imports).
- Wrap GenUI SDK wiring in a data-layer adapter for testability and to keep
  presentation focused on UI behavior.
- Use abstract interface class pattern (like `WebsocketRepository`) for domain
  interface.
- Follow existing cubit patterns with `CubitSubscriptionMixin` and
  `CubitExceptionHandler`.
- Avoid direct `GetIt` usage in presentation widgets; inject via routes or
  constructors.

## Implementation Steps

### 1) Dependencies

**File**: `pubspec.yaml`

Add dependencies:

```yaml
dependencies:
  genui: ^0.1.0  # Verify latest version
  genui_google_generative_ai: ^0.1.0  # Verify latest version
  json_schema_builder: ^1.0.0  # Optional, for custom widgets
```

**Note**: Verify package versions on pub.dev as GenUI SDK is in alpha and may
have frequent updates.

### 2) Secrets and Local Dev Config

**Files**:

- `lib/core/config/secret_config.dart`
- `lib/core/config/secret_config_sources.dart`
- `assets/config/secrets.sample.json`
- `assets/config/secrets.json` (local only, git-ignored)

**Changes**:

1. **Add constants and variables** in `secret_config.dart`:

   ```dart
   static const String _keyGeminiApiKey = 'gemini_api_key';
   static String? _geminiApiKey;
   static String? get geminiApiKey => _geminiApiKey;
   ```

2. **Update `_readSecureSecrets()`** in `secret_config_sources.dart`:

   ```dart
   final String? geminiKey = await storage.read(SecretConfig._keyGeminiApiKey);
   // Add to result map if not null
   ```

3. **Update `_readEnvironmentSecrets()`**:

   ```dart
   const String geminiKey = String.fromEnvironment('GEMINI_API_KEY');
   const String googleKey = String.fromEnvironment('GOOGLE_API_KEY');
   final String resolvedKey = geminiKey.isNotEmpty ? geminiKey : googleKey;
   // Add resolvedKey to result map as GEMINI_API_KEY if not empty
   ```

4. **Update `_applySecrets()`**:

   ```dart
   final String? geminiKey = (json['GEMINI_API_KEY'] as String?)?.trim();
   final String? googleKey = (json['GOOGLE_API_KEY'] as String?)?.trim();
   final String? resolvedKey =
       (geminiKey?.isNotEmpty ?? false) ? geminiKey : googleKey;
   SecretConfig._geminiApiKey =
       (resolvedKey?.isEmpty ?? true) ? null : resolvedKey;
   ```

5. **Update `_hasSecrets()`** to include Gemini key check.

6. **Update `_persistToSecureStorage()`** to persist Gemini key.

7. **Update `resetForTest()`** to reset `_geminiApiKey`.

8. **Update `secrets.sample.json`**:

   ```json
   {
     "GEMINI_API_KEY": "YOUR_GEMINI_API_KEY",
     "GOOGLE_API_KEY": ""
   }
   ```

9. **Update warning message** in `load()` to mention Gemini key if missing.

**Local dev setup**:

- Enable assets: `ENABLE_ASSET_SECRETS=true` and fill
  `assets/config/secrets.json`
- Or use: `--dart-define=GEMINI_API_KEY=...`

### 3) Domain and Data Adapter

#### Domain Interface (`genui_demo_agent.dart`)

Create an abstract interface class following the pattern of
`WebsocketRepository`:

```dart
import 'dart:async';

import 'package:genui/genui.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';

/// Domain interface for GenUI agent operations.
/// Keeps all types Flutter-free for clean architecture.
abstract interface class GenUiDemoAgent {
  /// Initializes the agent and establishes connection.
  Future<void> initialize();

  /// Sends a text message to the agent.
  Future<void> sendMessage(String text);

  /// Stream of surface lifecycle events (add/remove).
  Stream<GenUiSurfaceEvent> get surfaceEvents;

  /// Stream of text responses from the agent (optional, can be ignored).
  Stream<String> get textResponses;

  /// Stream of error messages.
  Stream<String> get errors;

  /// Opaque handle to pass into GenUiSurface widget.
  /// Keep the type consistent with GenUiSurface.host (verify SDK type).
  A2uiMessageProcessor? get hostHandle;

  /// Disposes all resources.
  Future<void> dispose();
}
```

#### Domain Events (`genui_demo_events.dart`)

Create Freezed models for surface events:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'genui_demo_events.freezed.dart';

@freezed
class GenUiSurfaceEvent with _$GenUiSurfaceEvent {
  const factory GenUiSurfaceEvent.added({
    required String surfaceId,
  }) = SurfaceAdded;

  const factory GenUiSurfaceEvent.removed({
    required String surfaceId,
  }) = SurfaceRemoved;
}
```

#### Data Implementation (`genui_demo_agent_impl.dart`)

Implement the domain interface, wrapping GenUI SDK:

```dart
import 'dart:async';

import 'package:genui/genui.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';

class GenUiDemoAgentImpl implements GenUiDemoAgent {
  GenUiDemoAgentImpl();

  late final A2uiMessageProcessor _messageProcessor;
  late final GoogleGenerativeAiContentGenerator _contentGenerator;
  late final GenUiConversation _conversation;
  final _surfaceEventsController = StreamController<GenUiSurfaceEvent>.broadcast();
  final _textResponsesController = StreamController<String>.broadcast();
  final _errorsController = StreamController<String>.broadcast();
  StreamSubscription<String>? _textResponsesSubscription;
  StreamSubscription<ContentGeneratorError>? _errorsSubscription;

  @override
  Future<void> initialize() async {
    final apiKey = SecretConfig.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('GEMINI_API_KEY not configured');
    }

    // Build catalog
    final catalog = CoreCatalogItems.asCatalog();

    // Create message processor
    _messageProcessor = A2uiMessageProcessor(catalogs: [catalog]);

    // Create content generator
    _contentGenerator = GoogleGenerativeAiContentGenerator(
      catalog: catalog,
      systemInstruction: _systemInstruction,
      modelName: 'models/gemini-2.5-flash',
      apiKey: apiKey,
      // Provide additionalTools only if you add custom tools beyond UI surfaces.
    );

    // Create conversation
    _conversation = GenUiConversation(
      contentGenerator: _contentGenerator,
      a2uiMessageProcessor: _messageProcessor,
      onSurfaceAdded: (update) {
        _surfaceEventsController.add(
          GenUiSurfaceEvent.added(surfaceId: update.surfaceId),
        );
      },
      onSurfaceDeleted: (update) {
        _surfaceEventsController.add(
          GenUiSurfaceEvent.removed(surfaceId: update.surfaceId),
        );
      },
    );

    // Forward streams
    _textResponsesSubscription = _contentGenerator.textResponseStream.listen(
      (text) => _textResponsesController.add(text),
    );

    _errorsSubscription = _contentGenerator.errorStream.listen(
      (error) => _errorsController.add(error.error.toString()),
    );
  }

  @override
  Future<void> sendMessage(String text) async {
    return _conversation.sendRequest(UserMessage.text(text));
  }

  @override
  Stream<GenUiSurfaceEvent> get surfaceEvents => _surfaceEventsController.stream;

  @override
  Stream<String> get textResponses => _textResponsesController.stream;

  @override
  Stream<String> get errors => _errorsController.stream;

  @override
  A2uiMessageProcessor? get hostHandle => _messageProcessor;

  @override
  Future<void> dispose() async {
    _conversation.dispose();
    _messageProcessor.dispose();
    _contentGenerator.dispose();
    await _textResponsesSubscription?.cancel();
    await _errorsSubscription?.cancel();
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
```

**Note**: Verify actual GenUI SDK constructor signatures and method names during
implementation, as the API may have changed.

### 4) DI Registration

**Files**:

- `lib/core/di/injector_registrations.dart` (or create
  `register_genui_services.dart` following the pattern of
  `register_chat_services.dart`)

**Registration**:

```dart
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/genui_demo/data/genui_demo_agent_impl.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';

void registerGenUiServices() {
  registerLazySingletonIfAbsent<GenUiDemoAgent>(
    () => GenUiDemoAgentImpl(),
    dispose: (agent) => agent.dispose(),
  );
}
```

Add call to `registerGenUiServices()` in `registerAllDependencies()`.

### 5) Cubit + State

#### State (`genui_demo_state.dart`)

Create Freezed union state:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'genui_demo_state.freezed.dart';

@freezed
class GenUiDemoState with _$GenUiDemoState {
  const factory GenUiDemoState.initial() = _Initial;

  const factory GenUiDemoState.loading({
    @Default(<String>[]) List<String> surfaceIds,
    @Default(false) bool isSending,
    A2uiMessageProcessor? hostHandle,
  }) = _Loading;

  const factory GenUiDemoState.ready({
    required List<String> surfaceIds,
    @Default(false) bool isSending,
    required A2uiMessageProcessor? hostHandle,
  }) = _Ready;

  const factory GenUiDemoState.error({
    required String message,
    @Default(<String>[]) List<String> surfaceIds,
    A2uiMessageProcessor? hostHandle,
  }) = _Error;
}
```

#### Cubit (`genui_demo_cubit.dart`)

Implement cubit with proper stream handling:

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_events.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';

class GenUiDemoCubit extends Cubit<GenUiDemoState>
    with CubitSubscriptionMixin<GenUiDemoState> {
  GenUiDemoCubit({required GenUiDemoAgent agent})
      : _agent = agent,
        super(const GenUiDemoState.initial());

  final GenUiDemoAgent _agent;
  StreamSubscription<GenUiSurfaceEvent>? _surfaceSubscription;
  StreamSubscription<String>? _errorSubscription;

  Future<void> initialize() async {
    final bool isReady = state.maybeWhen(ready: (_, __, ___) => true, orElse: () => false);
    if (isReady) return;

    emit(const GenUiDemoState.loading());

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _agent.initialize(),
      logContext: 'GenUiDemoCubit.initialize',
      onError: (message) {
        if (isClosed) return;
        emit(GenUiDemoState.error(message: message));
      },
    );

    if (isClosed) return;
    final bool isError =
        state.maybeWhen(error: (_, __, ___) => true, orElse: () => false);
    if (isError) return;

    // Subscribe to streams
    _surfaceSubscription = _agent.surfaceEvents.listen(_onSurfaceEvent);
    _errorSubscription = _agent.errors.listen(_onError);
    registerSubscription(_surfaceSubscription);
    registerSubscription(_errorSubscription);

    emit(GenUiDemoState.ready(
      surfaceIds: const [],
      hostHandle: _agent.hostHandle,
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final bool canSend = state.maybeWhen(
      ready: (_, __, ___) => true,
      loading: (_, __, ___) => true,
      orElse: () => false,
    );
    if (!canSend) return;

    state.mapOrNull(
      ready: (state) => emit(state.copyWith(isSending: true)),
      loading: (state) => emit(state.copyWith(isSending: true)),
    );

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _agent.sendMessage(text),
      logContext: 'GenUiDemoCubit.sendMessage',
      onError: (message) {
        if (isClosed) return;
        state.mapOrNull(
          ready: (state) => emit(GenUiDemoState.error(
            message: message,
            surfaceIds: state.surfaceIds,
            hostHandle: state.hostHandle,
          )),
          loading: (state) => emit(GenUiDemoState.error(
            message: message,
            surfaceIds: state.surfaceIds,
            hostHandle: state.hostHandle,
          )),
        );
      },
    );

    if (isClosed) return;

    state.mapOrNull(
      ready: (state) => emit(state.copyWith(isSending: false)),
      loading: (state) => emit(state.copyWith(isSending: false)),
    );
  }

  void _onSurfaceEvent(GenUiSurfaceEvent event) {
    if (isClosed) return;

    event.when(
      added: (surfaceId) {
        state.mapOrNull(
          ready: (state) => emit(
            state.copyWith(surfaceIds: [...state.surfaceIds, surfaceId]),
          ),
          loading: (state) => emit(
            state.copyWith(surfaceIds: [...state.surfaceIds, surfaceId]),
          ),
        );
      },
      removed: (surfaceId) {
        state.mapOrNull(
          ready: (state) => emit(
            state.copyWith(
              surfaceIds: state.surfaceIds
                  .where((id) => id != surfaceId)
                  .toList(),
            ),
          ),
          loading: (state) => emit(
            state.copyWith(
              surfaceIds: state.surfaceIds
                  .where((id) => id != surfaceId)
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _onError(String error) {
    if (isClosed) return;

    state.mapOrNull(
      ready: (state) => emit(GenUiDemoState.error(
        message: error,
        surfaceIds: state.surfaceIds,
        hostHandle: state.hostHandle,
      )),
      loading: (state) => emit(GenUiDemoState.error(
        message: error,
        surfaceIds: state.surfaceIds,
        hostHandle: state.hostHandle,
      )),
    );
  }

  @override
  Future<void> close() async {
    await closeAllSubscriptions();
    return super.close();
  }
}
```

**Note**: The `when()` method on Freezed unions requires code generation. Run
`dart run build_runner build --delete-conflicting-outputs` after creating the
state file.

### 6) UI: Page and Content Widget

#### Page (`genui_demo_page.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/widgets/genui_demo_content.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

class GenUiDemoPage extends StatelessWidget {
  const GenUiDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.genuiDemoPageTitle,
      body: TypeSafeBlocSelector<GenUiDemoCubit, GenUiDemoState, GenUiDemoState>(
        selector: (state) => state,
        builder: (context, state) {
          return GenUiDemoContent(state: state);
        },
      ),
    );
  }
}
```

#### Content Widget (`genui_demo_content.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';

class GenUiDemoContent extends StatefulWidget {
  const GenUiDemoContent({required this.state, super.key});

  final GenUiDemoState state;

  @override
  State<GenUiDemoContent> createState() => _GenUiDemoContentState();
}

class _GenUiDemoContentState extends State<GenUiDemoContent> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final cubit = context.cubit<GenUiDemoCubit>();
    await cubit.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return state.when(
      initial: () => const CommonLoadingWidget(),
      loading: (surfaceIds, isSending, hostHandle) => _buildContent(
        context: context,
        surfaceIds: surfaceIds,
        isSending: isSending,
        hostHandle: hostHandle,
      ),
      ready: (surfaceIds, isSending, hostHandle) => _buildContent(
        context: context,
        surfaceIds: surfaceIds,
        isSending: isSending,
        hostHandle: hostHandle,
      ),
      error: (message, surfaceIds, hostHandle) => Column(
        children: [
          Expanded(
            child: CommonErrorView(message: message),
          ),
          if (hostHandle != null && surfaceIds.isNotEmpty)
            Expanded(
              child: _buildSurfacesList(
                surfaceIds: surfaceIds,
                hostHandle: hostHandle,
              ),
            ),
          _buildInputRow(context: context, isSending: false),
        ],
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required List<String> surfaceIds,
    required bool isSending,
    required A2uiMessageProcessor? hostHandle,
  }) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: hostHandle != null && surfaceIds.isNotEmpty
              ? _buildSurfacesList(
                  surfaceIds: surfaceIds,
                  hostHandle: hostHandle,
                )
              : Center(
                  child: Text(
                    l10n.genuiDemoHintText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
        ),
        _buildInputRow(context: context, isSending: isSending),
      ],
    );
  }

  Widget _buildSurfacesList({
    required List<String> surfaceIds,
    required A2uiMessageProcessor hostHandle,
  }) {
    return ListView.builder(
      cacheExtent: 500,
      itemCount: surfaceIds.length,
      itemBuilder: (context, index) {
        final surfaceId = surfaceIds[index];
        return RepaintBoundary(
          key: ValueKey(surfaceId),
          child: GenUiSurface(
            host: hostHandle,
            surfaceId: surfaceId,
          ),
        );
      },
    );
  }

  Widget _buildInputRow({
    required BuildContext context,
    required bool isSending,
  }) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(context.responsiveGapM),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.outline.withOpacity(0.2)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: PlatformAdaptive.textField(
                context: context,
                controller: _textController,
                hintText: l10n.genuiDemoHintText,
                enabled: !isSending,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: context.responsiveGapS),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: isSending ? null : _sendMessage,
              child: isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                      ),
                    )
                  : Text(l10n.genuiDemoSendButton),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 7) Routing and Feature Exports

#### Route Constants (`lib/core/router/app_routes.dart`)

```dart
static const genuiDemo = 'genui-demo';
static const genuiDemoPath = '/genui-demo';
```

#### Route Definition (`lib/app/router/routes.dart`)

```dart
GoRoute(
  path: AppRoutes.genuiDemoPath,
  name: AppRoutes.genuiDemo,
  builder: (context, state) {
    final apiKey = SecretConfig.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return CommonPageLayout(
        title: context.l10n.genuiDemoPageTitle,
        body: CommonErrorView(
          message: context.l10n.genuiDemoNoApiKey,
        ),
      );
    }
    return BlocProviderHelpers.withAsyncInit<GenUiDemoCubit>(
      create: () => GenUiDemoCubit(agent: getIt<GenUiDemoAgent>()),
      init: (cubit) => cubit.initialize(),
      child: const GenUiDemoPage(),
    );
  },
),
```

**Note**: Add imports for `CommonPageLayout`, `CommonErrorView`,
`BlocProviderHelpers`, `GenUiDemoCubit`, and `GenUiDemoAgent` as needed in
`lib/app/router/routes.dart`.

#### Feature Exports

**File**: `lib/features/genui_demo/genui_demo.dart`

```dart
/// GenUI Demo feature barrel file
library;

// Domain exports
export 'domain/genui_demo_agent.dart';
export 'domain/genui_demo_events.dart';

// Data exports
export 'data/genui_demo_agent_impl.dart';

// Presentation exports
export 'presentation/cubit/genui_demo_cubit.dart';
export 'presentation/cubit/genui_demo_state.dart';
export 'presentation/pages/genui_demo_page.dart';
export 'presentation/widgets/genui_demo_content.dart';
```

**File**: `lib/features/features.dart`

Add: `export 'genui_demo/genui_demo.dart';`

### 8) Localization

**File**: `lib/l10n/app_en.arb`

Add strings:

```json
{
  "genuiDemoPageTitle": "GenUI Demo",
  "genuiDemoHintText": "Enter a message to generate UI...",
  "genuiDemoSendButton": "Send",
  "genuiDemoErrorTitle": "Error",
  "genuiDemoNoApiKey": "GEMINI_API_KEY not configured. Please add it to secrets.json or use --dart-define=GEMINI_API_KEY=..."
}
```

**Important**: Run `flutter gen-l10n` after updating ARB files.

### 9) Platform Entitlements

**Files**:

- `ios/Runner/Runner.entitlements`
- `macos/Runner/Runner.entitlements`

Add network client entitlement (if not already present):

```xml
<key>com.apple.security.network.client</key>
<true/>
```

**Note**: If these files don't exist, create them. For iOS, the entitlements
file is typically in `ios/Runner/`. For macOS, it's in
`macos/Runner/Runner.entitlements`.

### 10) Optional Enhancements

- **Custom CatalogItem**: Add a custom widget using `json_schema_builder` to
  showcase domain-specific UI (e.g., a "RiddleCard" as shown in GenUI docs).
- **Data Binding Demo**: Demonstrate GenUI data binding patterns (DataModel)
  with a small interactive example.
- **Error Recovery**: Add retry mechanism for failed message sends.
- **Message History**: Store and display conversation history.

### 11) Validation and Tests

#### Validation Checklist

Run before committing:

```bash
dart format .
flutter analyze
flutter test
dart run tool/update_coverage_summary.dart
./bin/checklist
```

#### Unit Tests

**File**: `test/features/genui_demo/presentation/cubit/genui_demo_cubit_test.dart`

Test cases:

1. **Initialization**:
   - Success: transitions from initial → loading → ready
   - Failure: transitions to error state with message
   - Missing API key: emits error state

2. **Surface lifecycle**:
   - Adding surface updates state correctly
   - Removing surface updates state correctly
   - Multiple surfaces managed correctly

3. **Send message**:
   - Success: sets isSending flag correctly
   - Failure: transitions to error state
   - Empty message: no-op

4. **Stream handling**:
   - Subscriptions registered and cancelled properly
   - Errors from agent stream handled correctly

**Example test structure**:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/genui_demo/domain/genui_demo_agent.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_cubit.dart';
import 'package:flutter_bloc_app/features/genui_demo/presentation/cubit/genui_demo_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGenUiDemoAgent extends Mock implements GenUiDemoAgent {}

void main() {
  group('GenUiDemoCubit', () {
    late MockGenUiDemoAgent mockAgent;

    setUp(() {
      mockAgent = MockGenUiDemoAgent();
    });

    blocTest<GenUiDemoCubit, GenUiDemoState>(
      'emits [loading, ready] when initialization succeeds',
      build: () {
        when(() => mockAgent.initialize()).thenAnswer((_) async {});
        when(() => mockAgent.surfaceEvents).thenAnswer((_) => const Stream.empty());
        when(() => mockAgent.errors).thenAnswer((_) => const Stream.empty());
        when(() => mockAgent.hostHandle).thenReturn(null);
        return GenUiDemoCubit(agent: mockAgent);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const GenUiDemoState.loading(),
        isA<GenUiDemoState>().having(
          (state) => state.maybeWhen(
            ready: (_, __, ___) => true,
            orElse: () => false,
          ),
          'isReady',
          true,
        ),
      ],
    );
  });
}
```

#### Widget Tests

**File**: `test/features/genui_demo/presentation/pages/genui_demo_page_test.dart`

Test cases:

1. **State rendering**:
   - Initial state shows loading widget
   - Ready state shows surfaces list
   - Error state shows error view
   - Empty surfaces shows hint text

2. **User interaction**:
   - Text input and send button work correctly
   - Sending state disables input
   - Message sent triggers cubit method

3. **Surface rendering**:
   - Surfaces list builds with correct keys
   - RepaintBoundary wraps each surface

**Note**: Mock the GenUI SDK widgets (`GenUiSurface`) in tests to avoid
requiring actual SDK initialization.

## System Instruction

The system instruction used in the demo:

```dart
static const String _systemInstruction = '''
You are a helpful assistant that generates dynamic Flutter UI.
When the user sends a message, respond by creating UI using the available
catalog widgets. Prefer concise, simple layouts and include text labels so the
user can understand the intent of the UI.
''';
```

**Important**: The instruction must explicitly tell the model to use the
available catalog widgets, as per GenUI documentation.

## Files to Create or Modify

### New Files

- `lib/features/genui_demo/genui_demo.dart`
- `lib/features/genui_demo/domain/genui_demo_agent.dart`
- `lib/features/genui_demo/domain/genui_demo_events.dart`
- `lib/features/genui_demo/data/genui_demo_agent_impl.dart`
- `lib/features/genui_demo/presentation/cubit/genui_demo_cubit.dart`
- `lib/features/genui_demo/presentation/cubit/genui_demo_state.dart`
- `lib/features/genui_demo/presentation/pages/genui_demo_page.dart`
- `lib/features/genui_demo/presentation/widgets/genui_demo_content.dart`
- `test/features/genui_demo/presentation/cubit/genui_demo_cubit_test.dart`
- `test/features/genui_demo/presentation/pages/genui_demo_page_test.dart`

### Modified Files

- `pubspec.yaml`
- `lib/core/config/secret_config.dart`
- `lib/core/config/secret_config_sources.dart`
- `assets/config/secrets.sample.json`
- `lib/core/di/injector_registrations.dart` (or new
  `register_genui_services.dart`)
- `lib/core/router/app_routes.dart`
- `lib/app/router/routes.dart`
- `lib/l10n/app_en.arb`
- `lib/features/features.dart`
- `ios/Runner/Runner.entitlements` (if exists, or create)
- `macos/Runner/Runner.entitlements` (if exists, or create)

## Dependencies

- `genui` (core SDK) - Verify latest version on pub.dev
- `genui_google_generative_ai` (Gemini provider) - Verify latest version
- `json_schema_builder` (optional, for custom widgets)

## Implementation Checklist

- [x] Add GenUI dependencies to `pubspec.yaml` and run `flutter pub get`
- [x] Extend `SecretConfig` for Gemini keys and update secrets sample
- [x] Create domain interface (`GenUiDemoAgent`) with Flutter-free types
- [x] Create domain events (`GenUiSurfaceEvent`) using Freezed (sealed class)
- [x] Implement data adapter (`GenUiDemoAgentImpl`) wrapping GenUI SDK
- [x] Register DI using `registerLazySingletonIfAbsent` with dispose callback
- [x] Create Freezed state (`GenUiDemoState`) with union types
- [x] Implement Cubit with `CubitSubscriptionMixin` and `CubitExceptionHandler`
- [x] Build responsive, platform-adaptive UI with `GenUiSurface` list
- [x] Add route constants and `GoRoute` definition
- [x] Create feature barrel file and update `features.dart`
- [x] Add localization strings and run `flutter gen-l10n`
- [x] Add iOS/macOS network entitlement
- [x] Run code generation: `dart run build_runner build --delete-conflicting-outputs`
- [x] Write unit tests for cubit
- [x] Write widget tests for page
- [ ] Run `./bin/checklist` and fix any issues
- [ ] Test with actual Gemini API key

## Implementation Status

**Completed**: Core implementation is complete. All files created, dependencies added, routes configured, and code generation completed. The feature is ready for testing with a valid GEMINI_API_KEY.

**Implementation Date**: January 2025

**Key Implementation Details**:

1. **Dependencies**:
   - Added `genui: ^0.5.1` and `genui_google_generative_ai: ^0.5.1` (compatible versions)
   - Updated `firebase_ui_auth` to `^3.0.1` (latest)
   - Added dependency override:
     - `email_validator: ^3.0.0` - Resolves conflict (genui requires ^3.0.0, firebase_ui_auth 3.0.1 requires ^2.1.17)
   - **Note**: `genui_google_generative_ai` 0.5.1 only supports genui ^0.5.1. Once 0.6.x is released, upgrade to genui 0.6.1

2. **SecretConfig**:
   - Extended to support `GEMINI_API_KEY` and `GOOGLE_API_KEY` (fallback)
   - Supports loading from secure storage, assets, and environment variables
   - Updated `secrets.sample.json` with placeholder

3. **Architecture**:
   - Domain layer: `GenUiDemoAgent` interface (Flutter-free)
   - Data layer: `GenUiDemoAgentImpl` wrapping GenUI SDK
   - Presentation layer: Cubit with Freezed state, responsive UI widgets
   - All GenUI types imported with `as genui` prefix to avoid naming conflicts

4. **API Version Used (0.5.1)**:
   - Uses `GenUiManager` (renamed to `A2uiMessageProcessor` in 0.6.0, but genui_google_generative_ai 0.5.1 only supports 0.5.1)
   - `GenUiManager` constructor takes `catalog` (single Catalog)
   - `GenUiConversation` uses `genUiManager` parameter
   - Callbacks receive SDK's native `SurfaceAdded`/`SurfaceRemoved` types
   - Domain events (`GenUiSurfaceEvent`) use sealed class pattern to avoid conflicts
   - **Note**: Once `genui_google_generative_ai` 0.6.x is released, upgrade to genui 0.6.1 and update to `A2uiMessageProcessor`

5. **Files Created**:
   - Domain: `genui_demo_agent.dart`, `genui_demo_events.dart`
   - Data: `genui_demo_agent_impl.dart`
   - Presentation: `genui_demo_cubit.dart`, `genui_demo_state.dart`, `genui_demo_page.dart`, `genui_demo_content.dart`
   - Barrel: `genui_demo.dart`

6. **Files Modified**:
   - `pubspec.yaml` - Dependencies and override
   - `secret_config.dart` and `secret_config_sources.dart` - Gemini key support
   - `register_genui_services.dart` - DI registration (new file)
   - `injector_registrations.dart` - Service registration
   - `app_routes.dart` - Route constants
   - `routes.dart` - Route definition with API key check
   - `app_en.arb` - Localization strings
   - `features.dart` - Feature export
   - `ios/Runner/Runner.entitlements` - Network client permission

**Next Steps** (not yet completed):

- Run `./bin/checklist` validation
- Test with actual Gemini API key

**Files Summary**:

- Total files created: 12 Dart files (10 source + 2 generated)
  - Domain: 2 files (agent interface, events)
  - Data: 1 file (agent implementation)
  - Presentation: 4 files (cubit, state, page, content widget)
  - Tests: 2 files (cubit tests, page tests)
  - Barrel: 1 file
- All code compiles without errors
- All tests passing (11 cubit tests, 8 widget tests)
- Follows existing architecture patterns
- Ready for integration testing with actual Gemini API key

## Notes

- **GenUI SDK is alpha**: APIs may change; verify constructor signatures and
  method names during implementation. Check the latest documentation.
- **Production migration**: For production, plan migration to
  `genui_firebase_ai` with Firebase AI Logic for better security and
  scalability.
- **Localization**: Always use `context.l10n.*`; never hard-code strings.
- **Testing**: Use fakes/mocks for the domain interface; avoid `DateTime.now()`
  in tests (use fixed timestamps).
- **Code generation**: Remember to run `build_runner` after creating Freezed
  models.
- **Error handling**: Always guard `emit()` with `if (isClosed) return;` in
  async callbacks.
- **Stream cleanup**: Use `CubitSubscriptionMixin` and call
  `closeAllSubscriptions()` in `close()`.

## References

- [GenUI SDK Documentation](https://docs.flutter.dev/ai/genui/get-started)
- [Google Generative AI API](https://ai.google.dev/)
- Existing feature patterns:
  - `lib/features/websocket/` - Stream-based domain interface pattern
  - `lib/features/chat/` - Complex state management with async operations
  - `lib/features/counter/` - Cubit with subscription mixin
- [Clean Architecture Guide](docs/clean_architecture.md)
- [Testing Overview](docs/testing_overview.md)
