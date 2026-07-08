import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/backend_availability.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/app/utils/navigation.dart';
import 'package:flutter_bloc_app/app/widgets/backend_disabled_banner.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';

part 'chat_page_actions.part.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.errorNotificationService,

    /// When non-null, overrides [SecretConfig.chatRenderDemoStrict] for the transport chip strict line (widget tests).
    this.renderTransportDemoStrictOverride,
    super.key,
  });

  final ErrorNotificationService errorNotificationService;

  final bool? renderTransportDemoStrictOverride;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final bool renderDemoStrict =
        widget.renderTransportDemoStrictOverride ??
        SecretConfig.chatRenderDemoStrict;
    final bool hasHistory = context.selectState<ChatCubit, ChatState, bool>(
      selector: (final state) => state.hasHistory,
    );
    return CommonPageLayout(
      title: l10n.chatPageTitle,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.chatHistoryShowTooltip,
          onPressed: () => _showHistorySheet(context),
          icon: const Icon(Icons.history),
        ),
        IconButton(
          tooltip: l10n.chatHistoryClearAll,
          onPressed: hasHistory ? () => _confirmAndClearHistory(context) : null,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
      body: Column(
        children: <Widget>[
          BackendDisabledBanner(
            visible: () {
              final BackendAvailability availability =
                  getIt.isRegistered<BackendAvailability>()
                  ? getIt<BackendAvailability>()
                  : BackendAvailability.fromBootstrap();
              return availability.webNoBackendMode &&
                  (!availability.firebaseInitialized ||
                      !availability.supabaseInitialized);
            }(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsiveHorizontalGapL,
              context.responsiveGapM,
              context.responsiveHorizontalGapL,
              context.responsiveGapS,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: context.responsiveGapS,
              runSpacing: context.responsiveGapS,
              children: <Widget>[
                const ChatModelSelector(),
                TypeSafeBlocSelector<SyncStatusCubit, SyncStatusState, bool>(
                  selector: (final s) => !s.isOnline,
                  builder: (context, offline) {
                    if (offline) {
                      return const ChatOfflineBadge();
                    }
                    return TypeSafeBlocSelector<
                      ChatCubit,
                      ChatState,
                      ChatRemotePath?
                    >(
                      selector: (final s) => s.transportForBadge,
                      builder: (context, transport) {
                        if (transport == null) {
                          return const SizedBox.shrink();
                        }
                        final bool showFastApiCloudBadge =
                            transport == ChatRemotePath.renderOrchestration &&
                            SecretConfig.chatRenderDemoBaseUrl.contains(
                              'fastapicloud',
                            );
                        if (!showFastApiCloudBadge) {
                          return ChatTransportBadge(
                            transport: transport,
                            renderDemoStrict: renderDemoStrict,
                          );
                        }
                        return Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: context.responsiveGapS,
                          runSpacing: context.responsiveGapS,
                          children: <Widget>[
                            const ChatFastApiCloudBadge(),
                            ChatTransportBadge(
                              transport: transport,
                              renderDemoStrict: renderDemoStrict,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const ChatSyncBanner(),
          Expanded(
            child: ChatMessageList(
              controller: _scrollController,
              errorNotificationService: widget.errorNotificationService,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.responsiveHorizontalGapL,
                context.responsiveGapS,
                context.responsiveHorizontalGapL,
                context.responsiveGapS,
              ),
              child: ChatInputBar(
                controller: _controller,
                onSend: () => _submit(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
