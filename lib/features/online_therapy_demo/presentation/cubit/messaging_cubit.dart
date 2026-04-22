import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_messaging_repository.dart';

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
  }) => MessagingState(
    isBusy: isBusy ?? this.isBusy,
    conversations: conversations ?? this.conversations,
    selectedConversationId: identical(selectedConversationId, _noChange)
        ? this.selectedConversationId
        : selectedConversationId as String?,
    messages: messages ?? this.messages,
    draft: draft ?? this.draft,
    errorMessage: errorMessage,
  );
}

class MessagingCubit extends Cubit<MessagingState> {
  MessagingCubit({required final TherapyMessagingRepository messaging})
    : _messaging = messaging,
      super(
        const MessagingState(
          isBusy: false,
          conversations: <Conversation>[],
          messages: <Message>[],
        ),
      );

  final TherapyMessagingRepository _messaging;

  Future<void> refresh() async {
    emit(state.copyWith(isBusy: true));
    try {
      final conversations = await _messaging.listConversations();
      final currentSelection = state.selectedConversationId;
      final selected =
          currentSelection != null &&
              conversations.any((c) => c.id == currentSelection)
          ? currentSelection
          : conversations.isEmpty
          ? null
          : conversations.first.id;
      if (isClosed) return;
      emit(
        state.copyWith(
          isBusy: false,
          conversations: conversations,
          selectedConversationId: selected,
          messages: selected != null && selected == currentSelection
              ? null
              : <Message>[],
        ),
      );
      if (selected != null) {
        await selectConversation(selected);
      }
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> selectConversation(final String conversationId) async {
    emit(
      state.copyWith(
        selectedConversationId: conversationId,
        isBusy: true,
        messages: <Message>[],
      ),
    );
    try {
      final messages = await _messaging.listMessages(
        conversationId: conversationId,
      );
      if (isClosed) return;
      if (state.selectedConversationId != conversationId) return;
      emit(state.copyWith(isBusy: false, messages: messages));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  void setDraft(final String value) {
    emit(state.copyWith(draft: value));
  }

  Future<void> send() async {
    final convId = state.selectedConversationId;
    final draft = (state.draft ?? '').trim();
    if (convId == null || draft.isEmpty) return;

    emit(state.copyWith(isBusy: true));
    try {
      await _messaging.sendMessage(conversationId: convId, body: draft);
      final messages = await _messaging.listMessages(conversationId: convId);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, messages: messages, draft: ''));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> retry(final String messageId) async {
    emit(state.copyWith(isBusy: true));
    try {
      final msg = await _messaging.retryMessage(messageId: messageId);
      final convId = msg.conversationId;
      final messages = await _messaging.listMessages(conversationId: convId);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, messages: messages));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }
}
