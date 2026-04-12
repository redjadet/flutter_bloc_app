import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/data/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chat_cubit_helpers.dart';
part 'chat_cubit_history_actions.dart';
part 'chat_cubit_message_actions.dart';
part 'chat_cubit_models.dart';
part 'chat_cubit_selection_actions.dart';

class ChatCubit extends _ChatCubitCore
    with
        _ChatCubitHelpers,
        _ChatCubitHistoryActions,
        _ChatCubitMessageActions,
        _ChatCubitSelectionActions {
  ChatCubit({
    required super.repository,
    required super.historyRepository,
    super.initialModel,
    super.supportedModels,
  });
}

abstract class _ChatCubitCore extends Cubit<ChatState> {
  _ChatCubitCore({
    required final ChatRepository repository,
    required final ChatHistoryRepository historyRepository,
    final String? initialModel,
    final List<String>? supportedModels,
  }) : _repository = repository,
       _historyRepository = historyRepository,
       _models = _buildModelList(initialModel, supportedModels),
       super(
         ChatState.initial(
           currentModel: _resolveInitialModel(initialModel, supportedModels),
         ),
       ) {
    _listenSupabaseAuthForTransportHint();
    _listenFirebaseAuthForTransportHint();
  }

  final ChatRepository _repository;
  final ChatHistoryRepository _historyRepository;
  final List<String> _models;
  final RequestIdGuard _requestIdGuard = RequestIdGuard();
  StreamSubscription<AuthState>? _supabaseAuthSubscription;
  StreamSubscription<firebase_auth.User?>? _firebaseAuthSubscription;

  List<String> get models => _models;
  String get _currentModel {
    if (_models.isEmpty) {
      // Defensive fallback: should never happen as _buildModelList always adds defaults
      return 'openai/gpt-oss-20b';
    }
    return state.currentModel ?? _models.first;
  }

  @protected
  ChatState get currentState => state;

  @protected
  void emitState(final ChatState newState) {
    if (isClosed) return;
    emit(newState);
  }

  @protected
  int nextRequestId() => _requestIdGuard.next();

  @protected
  bool isRequestCurrent(final int id) => _requestIdGuard.isCurrent(id);

  @protected
  void invalidateRequests() {
    _requestIdGuard.invalidate();
  }

  void clearError() {
    if (isClosed) return;
    if (state.hasError) {
      emit(
        state.copyWith(
          error: null,
          remoteFailureL10nCode: null,
          status: ViewStatus.initial,
        ),
      );
    }
  }

  void _listenFirebaseAuthForTransportHint() {
    if (Firebase.apps.isEmpty) {
      return;
    }
    _firebaseAuthSubscription = firebase_auth.FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user == null && getIt.isRegistered<RenderOrchestrationHfTokenProvider>()) {
          unawaited(
            getIt<RenderOrchestrationHfTokenProvider>().clearRenderOrchestrationTokenCache(),
          );
        }
        _refreshRunnableTransportHintOnly();
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'ChatCubit.onFirebaseAuthStateChange',
          error,
          stackTrace,
        );
      },
    );
  }

  void _listenSupabaseAuthForTransportHint() {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      return;
    }
    _supabaseAuthSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen(
          (_) {
            _refreshRunnableTransportHintOnly();
          },
          onError: (Object error, StackTrace stackTrace) {
            AppLogger.error(
              'ChatCubit.onAuthStateChange',
              error,
              stackTrace,
            );
          },
        );
  }

  void _refreshRunnableTransportHintOnly() {
    if (isClosed) {
      return;
    }
    final hint = _repository.chatRemoteTransportHint;
    if (hint == state.runnableTransportHint) {
      return;
    }
    emitState(state.copyWith(runnableTransportHint: hint));
  }

  @override
  Future<void> close() async {
    await _supabaseAuthSubscription?.cancel();
    _supabaseAuthSubscription = null;
    await _firebaseAuthSubscription?.cancel();
    _firebaseAuthSubscription = null;
    return super.close();
  }
}
