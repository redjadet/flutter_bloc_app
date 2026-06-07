import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_auth_session_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_render_orchestration_diagnostics_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';

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
    super.renderOrchestrationHfTokenProvider,
    super.authSessionPort,
    super.renderOrchestrationDiagnostics,
    super.initialModel,
    super.supportedModels,
  });
}

abstract class _ChatCubitCore extends Cubit<ChatState> {
  _ChatCubitCore({
    required this._repository,
    required this._historyRepository,
    this._renderOrchestrationHfTokenProvider,
    this._authSessionPort,
    this._renderOrchestrationDiagnostics,
    final String? initialModel,
    final List<String>? supportedModels,
  }) : _models = _buildModelList(initialModel, supportedModels),
       super(
         ChatState.initial(
           currentModel: _resolveInitialModel(initialModel, supportedModels),
         ),
       ) {
    _listenSupabaseAuthForTransportHint();
    _listenFirebaseAuthForTransportHint();
    _refreshRunnableTransportHintOnly();
  }

  final ChatRepository _repository;
  final ChatHistoryRepository _historyRepository;
  final RenderOrchestrationHfTokenProvider? _renderOrchestrationHfTokenProvider;
  final ChatAuthSessionPort? _authSessionPort;
  final ChatRenderOrchestrationDiagnosticsPort? _renderOrchestrationDiagnostics;
  final List<String> _models;
  final RequestIdGuard _requestIdGuard = RequestIdGuard();
  StreamSubscription<AuthUser?>? _supabaseAuthSubscription;
  StreamSubscription<AuthUser?>? _firebaseAuthSubscription;

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

  @protected
  void logRenderOrchestrationIfDebug(final String tag) {
    _renderOrchestrationDiagnostics?.logIfDebug(tag);
  }

  void _listenFirebaseAuthForTransportHint() {
    final authSession = _authSessionPort;
    if (authSession == null) {
      return;
    }
    _firebaseAuthSubscription = authSession.firebaseAuthStateChanges.listen(
      (user) {
        final provider = _renderOrchestrationHfTokenProvider;
        if (user == null && provider != null) {
          unawaited(provider.clearRenderOrchestrationTokenCache());
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
    final authSession = _authSessionPort;
    if (authSession == null) {
      return;
    }
    _supabaseAuthSubscription = authSession.supabaseAuthStateChanges.listen(
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
    if (kDebugMode) {
      AppLogger.info(
        'Chat: transport_hint_refresh '
        'repoHint=$hint cubitStoredHint=${state.runnableTransportHint} '
        'lastCompletion=${state.lastCompletionTransport} '
        'transportForBadge=${state.transportForBadge} '
        '(badge uses lastCompletion first; chip can stay Supabase after a '
        'Supabase fallback reply even when FastAPI Cloud demo is configured)',
      );
      logRenderOrchestrationIfDebug('cubit_transport_hint');
    }
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
