import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_messaging_repository.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:utilities/utilities.dart';

class MessagingState {
  const MessagingState({
    required this.isBusy,
    required this.conversations,
    required this.messages,
    this.selectedConversationId,
    this.draft,
    this.errorMessage,
  });

  final bool isBusy;
  final List<Conversation> conversations;
  final String? selectedConversationId;
  final List<Message> messages;
  final String? draft;
  final String? errorMessage;

  static const Object _noChange = Object();

  MessagingState copyWith({
    bool? isBusy,
    List<Conversation>? conversations,
    Object? selectedConversationId = _noChange,
    List<Message>? messages,
    String? draft,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => MessagingState(
    isBusy: isBusy ?? this.isBusy,
    conversations: conversations ?? this.conversations,
    selectedConversationId: identical(selectedConversationId, _noChange)
        ? this.selectedConversationId
        : selectedConversationId as String?,
    messages: messages ?? this.messages,
    draft: draft ?? this.draft,
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
  );
}

class MessagingCubit extends Cubit<MessagingState> {
  MessagingCubit({required this._messaging})
    : super(
        const MessagingState(
          isBusy: false,
          conversations: <Conversation>[],
          messages: <Message>[],
        ),
      );

  final TherapyMessagingRepository _messaging;
  final RequestIdGuard _operationGuard = RequestIdGuard();

  bool _isRequestStillActive(final int requestId) =>
      !isClosed && _operationGuard.isCurrent(requestId);

  Future<void> refresh() async {
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      final conversations = await _messaging.listConversations();
      if (!_isRequestStillActive(requestId)) return;
      final currentSelection = state.selectedConversationId;
      final selected =
          currentSelection != null &&
              conversations.any((c) => c.id == currentSelection)
          ? currentSelection
          : conversations.isEmpty
          ? null
          : conversations.first.id;
      emit(
        state.copyWith(
          isBusy: false,
          clearErrorMessage: true,
          conversations: conversations,
          selectedConversationId: selected,
          messages: selected != null && selected == currentSelection
              ? null
              : <Message>[],
        ),
      );
      if (!_isRequestStillActive(requestId)) return;
      if (selected != null) {
        await selectConversation(selected);
      }
    } on Object catch (e, st) {
      if (!_isRequestStillActive(requestId)) return;
      _handleOperationError(e, st, 'MessagingCubit.refresh');
    }
  }

  Future<void> selectConversation(final String conversationId) async {
    if (conversationId.trim().isEmpty) {
      _operationGuard.invalidate();
      emit(
        state.copyWith(
          isBusy: false,
          selectedConversationId: null,
          messages: <Message>[],
          clearErrorMessage: true,
        ),
      );
      return;
    }
    final requestId = _operationGuard.next();
    emit(
      state.copyWith(
        selectedConversationId: conversationId,
        isBusy: true,
        clearErrorMessage: true,
        messages: <Message>[],
      ),
    );
    try {
      final messages = await _messaging.listMessages(
        conversationId: conversationId,
      );
      if (!_isRequestStillActive(requestId)) return;
      if (state.selectedConversationId != conversationId) {
        emit(state.copyWith(isBusy: false));
        return;
      }
      emit(
        state.copyWith(
          isBusy: false,
          messages: messages,
          clearErrorMessage: true,
        ),
      );
    } on Object catch (e, st) {
      if (!_isRequestStillActive(requestId)) return;
      _handleOperationError(e, st, 'MessagingCubit.selectConversation');
    }
  }

  void setDraft(final String value) {
    emit(state.copyWith(draft: value));
  }

  Future<void> send() async {
    final convId = state.selectedConversationId;
    final draft = (state.draft ?? '').trim();
    if (convId == null || draft.isEmpty) return;

    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      await _messaging.sendMessage(conversationId: convId, body: draft);
      // Message was sent even if a newer request superseded this one.
      if (!_isRequestStillActive(requestId)) {
        if (!isClosed && state.selectedConversationId == convId) {
          emit(state.copyWith(draft: ''));
        }
        return;
      }
      final messages = await _messaging.listMessages(conversationId: convId);
      if (!_isRequestStillActive(requestId)) return;
      emit(
        state.copyWith(
          isBusy: false,
          clearErrorMessage: true,
          messages: messages,
          draft: '',
        ),
      );
    } on Object catch (e, st) {
      if (!_isRequestStillActive(requestId)) return;
      _handleOperationError(e, st, 'MessagingCubit.send');
    }
  }

  Future<void> retry(final String messageId) async {
    if (messageId.trim().isEmpty) {
      _operationGuard.invalidate();
      emit(state.copyWith(isBusy: false));
      return;
    }
    final requestId = _operationGuard.next();
    emit(state.copyWith(isBusy: true, clearErrorMessage: true));
    try {
      final msg = await _messaging.retryMessage(messageId: messageId);
      // Retry completed even if a newer request superseded this one.
      if (!_isRequestStillActive(requestId)) return;
      final convId = msg.conversationId;
      final messages = await _messaging.listMessages(conversationId: convId);
      if (!_isRequestStillActive(requestId)) return;
      emit(
        state.copyWith(
          isBusy: false,
          clearErrorMessage: true,
          messages: messages,
        ),
      );
    } on Object catch (e, st) {
      if (!_isRequestStillActive(requestId)) return;
      _handleOperationError(e, st, 'MessagingCubit.retry');
    }
  }

  void _handleOperationError(
    final Object error,
    final StackTrace stackTrace,
    final String logContext,
  ) {
    if (isClosed) return;
    CubitExceptionHandler.handleException(
      error,
      stackTrace,
      logContext,
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, errorMessage: message));
      },
    );
  }
}
