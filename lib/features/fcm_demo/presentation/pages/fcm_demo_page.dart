import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';

/// FCM demo page: permission, tokens, last message.
class FcmDemoPage extends StatelessWidget {
  const FcmDemoPage({super.key});

  static String _permissionLabel(
    final FcmPermissionState state,
    final AppLocalizations l10n,
  ) {
    return switch (state) {
      FcmPermissionState.notDetermined => l10n.fcmDemoPermissionNotDetermined,
      FcmPermissionState.authorized => l10n.fcmDemoPermissionAuthorized,
      FcmPermissionState.denied => l10n.fcmDemoPermissionDenied,
      FcmPermissionState.provisional => l10n.fcmDemoPermissionProvisional,
    };
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.fcmDemoPageTitle,
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: const _FcmDemoBody(),
      ),
    );
  }
}

class _FcmDemoBody extends StatelessWidget {
  const _FcmDemoBody();

  @override
  Widget build(final BuildContext context) {
    final viewState = context
        .selectState<
          FcmDemoCubit,
          FcmDemoState,
          ({FcmDemoStatus status, String? errorMessage})
        >(
          selector: (final state) => (
            status: state.status,
            errorMessage: state.errorMessage,
          ),
        );

    if (viewState.status == FcmDemoStatus.loading ||
        viewState.status == FcmDemoStatus.initial) {
      return Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (viewState.status == FcmDemoStatus.error) {
      return Padding(
        padding: EdgeInsets.all(context.responsiveGapL),
        child: Text(viewState.errorMessage ?? context.l10n.errorUnknown),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: context.responsiveGapL),
        const _PermissionSection(),
        SizedBox(height: context.responsiveGapM),
        _TokenSectionContainer(
          label: context.l10n.fcmDemoFcmTokenLabel,
          selector: (final state) => state.fcmToken,
        ),
        SizedBox(height: context.responsiveGapS),
        _TokenSectionContainer(
          label: context.l10n.fcmDemoApnsTokenLabel,
          selector: (final state) => state.apnsToken,
        ),
        SizedBox(height: context.responsiveGapM),
        const _LastMessageSectionContainer(),
        SizedBox(height: context.responsiveGapL),
        Text(
          context.l10n.fcmDemoScopeNoteIos,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: context.responsiveGapS),
        Text(
          context.l10n.fcmDemoScopeNoteSimulator,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PermissionSection extends StatelessWidget {
  const _PermissionSection();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final permissionState = context
        .selectState<FcmDemoCubit, FcmDemoState, FcmPermissionState>(
          selector: (final state) => state.permissionState,
        );

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.fcmDemoPermissionLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: context.responsiveGapXS),
          Text(
            FcmDemoPage._permissionLabel(permissionState, l10n),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TokenSectionContainer extends StatelessWidget {
  const _TokenSectionContainer({
    required this.label,
    required this.selector,
  });

  final String label;
  final String? Function(FcmDemoState state) selector;

  @override
  Widget build(final BuildContext context) {
    final value = context.selectState<FcmDemoCubit, FcmDemoState, String?>(
      selector: selector,
    );
    return _TokenSection(label: label, value: value, l10n: context.l10n);
  }
}

class _LastMessageSectionContainer extends StatelessWidget {
  const _LastMessageSectionContainer();

  @override
  Widget build(final BuildContext context) {
    final message = context
        .selectState<FcmDemoCubit, FcmDemoState, PushMessage?>(
          selector: (final state) => state.lastMessage,
        );
    return _LastMessageSection(message: message, l10n: context.l10n);
  }
}

class _TokenSection extends StatelessWidget {
  const _TokenSection({
    required this.label,
    required this.value,
    required this.l10n,
  });

  final String label;
  final String? value;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final String? tokenValue = value;
    final String display = (tokenValue != null && tokenValue.isNotEmpty)
        ? tokenValue
        : l10n.fcmDemoTokenNotAvailable;
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (tokenValue != null && tokenValue.isNotEmpty)
                PlatformAdaptive.textButton(
                  context: context,
                  onPressed: () => _handleCopyPressed(context, tokenValue),
                  child: Text(l10n.fcmDemoCopyToken),
                ),
            ],
          ),
          SizedBox(height: context.responsiveGapXS),
          SelectableText(
            display,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _handleCopyPressed(final BuildContext context, final String text) {
    unawaited(_copyToken(context, text));
  }

  Future<void> _copyToken(final BuildContext context, final String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ErrorHandling.showSuccessSnackBar(
          context,
          l10n.fcmDemoCopySuccess,
        );
      }
    } on Exception {
      if (context.mounted) {
        ErrorHandling.showErrorSnackBar(
          context,
          l10n.fcmDemoCopyFailure,
        );
      }
    }
  }
}

class _LastMessageSection extends StatelessWidget {
  const _LastMessageSection({
    required this.message,
    required this.l10n,
  });

  final PushMessage? message;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final PushMessage? msg = message;
    final String titleText = msg?.title ?? '';
    final String bodyText = msg?.body ?? '';
    final bool hasTitle = titleText.isNotEmpty;
    final bool hasBody = bodyText.isNotEmpty;
    final bool hasData = msg?.data.isNotEmpty ?? false;
    final bool isEmpty = !hasTitle && !hasBody && !hasData;

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.fcmDemoLastMessageLabel,
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: context.responsiveGapXS),
          if (msg == null)
            Text(
              l10n.fcmDemoLastMessageNone,
              style: theme.textTheme.bodyMedium,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (hasTitle)
                  Text(
                    titleText,
                    style: theme.textTheme.titleSmall,
                  ),
                if (hasBody)
                  Text(
                    bodyText,
                    style: theme.textTheme.bodyMedium,
                  ),
                if (hasData)
                  Padding(
                    padding: EdgeInsets.only(top: context.responsiveGapS),
                    child: Text(
                      msg.data.entries
                          .map((final e) => '${e.key}: ${e.value}')
                          .join(', '),
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                  ),
                if (isEmpty)
                  Text(
                    msg.messageId.isNotEmpty
                        ? '${l10n.fcmDemoLastMessageReceived} (id: ${msg.messageId})'
                        : l10n.fcmDemoLastMessageReceived,
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
