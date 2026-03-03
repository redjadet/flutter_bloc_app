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
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

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
        child: TypeSafeBlocBuilder<FcmDemoCubit, FcmDemoState>(
          builder: (final context, final state) {
            if (state.status == FcmDemoStatus.loading ||
                state.status == FcmDemoStatus.initial) {
              return Padding(
                padding: EdgeInsets.all(context.responsiveGapL),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (state.status == FcmDemoStatus.error) {
              final String? err = state.errorMessage;
              return Padding(
                padding: EdgeInsets.all(context.responsiveGapL),
                child: Text(err ?? l10n.errorUnknown),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: context.responsiveGapL),
                CommonCard(
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
                        _permissionLabel(state.permissionState, l10n),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveGapM),
                _TokenSection(
                  label: l10n.fcmDemoFcmTokenLabel,
                  value: state.fcmToken,
                  l10n: l10n,
                ),
                SizedBox(height: context.responsiveGapS),
                _TokenSection(
                  label: l10n.fcmDemoApnsTokenLabel,
                  value: state.apnsToken,
                  l10n: l10n,
                ),
                SizedBox(height: context.responsiveGapM),
                _LastMessageSection(message: state.lastMessage, l10n: l10n),
                SizedBox(height: context.responsiveGapL),
                Text(
                  l10n.fcmDemoScopeNoteIos,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: context.responsiveGapS),
                Text(
                  l10n.fcmDemoScopeNoteSimulator,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
    final String? v = value;
    final String display = (v != null && v.isNotEmpty)
        ? v
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
              if (v != null && v.isNotEmpty)
                PlatformAdaptive.textButton(
                  context: context,
                  onPressed: () => _handleCopyPressed(context, v),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fcmDemoCopySuccess)),
        );
      }
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.fcmDemoCopyFailure),
          ),
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
                if ((msg.title ?? '').isNotEmpty)
                  Text(
                    msg.title ?? '',
                    style: theme.textTheme.titleSmall,
                  ),
                if ((msg.body ?? '').isNotEmpty)
                  Text(
                    msg.body ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                if (msg.data.isNotEmpty)
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
                if ((msg.title ?? '').isEmpty &&
                    (msg.body ?? '').isEmpty &&
                    msg.data.isEmpty)
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
