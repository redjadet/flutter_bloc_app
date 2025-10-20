import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:meta/meta.dart';

part 'chat_cubit_history_actions.dart';
part 'chat_cubit_helpers.dart';
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
       );

  final ChatRepository _repository;
  final ChatHistoryRepository _historyRepository;
  final List<String> _models;

  List<String> get models => _models;
  String get _currentModel => state.currentModel ?? _models.first;

  @protected
  ChatState get currentState => state;

  @protected
  void emitState(final ChatState newState) => emit(newState);

  void clearError() {
    if (state.hasError) {
      emit(state.copyWith(error: null, status: ChatStatus.idle));
    }
  }
}
